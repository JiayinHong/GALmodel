n_init = 500;   % how many random initial states

folder_random_init = '../metadata/mcmc_for_multiple_trait';
if ~exist(folder_random_init)
    mkdir(folder_random_init)
end

trait_multiple = struct();
load('../metadata/wildtype_v2_1c.mat')
trait_multiple.wt = trait;
load('../metadata/mig1d_v2_1c.mat')
trait_multiple.mig1d = trait;
load('../metadata/gal80d_v2_1c.mat')
trait_multiple.gal80d = trait;

parameter_update_wt = readtable('MCMC_parameter_config_including_all_n_d.csv');
param_init_base_wt = set_parameter(6);

error_tol = .15;
n_propose = 10000;

for i_init = 1:n_init
    parameter_val_wt = nan(height(parameter_update_wt),1);
    for i = 1:height(parameter_update_wt)
        parameter_val_wt(i) = random('lognormal', ...
            log(parameter_update_wt{i, 'prior_mean'}), ...
            parameter_update_wt{i, 'prior_sigma'} ...
            );
    end
    param_init_wt = update_param(param_init_base_wt, parameter_update_wt.parameter_name, parameter_val_wt);
    
    param_init_mig1d = param_init_wt;
    param_init_mig1d.aR = 0;
    
    param_init_gal80d = param_init_wt;
    param_init_gal80d.a80 = 0;
    param_init_gal80d.ag80 = 0;
    
    param_init = struct();
    param_init.wt = param_init_wt;
    param_init.mig1d = param_init_mig1d;
    param_init.gal80d = param_init_gal80d;
    
    trait = trait_multiple;
    jobtag = 'MCMC_multiple_trait';
    save(fullfile(folder_random_init, [jobtag, num2str(i_init, '_%03d'), '.mat']) ...
        , 'parameter_update', 'param_init' ...
        , 'error_tol', 'n_propose' ...
        , 'trait' ...
        , 'jobtag' ...
        )
end