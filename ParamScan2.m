function obj = ParamScan2(base_param, param_name, target_trait)
% caution: input 'param_name' should be a cell array

% this function is adapted from 'ParamScan', for a purpose of single
% parameter scan of massive strains. It calculat the total objective
% function value of GAL1 of all 96 wells

param = base_param;

%% scan single parameter value

param_name = param_name{1};
% perturb_coefficient = logspace(log10(0.01),log10(100),11);
perturb_coefficient = logspace(log10(0.001), log10(1000), 13);  % we scan for a broader range now
nValue = length(perturb_coefficient);

% the baseline value of the parameters
base_val = param.(param_name);
% vary parameter values based on the perturb coefficient
varied_value = perturb_coefficient .* base_val;

if regexp(param_name, 'n*')     % hill coefficients
    perturb_coefficient = linspace(1,4,7);
    nValue = length(perturb_coefficient);
    varied_value = perturb_coefficient;
end

obj = [];

for i=1:nValue
    param.(param_name) = varied_value(i);
    output = evalGalPathway(param, target_trait, '96well');
    obj(i) = output.G1obj;
    if regexp(param_name, 'n*')
        obj(8:13) = NaN;
        % to match the other dimensions so that they could be
        % stored in the same field of obj
    end
end

end
