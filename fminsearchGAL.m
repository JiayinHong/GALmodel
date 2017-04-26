function fminsearchGAL( jobtag, array_id )

folder_name = '/Users/jh428/Dropbox (HMS)/Jiayin Notebook/J9_JY_GAL_model/metadata/mcmc_mutant_and_wt_1c_Mar30';
task_id = str2double(array_id);
filepath = fullfile(folder_name, [jobtag, num2str(task_id, '_%03d'), '.mat']);
load(filepath)
parameter_name = parameter_update{:, 'parameter_name'};
param_init_value = nan(1,length(parameter_name));
for i_param = 1:length(parameter_name)
    param_name = parameter_name{i_param};
    param_init_value(i_param) = param_init.(param_name);
end

if ~isdir('../results/fminsearch');
    mkdir('../results/fminsearch');
end
outfilepath = fullfile('../results/fminsearch', [jobtag, num2str(task_id, '_%03d'), '.txt']);

opt = optimset...
    ( 'Display', 'iter' ...
    , 'OutputFcn', @(x, optimValues, state) fminsearch_outfun(x, optimValues, state, outfilepath) );

fminsearch(...
    @(x) evalGalPathway(...
    update_param( param_init, parameter_name, x )...
    , trait) ...
    , param_init_value ...
    , opt)

end