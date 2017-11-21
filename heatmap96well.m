% the following part is only valid in R2017a version, i.e. function in
% script

% load mcmc results
% mcmc_data_folder = '../results/singleTrans-96well/';
% mcmc_data_folder = '../results/singleTrans_noPrior/';
% 
% mcmc_data_folder = '../results/twoTrans-96well/';
% mcmc_data_folder = '../results/biTrans_noRegulation/';  % 96well, no prior version
% 
% mcmc_data_folder = '../results/biTrans_addHXT_96well/';
% mcmc_data_folder = '../results/biTrans_addHXT_noPrior/';
% 
% mcmc_data_folder = '../results/constTrans_96well/';
% mcmc_data_folder = '../results/constTrans_noPrior/';
% 
% jobtags = {'wildtype_96well', 'gal80d_96well', 'mig1d_96well'};
% mcmc_result = load_mcmc_result(mcmc_data_folder, jobtags);

% mcmc_result = sortrows(mcmc_result,'map_data_over_param','descend');    % when prior is included
% mcmc_result = sortrows(mcmc_result,'param_prob_map','descend');         % when there's no prior
%% 
i_example = 54;
param = mcmc_result{i_example, 'param_map'};

dataType = 'wildtype';      % 'wildtype' / 'mig1d' / 'gal80d'
version = 'R2017a';         % 'R2016a' / 'R2017a'
plot_heatmap(param, dataType, version)

% function heatmap96well(param, dataType, version)
function plot_heatmap(param, dataType, version)
%   This function is adapted from a previous script, used to plot 96-well
%   heatmap for wildtype/mig1d/gal80d and simulation results comparison,
%   also, compress the simulation result in eith direction and draw the
%   titration plot
%   created by JH, 2017.9.22
%   warning: be careful of the trait loading, there is only once load in
%   the current version, if changed later, be sure the old trait are not
%   overlaid by the new one

%% claim saving directory
saveDir = sprintf('../96wellPlot/%s', dataType);  % the directory to store the figures
if ~isdir(saveDir)
    mkdir(saveDir)
end
%% load experimental data
switch dataType
    case 'wildtype'
        load('../metaData/trait_extraction/S288C-double_gradient/wildtype_all_data.mat')
    case 'mig1d'
        load('../metaData/trait_extraction/S288C-double_gradient/mig1d_all_data.mat')
    case 'gal80d'
        load('../metaData/trait_extraction/S288C-double_gradient/gal80d_all_data.mat')
    otherwise
        error('choose one from ''wildtype'', ''mig1d'', and ''gal80d''')
end

expt_96well = trait;
galLabel = {'None','-8','-7','-6','-5','-4','-3','-2','-1','0','1','2'};
gluLabel = {'None','-6','-5','-4','-3','-2','-1','0'};
colLabels = fliplr(gluLabel);
rowLabels = galLabel;
load_global
alldata = nan(8,12);

if strcmp(dataType, 'gal80d')
    % gal80d is different from the other two, because all the mask_basal in
    % gal80d equals to 0 (unimodal), thus there's no need to replace
    % induced level using basal level, just change the wells we don't trust
    % to NaN
    ind3 = find(expt_96well.mask_induction == 0);
    expt_96well{ind3, 'ind_level'} = NaN;
else
    % to clean the data
    ind1 = find(expt_96well.mask_induction == 0);     % all the rows whose mask_induction == 0
    tmp = find(expt_96well(ind1,:).mask_basal == 0);
    ind2 = ind1(tmp);                               % the rows whose mask_basal also equals to 0
    ind1(tmp) = [];                                 % remove ind2 from ind1, so that ind1 only contains
                                                    % rows whose mask_induction == 0 while mask_basal ~= 0
    
    % use NaN for those induced level in ind2
    expt_96well{ind2, 'ind_level'} = NaN;
    % use basal_level to represent induced level in ind1
    expt_96well(ind1,:).ind_level = expt_96well(ind1,:).basal_level;
end

alldata(:) = logyfp_to_nm(expt_96well{:,'ind_level'});

%% fetch simulation results
output = evalGalPathway( param, trait, '96well' );

simG1_96well = nan(8,12);
simG1_96well(:) = output.all_conc_Gal(:,1);

if exist('ind1', 'var')
    % use basal level to compare with expt data when mask_basal = 1 &&
    % mask_induction == 0
    simG1_96well(ind1) = output.all_conc_Glu(ind1,1);
end

% fetch original simulation result to draw the titration plot
simG1_ind = output.all_conc_Gal(:,1);
simG1_basal = output.all_conc_Glu(:,1);

% get GAL1 obj
GAL1_obj = output.G1obj;

%% simple calculation
logAllData = log10(alldata);
logSimG1 = log10(simG1_96well);
logdelta = logSimG1 - logAllData;   % the deviation in log scale
% lindelta = simG1_96well - alldata;  % the deviation in linear scale
fprintf('\nthe total difference: %.2f\n', nansum(abs(logdelta(:))))

%% draw heatmap
switch version
    case 'R2016a'
        % first, heatmap for the expt trait
        figure
        set(gcf, 'position', [689 136 1036 811])
        heatmap(alldata, rowLabels, colLabels, '%.2f', 'Colorbar', true ...
            , 'ShowAllTicks', true, 'TextColor', 'r', 'FontSize', 14  ...
            , 'GridLines', ':', 'ColorLevels', 128, 'TickFontSize', 15);
        h=title(sprintf('%s expt G1 induced level', dataType), 'FontSize', 15);
        xlabel('galactose titration')
        ylabel('glucose titration')
        export_fig(fullfile(saveDir, h.String))
        
        % second, heatmap for simulation results
        figure
        set(gcf, 'position', [689 136 1036 811])
        heatmap(simG1_96well, rowLabels, colLabels, '%.2f' ...
            , 'ShowAllTicks', true, 'TextColor', 'r', 'FontSize', 14, 'Colorbar', true ...
            , 'GridLines', ':', 'ColorLevels', 128, 'TickFontSize', 15);
        h=title(sprintf('%s simulation G1 induced level', dataType), 'FontSize', 15);
        xlabel('galactose titration')
        ylabel('glucose titration')
        export_fig(fullfile(saveDir, h.String))
        
        % Then, difference heatmap
        figure
        set(gcf, 'position', [689 136 1036 811])
        heatmap(logdelta, rowLabels, colLabels, '%.2f' ...
            , 'MinColorValue', -1, 'MaxColorValue', 1 ...  % to normalize among different heatmaps
            , 'ShowAllTicks', true, 'TextColor', 'r', 'FontSize', 14, 'Colorbar', true ...
            , 'GridLines', ':', 'ColorLevels', 128, 'TickFontSize', 15);
        h=title(sprintf('The deviation heatmap - %s, obj=%.2f', dataType, GAL1_obj), 'FontSize', 15);
        xlabel('galactose titration')
        ylabel('glucose titration')
        export_fig(fullfile(saveDir, h.String))

    case 'R2017a'
        Cmap = parula;
        
        % first, heatmap for the expt trait
        figure
        set(gcf, 'position', [689 136 1036 811])
        h1=heatmap(rowLabels, colLabels, alldata, 'Colormap', Cmap ...
            , 'CellLabelFormat', '%.2f', 'FontSize', 12);
        title(sprintf('%s expt G1 induced level', dataType));
        export_fig(fullfile(saveDir, get(gca, 'Title')))

        % second, heatmap for simulation results
        figure
        set(gcf, 'position', [689 136 1036 811])
        h2=heatmap(rowLabels, colLabels, simG1_96well, 'Colormap', Cmap ...
            , 'CellLabelFormat', '%.2f', 'FontSize', 12);
        h2.ColorLimits = h1.ColorLimits;    % force the second heatmap has the same colorbar with the first one
        title(sprintf('%s simulation G1 induced level', dataType));
        export_fig(fullfile(saveDir, get(gca, 'Title')))

        % then, difference heatmap
        figure
        set(gcf, 'position', [689 136 1036 811])
        heatmap(rowLabels, colLabels, logdelta, 'Colormap', Cmap ...
            , 'ColorLimits', [-1 1] ...
            , 'CellLabelFormat', '%.2f', 'FontSize', 12);
        title(sprintf('The deviation heatmap - %s, obj=%.2f', dataType, GAL1_obj));
        export_fig(fullfile(saveDir, get(gca, 'Title')))

end

%% compress the data in either direction and draw the titration plot
markersize = 6;
linewid = 1.5;

% split the 96-well plate into 8 rows, each one is galactose titration
galTitrate = 1:8:89;    % the first row of gal titration

figure
set(gcf, 'position', [680 106 1052 872])

for i = 1:8     % from the first to the last row
    subplot(8,1,i)
    for j = 1:12
        index = i - 1 + galTitrate;   % get the subscript in the trait table
        sub = index(j);
        % plot experimental basal
        if trait{sub, 'mask_basal'}
            plot(j,logyfp_to_nm(trait{sub, 'basal_level'}), 'ok', 'markersize', markersize)
        else
            plot(j,logyfp_to_nm(trait{sub, 'basal_level'}), '+k', 'markersize', markersize)
        end
        hold all
        % plot experimental induced
        if trait{sub, 'mask_induction'}
            plot(j,logyfp_to_nm(trait{sub, 'ind_level'}), 'or', 'markersize', markersize)
        else
            plot(j,logyfp_to_nm(trait{sub, 'ind_level'}), '+r', 'markersize', markersize)
        end
    end
    
    plot(simG1_basal(index), 'k-', 'linewidth', linewid)
    plot(simG1_ind(index), 'r-', 'linewidth', linewid)
    
    set(gca, 'yscale', 'log', 'FontSize', 12)
    if i == 8       % the last row
        set(gca, 'XTick', 0:13)
        set(gca, 'XTickLabel', {'', galLabel{:}, ''})
    else
        set(gca, 'XTickLabel', [])
    end
    xlim([0, 13])
    ylabel(colLabels{i}, 'FontWeight', 'bold')
end

h = suplabel('glucose gradient', 'y');
h.FontSize = 15;
h = suplabel('galactose gradient', 'x');
h.FontSize = 15;
[ax,h] = suplabel(sprintf('%s galactose titration subplot', dataType), 't');
h.FontSize = 15;
export_fig(fullfile(saveDir, ax.Title.String))


% split the 96-well plate into 12 rows, each one is glucose titration
gluTitrate = 1:8;    % the first col of glu titration

figure
set(gcf, 'position', [680 106 1052 872])

for i = 1:12     % from the first to the last row
    subplot(12,1,i)
    for j = 1:8
        index = gluTitrate + 8*(i-1);   % get the subscript in the trait table
        sub = index(j);
        % plot experimental basal
        if trait{sub, 'mask_basal'}
            plot(j,logyfp_to_nm(trait{sub, 'basal_level'}), 'ok', 'markersize', markersize)
        else
            plot(j,logyfp_to_nm(trait{sub, 'basal_level'}), '+k', 'markersize', markersize)
        end
        hold all
        % plot experimental induced
        if trait{sub, 'mask_induction'}
            plot(j,logyfp_to_nm(trait{sub, 'ind_level'}), 'or', 'markersize', markersize)
        else
            plot(j,logyfp_to_nm(trait{sub, 'ind_level'}), '+r', 'markersize', markersize)
        end
    end
    
    plot(simG1_basal(index), 'k-', 'linewidth', linewid)
    plot(simG1_ind(index), 'r-', 'linewidth', linewid)
    
    set(gca, 'yscale', 'log', 'FontSize', 12)
    if i == 12      % the last row
        set(gca, 'XTickLabel', {'',colLabels{:},''})
    else
        set(gca, 'XTickLabel', [])
    end
    xlim([0, 9])
    ylabel(rowLabels{i}, 'FontWeight', 'bold')
end

h = suplabel('galactose gradient', 'y');
h.FontSize = 15;
h = suplabel('glucose gradient', 'x');
h.FontSize = 15;
[ax,h] = suplabel(sprintf('%s glucose titration subplot by row', dataType), 't');
h.FontSize = 15;
export_fig(fullfile(saveDir, ax.Title.String))



% split the 96-well plate into 12 columns, each one is glucose titration
gluTitrate = 1:8;    % the first col of glu titration

figure
set(gcf, 'position', [446 106 1286 872])

for i = 1:12     % from the first to the last row
    subplot(1,12,i)
    for j = 1:8
        index = gluTitrate + 8*(i-1);   % get the subscript in the trait table
        sub = index(j);
        % plot experimental basal
        if trait{sub, 'mask_basal'}
            plot(logyfp_to_nm(trait{sub, 'basal_level'}),9-j, 'ok', 'markersize', markersize)
        else
            plot(logyfp_to_nm(trait{sub, 'basal_level'}),9-j, '+k', 'markersize', markersize)
        end
        hold all
        % plot experimental induced
        if trait{sub, 'mask_induction'}
            plot(logyfp_to_nm(trait{sub, 'ind_level'}),9-j, 'or', 'markersize', markersize)
        else
            plot(logyfp_to_nm(trait{sub, 'ind_level'}),9-j, '+r', 'markersize', markersize)
        end
    end
    
    plot(simG1_basal(index),8:-1:1, 'k-', 'linewidth', linewid)
    plot(simG1_ind(index),8:-1:1, 'r-', 'linewidth', linewid)
    
    set(gca, 'xscale', 'log', 'FontSize', 12)
    if i == 1   % the first col
        set(gca, 'YTickLabel', {'','None','-6','-5','-4','-3','-2','-1','0',''})
    else
        set(gca, 'YTickLabel', [])
    end
    ylim([0, 9])
    xlabel(rowLabels{i}, 'FontWeight', 'bold')
end

h = suplabel('galactose gradient', 'x');
h.FontSize = 15;
h = suplabel('glucose gradient', 'y');
h.FontSize = 15;
[ax,h] = suplabel(sprintf('%s glucose titration subplot by column', dataType), 't');
h.FontSize = 15;
export_fig(fullfile(saveDir, ax.Title.String))


end

