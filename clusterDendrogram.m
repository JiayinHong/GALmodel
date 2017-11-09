%% heatmap, cluster & dendrogram for single mutants data

% load obj results from each file, then store them all in 'obj_all'
clear
obj_all = struct;
tmp = dir('../paramScanResults/');
for i=3:length(tmp)     % the first 2 are not files
    if ~ strcmp(tmp(i).name, '.DS_Store')
        load(fullfile('../paramScanResults/', tmp(i).name))
        str = fieldnames(obj);  % fieldnames is a cell
        str = str{1};           % convert cell to char
        no = str(4:end);        % 'str10' -> '10'
        %         no = str2num(no)-2;     % '10' -> 8
        no = str2num(no)-3;     % be careful to -2 / -3,
        % if there's '.DS_Store' in the traits folder, should -3
        fdn = sprintf('str%02d',no);    % fdn='str08'
        obj_all.(fdn) = obj.(str);  % assign the value to the same field of obj_all
    end
end

% store all the strain names into a cell array
clear strNames
nStr = numel(fieldnames(obj_all));
strNames = cell(nStr,1);

for i=3:length(allTraits)   % the first 2 are not traits
    if ~ strcmp(allTraits(i).name, '.DS_Store')
        tmp = allTraits(i).name;
        strNames{i-3} = tmp(1:end-4);   % to remove '.mat'
    end
end

% organize the data
nPerturb = size(obj_all.str01,1);
mydata = nan(nStr,nPerturb);
for iStr = 1:nStr
    fdn = num2str(sprintf('str%02d',iStr));
    for iPerturb = 1:nPerturb
        mydata(iStr,iPerturb) = min(obj_all.(fdn)(iPerturb,:));
    end
end

% make a list of sorted strain names
load('../wildtype_96well-025-170925_16:18.mat')
param_names = parameter_update.parameter_name;
rowLabels = param_names;

for i=1:length(param_names)
    if regexp(param_names{i},'n*')
        tmp1 = sprintf([param_names{i}, '=4']);
        tmp2 = sprintf([param_names{i}, '=1']);
    else
        tmp1 = sprintf([param_names{i}, '*10']);
        tmp2 = sprintf([param_names{i}, '*0.1']);
    end
    sortedNames{2*i-1} = tmp1;
    sortedNames{2*i} = tmp2;
end

[~, ind] = ismember(sortedNames, strNames);
mySortedData = mydata(ind,:);
colLabels = sortedNames;

% make heatmap
Cmap = flipud(parula);

figure
set(gcf, 'position', [245 50 400 655])
heatmap(rowLabels, colLabels, mySortedData, 'Colormap', Cmap ...
    , 'ColorScaling', 'log' ...
    , 'ColorLimits', [log(.1), log(100)], 'FontSize', 12);

% heatmap with bi-directional cluster and dendrogram
% CG = clustergram(mySortedData, 'RowLabels',colLabels, 'ColumnLabels',rowLabels ...
%     , 'Standardize','none', 'Cluster','all', 'Colormap',Cmap ...
%     , 'LogTrans', 1);
% cgAxes = plot(CG);
% set(gcf, 'position', [360 50 569 655])
% % 'LogTrans' transform the data from natural scale to log2 scale
% set(cgAxes, 'Clim', [log2(.1), log2(100)], 'FontSize', 12)


%% plot a dendrogram tree to view the dissimilarity between the perturbations

% mySortedData is Strains * Perturbations, since we'd like to know which
% clusters of perturbations have similar effect to the system, so we need
% to first transpose the matrix, and then calculate the pairwise distance
% of each two perturbations using default metric - Euclidean distance
distList = pdist(mySortedData');

% the 1st and 2nd column of the linkaged matrix contains the cluster indices
% linked in pairs to form a binary tree, while the 3rd column contains the
% linkage distances between the two clusters merged in the same row
tree = linkage(distList);

% dendrogram is a way to visualize the linkage tree, while the x tick
% labels are the original indices of the objects, the height of the
% U-shaped lines indicates the distance between the objects
figure
set(gcf,'position',[680 511 950 467])
H = dendrogram(tree);
for i=1:numel(H)
    H(i).LineWidth = 1.5;
end

perturbID = str2num(get(gca,'XTickLabels'));
set(gca, 'XTickLabels', param_names(perturbID))
set(gca, 'XTickLabelRotation', 45, 'FontSize', 13)


%% heatmap, cluster & dendrogram for multiple strains data

% load obj results from each file, then store them all in 'obj_all'
clear
obj_all = struct;
tmp = dir('../multiStrainFromKayla/');
for i=3:length(tmp)
    if ~ strcmp(tmp(i).name, '.DS_Store')
        load(fullfile('../multiStrainFromKayla/', tmp(i).name))
        str = fieldnames(obj);
        str = str{1};
        no = str(4:end);
        no = str2num(no)-2;
        fdn = sprintf('str%02d',no);
        obj_all.(fdn) = obj.(str);
    end
end

% store all the strain names into a cell array
clear strNames
nStr = numel(fieldnames(obj_all));
strNames = cell(nStr,1);

for i=3:length(allTraits)
    if ~ strcmp(allTraits(i).name, '.DS_Store')
        tmp = allTraits(i).name;
        strNames{i-2} = tmp(1:end-4);
    end
end

% organize the data
nPerturb = size(obj_all.str01,1);
mydata = nan(nStr,nPerturb);
for iStr = 1:nStr
    fdn = num2str(sprintf('str%02d',iStr));
    for iPerturb = 1:nPerturb
        mydata(iStr,iPerturb) = min(obj_all.(fdn)(iPerturb,:));
    end
end

% hard-coded the list of picked strains
load('../wildtype_96well-025-170925_16:18.mat')
param_names = parameter_update.parameter_name;
rowLabels = param_names;

pickedStrains = strNames([1,2,4:6,8,10:13,16,19,20,22,23,26,27,29,31:34],:);

[~,ind] = ismember(pickedStrains, strNames);
myPickedData = mydata(ind,:);
colLabels = pickedStrains;

% make heatmap
Cmap = flipud(parula);
Climits = [min(myPickedData(:)), max(myPickedData(:))];
% Z_Climits = [min(zscore(myPickedData(:))), max(zscore(myPickedData(:)))];

% heatmap without cluster or dendrogram tree
figure
set(gcf, 'position', [218 129 780 496])
heatmap(rowLabels, colLabels, myPickedData, 'Colormap', Cmap ...
    , 'ColorLimits', Climits, 'FontSize', 12);

% heatmap with bi-directional cluster and dendrogram
CG = clustergram(myPickedData, 'RowLabels',colLabels, 'ColumnLabels',rowLabels ...
    , 'Standardize','none', 'Cluster','all', 'Colormap',Cmap);
cgAxes = plot(CG);
set(gcf, 'position', [397 99 810 552])
set(cgAxes, 'Clim', Climits, 'FontSize', 12)

