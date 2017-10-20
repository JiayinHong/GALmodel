function singleParamScan(arrayID)
% this function is called directly from the shell script of the same name,
% for a batch of strains to implement single parameter scan simultaneously

strainID = str2double(arrayID);
clear param_map
clear parameter_update
load('../wildtype_96well-025-170925_16:18.mat')     % this is a 'best-fit' set of parameters of wildtype
base_param = param_map;
param_names = parameter_update.parameter_name;

%% calculate single parameter scan obj values and store

allTraits = dir('../traitExtraction/');
obj = struct();     % store the results in a struct, with a fieldname naming after the strainID
clear trait
fileName = allTraits(strainID).name;
load(fullfile('../traitExtraction/', fileName))     % load certain strain trait
for i_param = 1:length(param_names)
    tmp(i_param,:) = ParamScan2(base_param, param_names(i_param), trait);
end
fieldname = sprintf('str%d',strainID);
obj.(fieldname) = tmp;

save(fullfile('../paramScanResults/', ['res-',arrayID,'.mat']),'obj','allTraits')
% the reason to save the variable 'allTraits' is that the sequence of the
% strain names here is very important, since I am not using a string to
% name each strain, which would cause invalid naming. Here all the names
% are like 'str1', 'str2', etc. Hence, we need to save 'allTraits' to make
% sure the sequence of these strains is not messy

end


