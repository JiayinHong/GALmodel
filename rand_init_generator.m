function rand_init_generator( n_init, trait, n_propose, base_param, parameter_update, jobtag )
%   use this function to generate random initial state for later use like
%   mcmc or fminsearch, given trait, base_param, parameter_update, jobtag etc. 
%   this function is called by 'submit_to_orchestra'

error_tol = .15;
folder_random_init = '../metaData/random_init_mutant_and_wt';
if ~exist(folder_random_init)
    mkdir(folder_random_init)
end

for i_init = 1:n_init
    parameter_val = nan(height(parameter_update), 1);
    for i = 1:height(parameter_update)
        parameter_val(i) = random('lognormal', ...
            log(parameter_update{i, 'prior_mean'}), ...
            parameter_update{i, 'prior_sigma'} ...
            );
    end
    param_init = update_param(base_param, parameter_update.parameter_name, parameter_val);
    
    save(fullfile(folder_random_init, [jobtag, num2str(i_init, '_%03d'), '.mat'])...
        , 'parameter_update', 'param_init' ...
        , 'error_tol', 'n_propose' ...
        , 'trait' ...
        , 'jobtag'...
        )
end

end

