% this script is used to generate shell scripts to call the mcmc function
% to run on slurm
% the core of the script has been modified to a function, take folder name, jobtag and fit type as input

algorithm_list = {'mcmc', 'fminsearch'};
jobtag_list = {'wildtype_1r', 'mig1d_1r', 'gal80d_1r', 'triple_fit_1r', ...
    'wildtype_1c', 'mig1d_1c', 'gal80d_1c', 'triple_fit_1c', ...
    'wildtype_1r1c', 'mig1d_1r1c', 'gal80d_1r1c', 'triple_fit_1r1c'};
for algorithm = algorithm_list
    algorithm = algorithm{1};
    
    for jobtag = jobtag_list
        jobtag = jobtag{1};
        
        if regexp(jobtag, 'triple_fit')
            folder_name = '../metaData/mutant_and_wt_triple_fit';
        else
            folder_name = '../metaData/random_init_mutant_and_wt';
        end
        
        if regexp(jobtag, '\w*_1r$') % match words ending with 1r
            fit_type = 'one_row';
        elseif regexp(jobtag, '\w*_1c$') % match words ending with 1c
            fit_type = 'one_column';
        elseif regexp(jobtag, '\w*_1r1c$')   % match words ending with 1r1c
            fit_type = 'one_cross';
        end
        
        shell_on_slurm_generator( algorithm, jobtag, folder_name, fit_type )
    end
end

%% test what if we don't force aR=0 or a80=0, ag80=0
jobtag_list = {'all_update_mig1d_1r', 'all_update_gal80d_1r', ...
    'all_update_mig1d_1c', 'all_update_gal80d_1c', ...
    'all_update_mig1d_1r1c', 'all_update_gal80d_1r1c'};
folder_name = '../metaData/random_init_mutant_and_wt';
for jobtag = jobtag_list
    jobtag = jobtag{1};
    
    if regexp(jobtag, '\w*_1r$')
        fit_type = 'one_row';
    elseif regexp(jobtag, '\w*_1c$')
        fit_type = 'one_column';
    elseif regexp(jobtag, '\w*_1r1c$')
        fit_type = 'one_cross';
    end
    
    shell_on_slurm_generator( 'mcmc', jobtag, folder_name, fit_type )
end