function pairscatter(X,label,grp,varargin)
% Pairwise Scatter of Columns of Matrix
% This is similar to plotmatrix except that it only plots each pair of
% variables once, eliminates the histograms on the diagonals and enables
% the user to also specify labeling for each axes. In addition, one can use
% scatplot to display pairwise scatter as a density heatmap. 
%
% pairscatter(X, label, grp)
%    Draws a pairwise scatter of the columns of X. label is an optional
%    cell array of labels, one for each column of X. grp is an optional
%    grouping variable similar to that used in gscatter
%
% pairscatter(X, label, grp, 'plotArgs', {'name',value,...})
%    specifies a list of parameter-value pairs to be passed on to the
%    plotting routine to customize the look of the markers in the scatter
%    plot. Default = {'marker', '.', 'markersize', 3}
%
% pairscatter(X, label, grp, 'showDensity', true) 
%    colors the markers drawn with density information for that region. Use
%    this if there are too many markers drawn on the screen to sufficiently
%    discern individual points. This option is much slower than the
%    standard scatter plot and requires the function scatplot.m

% Copyright 2014 MathWorks, Inc.
figure
param = parsePVPairs({'plotArgs','showDensity'}, {{},false}, {@iscell, @islogical}, varargin); 

param.plotArgs = parsePVPairs({'marker','markersize','linestyle'}, {'o', 2,'none'}, [], param.plotArgs, 'keepUnmatched', true, 'pvOutput', true);


m = size(X,2);
nCharts = nchoosek(m,2);
nCol = ceil(sqrt(nCharts));
nRow = ceil(nCharts/nCol);
ctr = 0;

if nargin < 2 || isempty(label), label = 1:m; end
if nargin < 3 || isempty(grp), grp = []; end
    
if isnumeric(label)
    label = cellfun(@num2str,num2cell(label),'uniformoutput',false);
end
args = {};
if nRow > 5 || nCol > 5
    args = {'xtickmode','manual','ytickmode','manual','xtick',[],'ytick',[]};
end
for i = 1:m
    for j = i+1:m
        ctr = ctr + 1;
        ax(ctr) = subplot(nRow,nCol,ctr,'fontsize',12,args{:});
        if param.showDensity
            scatplot(X(:,i), X(:,j), [], [], [], [], 1, 2); 
        else
            if isempty(grp)
                plot(X(:,i), X(:,j), param.plotArgs{:});
            else
                h = gscatter(X(:,i), X(:,j), grp);
                legend location best
                set(h,param.plotArgs{:})
            end
        end
        axis(ax(ctr),'tight');
        %xlabel(ax(ctr),label{i});
        %ylabel(ax(ctr),label{j});
        title(sprintf('PC%s vs PC%s',label{i},label{j}));
        drawnow
    end
end
