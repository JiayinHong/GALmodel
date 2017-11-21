%% load bads results
badsResult = read_bads_result('../results/badsOptim/');

%% load configurations, i.e. parameter_update, param_init, etc
folder_name = '../metaData/noCompeteBinding/';
jobtag = 'wildtype_96well';
filepath = fullfile(folder_name, [jobtag, sprintf('_%03d',str2num('1')), '.mat']);  % config files are identical for the same batch
load(filepath)

%% plot 96 well heatmap for sanity check
i_example = 1;
parameter_name = parameter_update.parameter_name;
% call function 'update_param' to get the full struct of parameter values
best_param = update_param( param_init, parameter_name, badsResult{i_example,'best_params'}{1});
% plot the heatmap
heatmap96well(best_param,'wildtype','R2016a')