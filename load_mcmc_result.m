function mcmc_result = load_mcmc_result(mcmc_data_folder, jobtags)
% this version is only suitable for the special version of mcmc that
% without prior

% load all result files

mcmc_result = table();
files = dir( fullfile(mcmc_data_folder, '*.mat') );

% filename_pat = '([\d_\w]+)_\d{8}_\d{6}_\d{3}_\d+.mat';
% example: 'MCMC_BC187_random_init_0217_20170217_161008_731_62002.mat'

% filename_pat = '([\d_\w]+)-\d{1,3}_\d{8}_\d{6}.mat';
% example: 'MCMC_multiple_trait-11_20170410_155138.mat'

filename_pat = '([\d_\w]+)-\d{1,3}_\d{8}_\d{2}:\d{2}.mat';
% example: 'MCMC_wt_1c-13_20170422_20:53.mat'


for i_file = 1:length(files)
    filename = files(i_file).name;
    filepath = fullfile(mcmc_data_folder, filename);
    tok = regexp(filename, filename_pat, 'tokens');
    if isempty(tok)
        fprintf('File name format warning: %s\n', filename)
    else
        if ismember(tok{1}, jobtags)
            try
                load(filepath);
            catch
                warning('Not able to load %s\n', filepath);
                continue
            end
            
            max_iter = i_propose;
            average_accept = nanmean(accept_list);
            
            [~, i] = max(prob_data_over_parameter_list);
            try
                simulation_result_linear_map = simulation_result_linear_list(i);
            catch
                simulation_result_linear_map = nan;
            end
            
            mcmc_result = [...
                mcmc_result; ...
                table(...
                {filepath}, max_iter, param_map, param_prob_map, {jobtag}, {prob_data_over_parameter_list}, average_accept, {trait}, simulation_result_linear_map, ...
                'VariableNames', {'filepath', 'max_iter', 'param_map', 'param_prob_map', 'jobtag', 'param_prob_list', 'average_accept', 'trait', 'simulation_result_linear_map'}...
                )...
                ];
        else
            % pass
        end
    end
end

fprintf('done!\n')
