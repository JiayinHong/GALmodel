%   this script is used to submit mutant and wt jobs to orchestra
%   for mig1d, we force aR=0 and don't let it change;
%   for gal80d, we force a80=ag80=0, and keep them unchange;
%   the other settings are the same to wt

n_init = 5;     % 5 replicates
n_propose = 100000;     % run for 100,000 iterations

%% generate config .mat files that only fit one column

load('../metaData/trait_extraction/mig1d_1c.mat')
base_param = set_parameter(1);
base_param.aR = 0;
parameter_update = readtable('MCMC_parameter_config_mig1d_set1.csv');
rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'mig1d_1c');

load('../metaData/trait_extraction/gal80d_1c.mat')
base_param = set_parameter(1);
base_param.a80 = 0;
base_param.ag80 = 0;
parameter_update = readtable('MCMC_parameter_config_gal80d_set1.csv');
rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'gal80d_1c');

load('../metaData/trait_extraction/wildtype_1c.mat')
base_param = set_parameter(1);
parameter_update = readtable('MCMC_parameter_config_wt_set1.csv');
rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'wildtype_1c');

%% generate config .mat files that only fit one row

load('../metaData/trait_extraction/mig1d_1r.mat')
base_param = set_parameter(1);
base_param.aR = 0;
parameter_update = readtable('MCMC_parameter_config_mig1d_set1.csv');
rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'mig1d_1r');

load('../metaData/trait_extraction/gal80d_1r.mat')
base_param = set_parameter(1);
base_param.a80 = 0;
base_param.ag80 = 0;
parameter_update = readtable('MCMC_parameter_config_gal80d_set1.csv');
rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'gal80d_1r');

load('../metaData/trait_extraction/wildtype_1r.mat')
base_param = set_parameter(1);
parameter_update = readtable('MCMC_parameter_config_wt_set1.csv');
rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'wildtype_1r');

%% generate config .mat files that fit one cross

load('../metaData/trait_extraction/mig1d_1r1c.mat')
base_param = set_parameter(1);
base_param.aR = 0;
parameter_update = readtable('MCMC_parameter_config_mig1d_set1.csv');
rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'mig1d_1r1c');

load('../metaData/trait_extraction/gal80d_1r1c.mat')
base_param = set_parameter(1);
base_param.a80 = 0;
base_param.ag80 = 0;
parameter_update = readtable('MCMC_parameter_config_gal80d_set1.csv');
rand_init_generator(n_init, trait, n_propose, base_param, parameter_update, 'gal80d_1r1c');

load('../metaData/trait_extraction/wildtype_1r1c.mat')
base_param = set_parameter(1);
parameter_update = readtable('MCMC_parameter_config_wt_set1.csv');
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
