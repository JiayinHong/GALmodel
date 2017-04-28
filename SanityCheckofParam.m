%% part I - mcmc without prior
% load data
mcmc_data_folder = '../results/mcmc_without_prior';
jobtags = {'double_gradient_wt_1c'};
mcmc_result = load_mcmc_result(mcmc_data_folder, jobtags);
trait = mcmc_result{1,'trait'}{1};
n_chain = height(mcmc_result);

%% show how parameters fit
n_example = 16;
n_row = floor(n_example ^0.5);
n_col = ceil(n_example / n_row);

figure
set(gcf, 'position', [360 156 722 542])
for i_example = 1:n_example
    param = mcmc_result{i_example, 'param_map'};
    subplot(n_row, n_col, i_example)
    param_fitting_plot(param, trait, 'one_column')
end

%% consolidate all parameters
load( mcmc_result{1,'filepath'}{1}, 'parameter_update');
param_update_names = parameter_update.parameter_name;
n_update_param = length(param_update_names);
map_param_vals = nan(n_chain, n_update_param);

% parameter values in log10 scale
for i_chain = 1:n_chain
    param_map = mcmc_result{i_chain, 'param_map'};
    for i_param = 1:n_update_param
        map_param_vals(i_chain, i_param) = log10(param_map.(param_update_names{i_param}));
    end
end

n_row = floor(n_update_param ^0.5);
n_col = ceil(n_update_param / n_row);

%% histogram
% ksdensity of parameter values
figure
set(gcf, 'position', [298 107 818 558])
for i_param = 1:n_update_param
    subplot(n_row, n_col, i_param)
    [f,xi] = ksdensity(map_param_vals(:, i_param));
    plot(xi, f, '-', 'linewidth', 2)
    hold on
    xlim([min(map_param_vals(:,i_param))-.5, max(map_param_vals(:,i_param))+.5])
    title(param_update_names{i_param})
    grid on
end

%% show parameter prior distribution
for i_param = 1:n_update_param
    subplot(n_row, n_col, i_param)
    prior_mean = parameter_update{i_param, 'prior_mean'};
    prior_sigma = parameter_update{i_param, 'prior_sigma'};
    xi = xlim();
    xi = linspace(xi(1), xi(2), 1000);
    yi = pdf('normal', xi, log10(prior_mean), prior_sigma * log10(exp(1)));
    yi = yi/max(yi) * max(ylim()) * 0.8;  % scaling so that easier to compare
    plot(xi, yi, 'k:', 'linewidth', 2)
end

        
%% part II - fminsearch
% load data





