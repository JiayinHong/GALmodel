function output = getInitParamsGalPathway( param )
% this function is used to get the initial value for ON/OFF state

load_global;
% opt = odeset('NonNegative',1:12);
opt = [];

% generate seed param for starting from GLUCOSE only state
param.exglu = 0.25*perc_to_nm;
param.exgal = 0;
odefunc = @(t,y)GALode(t,y,param);
% when exgal==0 -> Gal3*=0, C83=0, gal=0
tmp = [0, ones(1,4),0,1,1,0,1,1,0];
[~, y] = ode15s( odefunc, [0 100000], tmp, opt);
y0_Glu=y(end,:);

% generate seed param for starting from GALACTOSE only state
param.exglu = 0;
param.exgal = 0.25*perc_to_nm;
odefunc = @(t,y)GALode(t,y,param);
% when exglu==0 -> R*=0, glu=0
tmp = [0, ones(1,6),0,1,1,0,1];
[~, y] = ode15s( odefunc, [0 100000], tmp, opt);
y0_Gal=y(end,:);

y0_Gal(1) = y0_Glu(1); % make sure GAL1 initial value is low so that we can visualize the result

% temporary solution for negative value problem
output.y0_Gal = max(y0_Gal,0);
output.y0_Glu = max(y0_Glu,0);

end

