function traitExtraction(cellData, strainName)
%   this function is used to clear and format the pre-processed FACS data,
%   to generate a trait table for later use
%   created by JH, 2017.10.17
%   the input data should be formatted as 8*12 cell, each contains a struct
%   with 'yfp', 'bfp', 'ssc', 'fsc' etc fields. Specifically, in Kayla's
%   strainData, before proceeding processing, first invert glucose
%   titration (the rows).

% initialization of variables
nrow = size(cellData,1);
ncol = size(cellData,2);

basal_level = nan(nrow,ncol);
ind_level = nan(nrow,ncol);
basal_frac = nan(nrow,ncol);
ind_frac = nan(nrow,ncol);
mask_basal = 0.5 .* ones(nrow,ncol);
mask_induction = 0.5 .* ones(nrow,ncol);

% setup the sugar titration gradient
if size(cellData)==[7,12]   % Renan's data
    gluc_gradient = [2 .^ [0:-1:-6]]';
else
    gluc_gradient = [2 .^ [0:-1:-6], 0]';
end
galc_gradient = [0, 2 .^ [-8:1:2]];
gluc = gluc_gradient * ones(1,12);
galc = ones(nrow,1) * galc_gradient;

% pre-determine the bin edge and bin size
[hist_bin_edge, hist_bin_center] = GetHistBin(0.05, 9.95, 0.1);

% process and format the trait table
myData = flip(cellData);    % invert glucose titration
if isnan(myData{1,1}.yfp)   % in case the value in the top left well is NaN
    refWell = myData{2,1}.yfp;
else
    refWell = myData{1,1}.yfp;  % usually the top left well is fully OFF
end
logRef = log(refWell);      % I use natural logarithm in all my trait extraction
countsTotalRef = numel(refWell);    % the total counts of ref data
countsListRef = histcounts(logRef, hist_bin_edge);  % get the list of counts in each bin
normalizedCountsRef = countsListRef ./ countsTotalRef;
thresh = median(logRef);    % ignore if there are more counts of query than ref data beneath the threshold

for row = 1:nrow
    for col = 1:ncol
        if ~isfield(myData{row,col},'yfp')
            % do nothing, since already put NaN as place-holder
            mask_basal(row,col) = 0;
            mask_induction(row,col) = 0;
            
        elseif ~isnan(myData{row,col}.yfp)      % there is data in the current query well
            queryData = myData{row,col}.yfp;    % the current query well
            logQuery = log(queryData);  % natural logarithm, again
            countsTotalQuery = numel(queryData);    % the total counts of query data
            countsListQuery = histcounts(logQuery, hist_bin_edge);
            normalizedCountsQuery = countsListQuery ./ countsTotalQuery;
            
            deltaFreq = normalizedCountsQuery - normalizedCountsRef;
            % the difference between query and fully OFF, regarded as the ON fraction of query data
            weightONpeak = deltaFreq;   % the weight of ON peak in each bin
            weightONpeak(weightONpeak < 0) = 0;
            weightONpeak(weightONpeak > 0 & ...
                [1:length(weightONpeak)] <= ceil(thresh/0.1)) = 0;  % 0.1 is the bin size
            
            ind_frac(row,col) = sum(weightONpeak);
            ind_level(row,col) = sum(hist_bin_center .* weightONpeak) / sum(weightONpeak);
            basal_frac(row,col) = 1-ind_frac(row,col);
            weightOFFpeak = normalizedCountsQuery - weightONpeak;
            basal_level(row,col) = sum(hist_bin_center .* weightOFFpeak) / sum(weightOFFpeak);
            
        else     % for the missing well
            % do nothing, since already put NaN as place-holder
            mask_basal(row,col) = 0;
            mask_induction(row,col) = 0;
        end
    end
end

minModeWeight = min(basal_frac(nrow,ncol),0.1);
% the lower right well should be fully ON, where basal_frac
% should be zero, so any fraction smaller than that could be due to
% detection limit, however, funny data do exist, and I think a
% fraction greater than 0.1 should be considered as another
% mode
id1 = find(basal_frac <= minModeWeight);
mask_basal(id1) = 0;
mask_induction(id1) = 1;
id2 = find(ind_frac <= minModeWeight);
mask_induction(id2) = 0;
mask_basal(id2) = 1;

% cells cultured in severe nutrient conditions
if nrow==8
    mask_basal(8,1:4) = 0;
    mask_induction(8,1:4) = 0;
end

trait = table(basal_level(:), ind_level(:), basal_frac(:), ind_frac(:) ...
    , mask_basal(:), mask_induction(:), gluc(:), galc(:) ...
    , 'VariableNames', {'basal_level', 'ind_level', 'basal_frac', 'ind_frac' ...
    , 'mask_basal', 'mask_induction', 'gluc', 'galc'});
save(fullfile('../traitExtraction/', [strainName, '.mat']), 'trait')

end

