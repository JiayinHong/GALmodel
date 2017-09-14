%% heatmap showing experimental wildtype 96-well induced G1 level

load('../metaData/trait_extraction/S288C-double_gradient/wildtype_all_data.mat')
G1_96well = trait;
galLabel = {'None','-8','-7','-6','-5','-4','-3','-2','-1','0','1','2'};
gluLabel = {'None','-6','-5','-4','-3','-2','-1','0'};
load_global
alldata = nan(8,12);
alldata(:) = logyfp_to_nm(trait{:,'ind_level'});
colLabels = fliplr(gluLabel);
rowLabels = galLabel;

figure
set(gcf, 'position', [689 136 1036 811])
% R2016a version
% heatmap(alldata, rowLabels, colLabels, '%.2f', 'Colorbar', true ...
%     , 'ShowAllTicks', true, 'TextColor', 'r', 'FontSize', 14  ...
%     , 'GridLines', ':', 'ColorLevels', 128, 'TickFontSize', 15);
% title('Wildtype G1 induced level', 'FontSize', 15)

% R2017a version
h = heatmap(rowLabels, colLabels, alldata, 'CellLabelFormat', '%.2f', 'FontSize', 15);
title('Wildtype G1 induced level')

%% Load mcmc results
load('../metaData/trait_extraction/GAL3pr_all_data.mat')
G3level = trait.basal_level;
load('../metaData/trait_extraction/GAL4pr_all_data.mat')
G4level = trait.basal_level;

mcmc_data_folder = '../results/singleTrans-96well/';
jobtags = {'wildtype_96well'};
singleTrans_96well = load_mcmc_result(mcmc_data_folder, jobtags);

%% heatmap showing simulated wildtype 96-well induced G1 level
i_example = 2;
param = singleTrans_96well{i_example, 'param_map'};
output = evalGalPathway_GAL34_changedR(param, G1_96well, 0, G3level, G4level, '96well');

simG1_96well = nan(8,12);
simG1_96well(:) = output.all_conc_Gal(:,1);

figure
set(gcf, 'position', [689 136 1036 811])
% R2016a version

% heatmap(simG1_96well, rowLabels, colLabels, '%.2f' ...
%     , 'ShowAllTicks', true, 'TextColor', 'r', 'FontSize', 14, 'Colorbar', true ...
%     , 'GridLines', ':', 'ColorLevels', 128, 'TickFontSize', 15);
% title(sprintf('The no.%d example', i_example), 'FontSize', 15)

% R2017a version
heatmap(rowLabels, colLabels, simG1_96well, 'CellLabelFormat', '%.2f', 'FontSize', 15);
title(sprintf('The no.%d example', i_example))

