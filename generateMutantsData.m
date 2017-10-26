% this script is used to generate 'mutants' data based on wildtype good fit
% parameters, then to figure out if by single parameter scan or joint
% parameter scan, it's possible to recapture these phenotype
% created by JH on 2017.10.23

%% load a good fit of wildtype
load('../wildtype_96well-025-170925_16:18.mat', 'param_map', 'parameter_update', 'GAL1_trait')
param_names = parameter_update.parameter_name;
base_param = param_map;
mask_basal = GAL1_trait.mask_basal;
mask_induction = GAL1_trait.mask_induction;

%% setup the sugar titration gradient
gluc_gradient = [2 .^ [0:-1:-6], 0]';
galc_gradient = [0, 2 .^ [-8:1:2]];
gluc = gluc_gradient * ones(1,12);
galc = ones(8,1) * galc_gradient;
gluc = gluc(:);
galc = galc(:);

%% generate mutant trait table
n_param = length(param_names);

% generate 10 fold mutants
for i_param = 1:n_param
    clear y_ss_Glu y_ss_Gal basal_level ind_level
    new_param = base_param;
    basal_value = new_param.(param_names{i_param});
    if regexp(param_names{i_param},'n*')    % hill coefficients
        new_param.(param_names{i_param}) = 4;
    else
        new_param.(param_names{i_param}) = 10 * basal_value;     % multiplied by 10
    end
    % simulate G1 level using new parameters
    output = getInitParamsGalPathway(new_param);
    y_ss_Glu = evalMultiSugarConcentrations(new_param, output.y0_Glu, gluc, galc);
    y_ss_Gal = evalMultiSugarConcentrations(new_param, output.y0_Gal, gluc(end:-1:1), galc(end:-1:1));  % due to hysteresis?
    y_ss_Gal = y_ss_Gal(end:-1:1,:);
    basal_level = y_ss_Glu(:,1);
    ind_level = y_ss_Gal(:,1);
    
    basal_level = log(basal_level ./3000) + 7.34;   % funcional inverse of logyfp_to_nm
    ind_level = log(ind_level ./3000) + 7.34;
    
    trait = table(basal_level, ind_level, mask_basal, mask_induction, gluc, galc ...
        , 'VariableNames', {'basal_level', 'ind_level', 'mask_basal', 'mask_induction' ...
        , 'gluc', 'galc'});
    
    if regexp(param_names{i_param},'n*')    % hill coefficients
        save(fullfile('../fakeTraits/', [param_names{i_param}, '=4.mat']), 'trait')
    else
        save(fullfile('../fakeTraits/', [param_names{i_param}, '*10.mat']), 'trait')
    end
end

% generate 0.1 fold mutants
for i_param = 1:n_param
    clear y_ss_Glu y_ss_Gal basal_level ind_level
    new_param = base_param;
    basal_value = new_param.(param_names{i_param});
    if regexp(param_names{i_param},'n*')    % hill coefficients
        new_param.(param_names{i_param}) = 1;
    else
        new_param.(param_names{i_param}) = 0.1 * basal_value;     % multiplied by 0.1
    end
    % simulate G1 level using new parameters
    output = getInitParamsGalPathway(new_param);
    y_ss_Glu = evalMultiSugarConcentrations(new_param, output.y0_Glu, gluc, galc);
    y_ss_Gal = evalMultiSugarConcentrations(new_param, output.y0_Gal, gluc(end:-1:1), galc(end:-1:1));  % due to hysteresis?
    y_ss_Gal = y_ss_Gal(end:-1:1,:);
    basal_level = y_ss_Glu(:,1);
    ind_level = y_ss_Gal(:,1);
    
    basal_level = log(basal_level ./3000) + 7.34;   % funcional inverse of logyfp_to_nm
    ind_level = log(ind_level ./3000) + 7.34;
    
    trait = table(basal_level, ind_level, mask_basal, mask_induction, gluc, galc ...
        , 'VariableNames', {'basal_level', 'ind_level', 'mask_basal', 'mask_induction' ...
        , 'gluc', 'galc'});
    if regexp(param_names{i_param},'n*')    % hill coefficients
        save(fullfile('../fakeTraits/', [param_names{i_param}, '=1.mat']), 'trait')
    else
        save(fullfile('../fakeTraits/', [param_names{i_param}, '*0.1.mat']), 'trait')
    end
end


