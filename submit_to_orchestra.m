%   this script is used to submit mutant and wt jobs to orchestra
%   for mig1d, we force aR=0 and don't let it change;
%   for gal80d, we force a80=ag80=0, and keep them unchange;
%   the other settings are the same to wt

n_init = 5;     % 5 replicates
n_propose = 1000000;     % run for 1000,000 iterations
% n_propose = 20000;

%% generate config .mat files from MAP parameters
folder_MAP = '../results/GAL234-goodfittings_170707/';
folder_random_init = '../metaData/random_init_mutant_and_wt';
files = dir(fullfile(folder_MAP, '*.mat'));
n_file = length(files);
error_tol = .15;
parameter_update = readtable('July2nd_parameter_config_wt_set1.csv');

for i_file = 1:n_file
    filename = files(i_file).name;
    load(fullfile(folder_MAP, filename))
    n_propose = 1000000;    % load previous result will overwrite the value
    param_init = param_map;
    
    load('../metaData/trait_extraction/S288C-double_gradient/wildtype_1c.mat')  % trait
    jobtag = 'MAP-wildtype_1c';
    save(fullfile(folder_random_init, [jobtag, num2str(i_file, '_%03d'), '.mat'])...
        , 'parameter_update', 'param_init' ...
        , 'error_tol', 'n_propose' ...
        , 'trait' ...
        , 'jobtag'...
        )
    
    load('../metaData/trait_extraction/S288C-double_gradient/wildtype_1r.mat')
    jobtag = 'MAP-wildtype_1r';
    save(fullfile(folder_random_init, [jobtag, num2str(i_file, '_%03d'), '.mat'])...
        , 'parameter_update', 'param_init' ...
        , 'error_tol', 'n_propose' ...
        , 'trait' ...
        , 'jobtag'...
        )
    
    load('../metaData/trait_extraction/S288C-double_gradient/wildtype_1r1c.mat')
    jobtag = 'MAP-wildtype_1r1c';
    save(fullfile(folder_random_init, [jobtag, num2str(i_file, '_%03d'), '.mat'])...
        , 'parameter_update', 'param_init' ...
        , 'error_tol', 'n_propose' ...
        , 'trait' ...
        , 'jobtag'...
        )
    
end

%% generate config .mat files that only fit one column

% load('../metaData/trait_extraction/mig1d_1c.mat')
% base_param = set_parameter(1);
% base_param.aR = 0;
% parameter_update = readtable('MCMC_parameter_config_mig1d_set1.csv');
% rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'mig1d_1c');
% 
% load('../metaData/trait_extraction/gal80d_1c.mat')
% base_param = set_parameter(1);
% base_param.a80 = 0;
% base_param.ag80 = 0;
% parameter_update = readtable('MCMC_parameter_config_gal80d_set1.csv');
% rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'gal80d_1c');

load('../metaData/trait_extraction/S288C-double_gradient/wildtype_1c.mat')
base_param = set_parameter(1);
parameter_update = readtable('July2nd_parameter_config_wt_set1.csv');
rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'wildtype_1c');

%% generate config .mat files that only fit one row

% load('../metaData/trait_extraction/mig1d_1r.mat')
% base_param = set_parameter(1);
% base_param.aR = 0;
% parameter_update = readtable('MCMC_parameter_config_mig1d_set1.csv');
% rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'mig1d_1r');
% 
% load('../metaData/trait_extraction/gal80d_1r.mat')
% base_param = set_parameter(1);
% base_param.a80 = 0;
% base_param.ag80 = 0;
% parameter_update = readtable('MCMC_parameter_config_gal80d_set1.csv');
% rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'gal80d_1r');

load('../metaData/trait_extraction/S288C-double_gradient/wildtype_1r.mat')
base_param = set_parameter(1);
parameter_update = readtable('July2nd_parameter_config_wt_set1.csv');
rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'wildtype_1r');

%% generate config .mat files that fit one cross

% load('../metaData/trait_extraction/mig1d_1r1c.mat')
% base_param = set_parameter(1);
% base_param.aR = 0;
% parameter_update = readtable('MCMC_parameter_config_mig1d_set1.csv');
% rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'mig1d_1r1c');
% 
% load('../metaData/trait_extraction/gal80d_1r1c.mat')
% base_param = set_parameter(1);
% base_param.a80 = 0;
% base_param.ag80 = 0;
% parameter_update = readtable('MCMC_parameter_config_gal80d_set1.csv');
% rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'gal80d_1r1c');

load('../metaData/trait_extraction/S288C-double_gradient/wildtype_1r1c.mat')
base_param = set_parameter(1);
parameter_update = readtable('July2nd_parameter_config_wt_set1.csv');
rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'wildtype_1r1c');

%% generate shell script for calling mcmc function to run on LSF cluster

% fid = fopen('MCMC_mutant_and_wt_1c_orchestra_Mar30.sh', 'w');
% for i_init = 1:n_init
%     jobtag = 'MCMC_mig1d_1c';
%     filepath = fullfile(folder_random_init, [jobtag, num2str(i_init, '_%03d'), '.mat']);
%     fprintf(fid, 'bsub -q long -o out -W 240:00 matlab -r "load(''%s''); mcmc2( trait , param_init , parameter_update , ''n_propose'',n_propose , ''error_tol'', error_tol , ''jobtag'', jobtag ); "\n', filepath);
%     jobtag = 'MCMC_gal80d_1c';
%     filepath = fullfile(folder_random_init, [jobtag, num2str(i_init, '_%03d'), '.mat']);
%     fprintf(fid, 'bsub -q long -o out -W 240:00 matlab -r "load(''%s''); mcmc2( trait , param_init , parameter_update , ''n_propose'',n_propose , ''error_tol'', error_tol , ''jobtag'', jobtag ); "\n', filepath);
%     jobtag = 'MCMC_wt_1c';
%     filepath = fullfile(folder_random_init, [jobtag, num2str(i_init, '_%03d'), '.mat']);
%     fprintf(fid, 'bsub -q long -o out -W 240:00 matlab -r "load(''%s''); mcmc2( trait , param_init , parameter_update , ''n_propose'',n_propose , ''error_tol'', error_tol , ''jobtag'', jobtag ); "\n', filepath);
% end
% fclose(fid);
