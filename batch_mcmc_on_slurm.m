function batch_mcmc_on_slurm( folder_name, jobtag, array_id )

    task_id = str2num(array_id);
    filepath = fullfile(folder_name, [jobtag, num2str(task_id, '_%03d'), '.mat']);
    load(filepath);
    mcmc_without_prior( trait , param_init , parameter_update , 'jobtag', jobtag, 'arrayid', array_id );

end
