function fminsearchGAL( trait, param_init, parameter_update, jobtag, array_id, fit_type )

parameter_name = parameter_update{:, 'parameter_name'};
param_init_value = nan(1,length(parameter_name));
for i_param = 1:length(parameter_name)
    param_name = parameter_name{i_param};
    param_init_value(i_param) = param_init.(param_name);
end

if ~isdir('../results/fminsearch')
    mkdir('../results/fminsearch');
end

task_id = str2double(array_id);
outfilepath = fullfile(...
    '../results/fminsearch/', ...
    sprintf(...
    '%s-%s-%s.txt', ...
    jobtag, num2str(task_id, '%03d'), ...
    datestr(now, 'yymmdd_hh:MM') ...
    ) ...
    );

opt = optimset...
    ( 'Display', 'iter' ...
    , 'OutputFcn', @(x, optimValues, state) fminsearch_outfun(x, optimValues, state, outfilepath) );

fminsearch(...
    @(x) myfun(...
    update_param( param_init, parameter_name, x )...
    , trait, fit_type ) ...
    , param_init_value ...
    , opt)

end

function sum_obj = myfun(param, trait, fit_type)
output = evalGalPathway(param, trait, fit_type);
sum_obj = output.sum_obj;
end