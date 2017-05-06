function output = evalGalPathway( param, trait, fit_type )
%   the third version of eval_param, aim to increase the compatibility
%   when dealing with multiple rows and columns of data

output = getInitParamsGalPathway(param);

if nargin == 3
    
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
    
    trait = trait(index_list,:);
end

y_ss_Glu = evalMultiSugarConcentrations( param, output.y0_Glu, trait.gluc, trait.galc );
y_ss_Gal = evalMultiSugarConcentrations( param, output.y0_Gal, trait.gluc(end:-1:1), trait.galc(end:-1:1) );
y_ss_Gal = y_ss_Gal(end:-1:1,:);

basal_level = y_ss_Glu(:,1);
induction_level = y_ss_Gal(:,1);

[output.sum_obj, output.simulation_result_linear, output.experiment_result_linear] = calculate_obj( trait, basal_level, induction_level );

% autofluorescence = get_auto_fluorescence(trait);
% output.all_conc_Glu = y_ss_Glu + autofluorescence; 
% output.all_conc_Gal = y_ss_Gal + autofluorescence; 
output.all_conc_Glu = y_ss_Glu; % all 12 variables concentration at steady state, initial from Glu only condition
output.all_conc_Gal = y_ss_Gal; % all 12 variables concentration at steady state, initial from Gal only condition

end

