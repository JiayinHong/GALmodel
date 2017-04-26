% this script is used to generate shell scripts to call the mcmc function
% to run on slurm
% better modify it to a function, take folder name and job type as input

str1 = '#!/bin/bash\n';
str2 = '#SBATCH -p medium\n';
str3 = '#SBATCH -t 5-00:00\n';
str4 = '#SBATCH -c 1\n';
str5 = '#SBATCH --mem-per-cpu=4G';
str6 = '#SBATCH -e ../err_files/%%A_%%a.err\n';
str7 = '#SBATCH -o ../out_files/%%A_%%a.out\n';
str8 = 'module load gcc/6.2.0 matlab/2016b\n';
long_string = [str1, str2, str3, str4, str5, str6, str7, str8];

folder_name_list = {'../metadata/mcmc_mutant_and_wt_1r_random_start/', ...
    '../metadata/mcmc_mutant_and_wt_1c_random_start/', ...
    '../metadata/mcmc_mutant_and_wt_1r1c_random_start/', ...
    '../metadata/mcmc_mutant_and_wt_all_data_random_start/'};

for folder_name = folder_name_list
    
    switch folder_name{1}
        case '../metadata/mcmc_mutant_and_wt_1r_random_start/'
            jobtype_list = {'wt_1r', 'mig1d_1r', 'gal80d_1r'};
        case '../metadata/mcmc_mutant_and_wt_1c_random_start/'
            jobtype_list = {'wt_1c', 'mig1d_1c', 'gal80d_1c'};
        case '../metadata/mcmc_mutant_and_wt_1r1c_random_start/'
            jobtype_list = {'wt_1r1c', 'mig1d_1r1c', 'gal80d_1r1c'};
        case '../metadata/mcmc_mutant_and_wt_all_data_random_start/'
            jobtype_list = {'wt_alldata', 'mig1d_alldata', 'gal80d_alldata'};
    end
    
    for jobtype = jobtype_list
        
        jobtype = jobtype{1};
        script_name = sprintf('slurm_%s.sh', jobtype);
        fid = fopen(fullfile('../shell_script',script_name), 'w');
        fprintf(fid, long_string);
        prefix = 'matlab -nodesktop -nosplash -nojit -r ';
        jobtag = sprintf('MCMC_%s', jobtype);
        fprintf(fid, '%s "mcmc_on_slurm ''%s'' ''%s'' ''${SLURM_ARRAY_TASK_ID}'' "', prefix, folder_name, jobtag);
        
    end
    
end
