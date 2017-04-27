%   this script is used to submit mutant and wt jobs to orchestra
%   for mig1d, we force aR=0 and don't let it change;
%   for gal80d, we force a80=ag80=0, and keep them unchange;
%   the other settings are the same to wt

n_init = 200;

folder_random_init = '../metadata/mcmc_mutant_and_wt_1c';
if ~exist(folder_random_init)
    mkdir(folder_random_init)
end

load('../metadata/trait_extraction/mig1d_1c.mat')
trait_mig1d_1c = trait;

load('../metadata/trait_extraction/gal80d_1c.mat')
trait_gal80d_1c = trait;

load('../metadata/trait_extraction/wildtype_1c.mat')
trait_wt_1c = trait;

%%  generate config .mat files for wildtype
parameter_update = readtable('MCMC_parameter_config.csv');
error_tol = .15;
n_propose = 10000;
param_init_base = set_parameter(2);
for i_init = 1:n_init
    parameter_val = nan(height(parameter_update), 1);
    for i = 1:height(parameter_update)
        parameter_val(i) = random('lognormal', ...
            log(parameter_update{i, 'prior_mean'}), ...
            parameter_update{i, 'prior_sigma'} ...
            );
    end
    param_init = update_param(param_init_base, parameter_update.parameter_name, parameter_val);
    
    trait = trait_wt_1c;
    jobtag = 'double_gradient_wt_1c';
    save(fullfile(folder_random_init, [jobtag, num2str(i_init, '_%03d'), '.mat'])...
        , 'parameter_update', 'param_init' ...
        , 'error_tol', 'n_propose' ...
        , 'trait' ...
        , 'jobtag'...
        )
end

%% generate config .mat files for gal80d
parameter_update = readtable('MCMC_parameter_config_gal80d.csv');
error_tol = .15;
n_propose = 10000;
param_init_base = set_parameter(7);
for i_init = 1:n_init
    parameter_val = nan(height(parameter_update), 1);
    for i = 1:height(parameter_update)
        parameter_val(i) = random('lognormal', ...
            log(parameter_update{i, 'prior_mean'}), ...
            parameter_update{i, 'prior_sigma'} ...
            );
    end
    param_init = update_param(param_init_base, parameter_update.parameter_name, parameter_val);
    
    trait = trait_gal80d_1c;
    jobtag = 'MCMC_gal80d_1c';
    save(fullfile(folder_random_init, [jobtag, num2str(i_init, '_%03d'), '.mat'])...
        , 'parameter_update', 'param_init' ...
        , 'error_tol', 'n_propose' ...
        , 'trait' ...
        , 'jobtag'...
        )
    
end

%% generate config .mat files for mig1d
parameter_update = readtable('MCMC_parameter_config_mig1d.csv');
error_tol = .15;
n_propose = 10000;
param_init_base = set_parameter(5);
for i_init = 1:n_init
    parameter_val = nan(height(parameter_update), 1);
    for i = 1:height(parameter_update)
        parameter_val(i) = random('lognormal', ...
            log(parameter_update{i, 'prior_mean'}), ...
            parameter_update{i, 'prior_sigma'} ...
            );
    end
    param_init = update_param(param_init_base, parameter_update.parameter_name, parameter_val);
    
    trait = trait_mig1d_1c;
    jobtag = 'MCMC_mig1d_1c';
    save(fullfile(folder_random_init, [jobtag, num2str(i_init, '_%03d'), '.mat'])...
        , 'parameter_update', 'param_init' ...
        , 'error_tol', 'n_propose' ...
        , 'trait' ...
        , 'jobtag'...
        )
    
end

%% generate shell script for calling mcmc function to run on LSF cluster
fid = fopen('MCMC_mutant_and_wt_1c_orchestra_Mar30.sh', 'w');
for i_init = 1:n_init
    jobtag = 'MCMC_mig1d_1c';
    filepath = fullfile(folder_random_init, [jobtag, num2str(i_init, '_%03d'), '.mat']);
    fprintf(fid, 'bsub -q long -o out -W 240:00 matlab -r "load(''%s''); mcmc2( trait , param_init , parameter_update , ''n_propose'',n_propose , ''error_tol'', error_tol , ''jobtag'', jobtag ); "\n', filepath);
    jobtag = 'MCMC_gal80d_1c';
    filepath = fullfile(folder_random_init, [jobtag, num2str(i_init, '_%03d'), '.mat']);
    fprintf(fid, 'bsub -q long -o out -W 240:00 matlab -r "load(''%s''); mcmc2( trait , param_init , parameter_update , ''n_propose'',n_propose , ''error_tol'', error_tol , ''jobtag'', jobtag ); "\n', filepath);
    jobtag = 'MCMC_wt_1c';
    filepath = fullfile(folder_random_init, [jobtag, num2str(i_init, '_%03d'), '.mat']);
    fprintf(fid, 'bsub -q long -o out -W 240:00 matlab -r "load(''%s''); mcmc2( trait , param_init , parameter_update , ''n_propose'',n_propose , ''error_tol'', error_tol , ''jobtag'', jobtag ); "\n', filepath);
end
fclose(fid);
