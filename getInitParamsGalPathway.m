function output = getInitParamsGalPathway( param )
% this function is used to get the initial value for ON/OFF state

load_global;
% opt = odeset('NonNegative',1:12);
opt = odeset('NonNegative',1:11);
accurate_thresh = 10^-8;
% opt = [];
% opt = odeset('AbsTol', 1e-12, 'RelTol', 1e-12);

% generate seed param for starting from GLUCOSE only state
% param.exglu = 0.25*perc_to_nm;
param.exglu = 2*perc_to_nm;     % to solve the bifurcation problem
param.exgal = 0;

% The Current Equations In Use Is GALode3!
odefunc = @(t,y)GALode3(t,y,param);

% when exgal==0 -> Gal3*=0, C83=0, gal=0
% tmp = ones(1,12);
% tmp(1) = 0;     % Gal1
% tmp(6) = 0;     % Gal3*
% tmp(9) = 0;     % C83
% tmp(12) = 0;    % intracellular galactose

% delete R*, there are only 11 species
tmp = ones(1,11);
tmp(1) = 0;     % Gal1
tmp(6) = 0;     % Gal3*
tmp(8) = 0;     % C83
tmp(11) = 0;    % intracellular galactose
[~, y] = ode15s( odefunc, [0 10000], tmp, opt);

y(y<accurate_thresh) = 0;   % omit values that are too small
y0_Glu=y(end,:);

% generate seed param for starting from GALACTOSE only state
param.exglu = 0;
% param.exgal = 0.25*perc_to_nm;
param.exgal = 2*perc_to_nm;     % i.e. sometimes the local and cluster got different results

% The Current Equations In Use Is GALode3!
odefunc = @(t,y)GALode3(t,y,param);

% when exglu==0 -> R*=0, glu=0
% tmp = ones(1,12);
% tmp(1) = 0;     % Gal1
% tmp(8) = 0;     % R*
% tmp(11) = 0;    % intracellular glucose

% delete R*, there are only 11 species
tmp = ones(1,11);
tmp(1) = 0;     % Gal1
tmp(10) = 0;    % intracellular glucose

[~, y] = ode15s( odefunc, [0 10000], tmp, opt);

y(y<accurate_thresh) = 0;   
y0_Gal=y(end,:);

y0_Gal(1) = y0_Glu(1); % make sure GAL1 initial value is low so that we can visualize the result

% temporary solution for negative value problem
output.y0_Gal = max(y0_Gal,0);
output.y0_Glu = max(y0_Glu,0);

end

