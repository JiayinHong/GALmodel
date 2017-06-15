function obj = ParamSensitivity2( param_set, param_name, percent_to_change )
%   This function aims to compare three metrics between baseline parameter
%   vales and increased or decreased parameter values, the induced level,
%   the objective function, and the decision threshold. For the induced
%   level, each subplot show the scenario for one parameter variation, use
%   marker circle to represent the level of baseline value, and
%   upward-pointing triangle to represent the level of increased value, and
%   downward-pointing triangle to represent the level of decrease value
%   the output 'obj' has three fields: col, row, and cross. For each field,
%   the first one is the baseline value, the second one is the increased
%   value, while the third one is the decreased value.

%% load wildtype trait and a set of parameters
load('../metaData/trait_extraction/wildtype_1c.mat')
wt_trait_1c = trait;
load('../metaData/trait_extraction/wildtype_1r.mat')
wt_trait_1r = trait;
load('../metaData/trait_extraction/wildtype_1r1c.mat')
wt_trait_1r1c = trait;

% the baseline value of the parameters
param = param_set;

% calculate the increased value and the decreased value
base_val = param.(param_name);
% increase the baseline value by 'percent to change'
add_val = base_val * (1+percent_to_change);
% decrease the baseline value by 'percent to change'
min_val = base_val * (1-percent_to_change);

markersize = 6;

obj = struct();

%% simulate the induced level by taking the parameters into the ode
figure
set(gcf, 'position', [447 243 1330 428])

% simulate for one column fitting
[base_tab, base_obj] = sensitivity_helper(param, wt_trait_1c, 'one_column');
obj.col(1) = base_obj;
n_condition = height(base_tab);

param.(param_name) = add_val;
[increase_tab, inc_obj] = sensitivity_helper(param, wt_trait_1c, 'one_column');
obj.col(2) = inc_obj;

param.(param_name) = min_val;
[decrease_tab, dec_obj] = sensitivity_helper(param, wt_trait_1c, 'one_column');
obj.col(3) = dec_obj;

% make the plot for one column fitting
subplot(1,3,1)
plot(base_tab{:, 'sim_induce'}, 'ko', 'markersize', markersize+2)
hold on
plot(increase_tab{:, 'sim_induce'}, 'r^', 'markersize', markersize)
hold on
plot(decrease_tab{:, 'sim_induce'}, 'gv', 'markersize', markersize)
hold off
set(gca, 'yscale', 'log')
grid on
xlim([0 n_condition+1])
title(sprintf('base: %1.2f, inc: %1.2f, dec: %1.2f', base_obj, inc_obj, dec_obj))

% simulate for one row fitting
param.(param_name) = base_val;
[base_tab, base_obj] = sensitivity_helper(param, wt_trait_1r, 'one_row');
obj.row(1) = base_obj;
n_condition = height(base_tab);

param.(param_name) = add_val;
[increase_tab, inc_obj] = sensitivity_helper(param, wt_trait_1r, 'one_row');
obj.row(2) = inc_obj;

param.(param_name) = min_val;
[decrease_tab, dec_obj] = sensitivity_helper(param, wt_trait_1r, 'one_row');
obj.row(3) = inc_obj;

% make the plot for one row fitting
subplot(1,3,2)
plot(base_tab{:, 'sim_induce'}, 'ko', 'markersize', markersize+2)
hold on
plot(increase_tab{:, 'sim_induce'}, 'r^', 'markersize', markersize)
hold on
plot(decrease_tab{:, 'sim_induce'}, 'gv', 'markersize', markersize)
hold off
set(gca, 'yscale', 'log')
grid on
xlim([0 n_condition+1])
title(sprintf('base: %1.2f, inc: %1.2f, dec: %1.2f', base_obj, inc_obj, dec_obj))

% simulate for one cross fitting
param.(param_name) = base_val;
[base_tab, base_obj] = sensitivity_helper(param, wt_trait_1r1c, 'one_cross');
obj.cross(1) = base_obj;
n_condition = height(base_tab);

param.(param_name) = add_val;
[increase_tab, inc_obj] = sensitivity_helper(param, wt_trait_1r1c, 'one_cross');
obj.cross(2) = inc_obj;

param.(param_name) = min_val;
[decrease_tab, dec_obj] = sensitivity_helper(param, wt_trait_1r1c, 'one_cross');
obj.cross(3) = dec_obj;

% make the plot for one cross fitting
subplot(1,3,3)
plot(base_tab{:, 'sim_induce'}, 'ko', 'markersize', markersize+2)
hold on
plot(increase_tab{:, 'sim_induce'}, 'r^', 'markersize', markersize)
hold on
plot(decrease_tab{:, 'sim_induce'}, 'gv', 'markersize', markersize)
hold off
set(gca, 'yscale', 'log')
grid on
xlim([0 n_condition+1])
title(sprintf('base: %1.2f, inc: %1.2f, dec: %1.2f', base_obj, inc_obj, dec_obj))

[~,h1] = suplabel(sprintf('%s', param_name),'t');
set(h1, 'FontSize', 18, 'FontName', 'Helvetica')
outpath = fullfile('../results/param_sensitivity_analysis2/', sprintf('vary_by_%.2f/', percent_to_change));
if ~exist(outpath)
    mkdir(outpath)
end
export_fig(fullfile(outpath, sprintf('%s sensitivity analysis', param_name)));

end


function [eval_tab, obj] = sensitivity_helper( param, trait, fit_type )
output = evalGalPathway( param, trait, fit_type);

fit_type_config;

sugar_ratio = trait{index_list, 'galc'} ./ trait{index_list, 'gluc'};
eval_tab = table(output.experiment_result_linear(:,1)...
    , output.experiment_result_linear(:,2)...
    , output.simulation_result_linear(:,1)...
    , output.simulation_result_linear(:,2)...
    , trait{index_list, 'mask_basal'}...
    , trait{index_list, 'mask_induction'}...
    , sugar_ratio...
    , 'VariableNames', {'exp_basal', 'exp_induce', 'sim_basal', 'sim_induce', 'mask_basal', 'mask_induce', 'sugar_ratio'});

eval_tab = sortrows(eval_tab, 'sugar_ratio', 'ascend');
obj = output.sum_obj;

end