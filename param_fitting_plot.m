function  param_fitting_plot( param, trait, fit_type )
% this version works for single gradient, one row, one column, 
% or one cross of double gradient data

output = evalGalPathway( param, trait );
markersize = 5;

switch fit_type
    case 'one_row'
        index_list = [4:8:92];
    case 'one_column'
        index_list = [65:72];
    case 'one_cross'
        index_list = [4:8:60,65:72,76,84,92];
    case 'single_gradient'
        index_list = [1:12];
end

n_condition = length(index_list);

for i_condition = 1:n_condition
    if trait{index_list(i_condition), 'mask_basal'}
        plot(i_condition, output.experiment_result_linear(index_list(i_condition), 1), 'ok', 'markersize', markersize)
    else
        plot(i_condition, output.experiment_result_linear(index_list(i_condition), 1), '+k', 'markersize', markersize)
    end
    hold on
    if trait{index_list(i_condition), 'mask_induction'}
        plot(i_condition, output.experiment_result_linear(index_list(i_condition), 2), 'or', 'markersize', markersize)
    else
        plot(i_condition, output.experiment_result_linear(index_list(i_condition), 2), '+r', 'markersize', markersize)
    end
end

plot(output.simulation_result_linear(index_list,1), 'k-', 'linewidth', 2)
plot(output.simulation_result_linear(index_list,2), 'r-', 'linewidth', 2)
set(gca, 'yscale', 'log')
xlim([0, n_condition+1])
title(num2str(output.sum_obj, 'obj: %1.2f'))


end

