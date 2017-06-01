param_names = fieldnames(param_map);
for param_name = param_names'
    param_name = param_name{1};
    ParamSensitivity(param_map, param_name)
end

%%
fid = fopen(fullfile('../results/param_sensitivity_analysis/', ...
                    'param info.txt'), 'a');   
% open or create new file for writing. Append data to the end of the file.

fprintf(fid, '\n\nAppendix - baseline parameter values:\n\n');
for fdn = fieldnames(param_map)'
    fdn = fdn{1};
    fprintf(fid, '%s = %.04f\n', fdn, param.(fdn));
end

fclose(fid);