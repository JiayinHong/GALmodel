function batch_fminsearch_on_slurm( folder_name, jobtag, array_id )

    task_id = str2num(array_id);
    filepath = fullfile(folder_name, [jobtag, num2str(task_id, '_%03d'), '.mat']);
    load(filepath);
    fminsearchGAL( jobtag, array_id );

end
