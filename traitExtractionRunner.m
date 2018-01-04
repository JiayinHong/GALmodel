% this script is used to visualize and format the strain data

%% Load data
load('segmented data all.mat');
strainData = sortrows(strainData, 'name', 'ascend');

%% visualize the data using histogram and check the modality by eye
allStr = unique(strainData.name);
for istr = 1:length(allStr)
    strName = allStr{istr};
    irows = find(strcmp(strainData.name, strName));
    nrep = length(irows);   % how many replicates
    for irep = 1:nrep
%         data = strainData(irows(irep),:).query{1,1};
        data = strainData(irows(irep),:).ref{1,1};
        emptyCells = cellfun(@isempty,data);    % pick out the empty cells
        if min(emptyCells(:))==0    % there is at least one well that contains data
            
            % extract a trait table for later use
            strainName = [strName, '-rep', num2str(irep)];
            traitExtraction(data, strainName)
            
            figure
            set(gcf,'position', [-1754 -196 1625 876])
            for r = 8:-1:1      % flip glucose titration
                for c = 1:12
                    subplot(8,12,(8-r)*12+c)
                    hist(log(data{r,c}.yfp),[0.05:0.1:9.95])
                    if r~=1     % only display XTickLabel on the lowest row
                        set(gca,'XTickLabel',[])
                    end
                    set(gca,'FontSize',12)
                end
            end
            [~,h]=suplabel(['Strain ', strName,' - rep',num2str(irep)],'t');
            set(h,'FontSize',20)
            export_fig(fullfile('../BC187Hist/', ['Strain ', strName,' - rep',num2str(irep)]))
            
        elseif min(emptyCells(:))==1    % all 96 wells are void
            % do nothing
        end
        
    end
end


%%
figure
set(gcf,'position', [-1754 -196 1625 876])
for r = 8:-1:1      % flip glucose titration
    for c = 1:12
        subplot(8,12,(8-r)*12+c)
        hist(log(data{r,c}.yfp),[0.05:0.1:9.95])
        if r~=1     % only display XTickLabel on the lowest row
            set(gca,'XTickLabel',[])
        end
        set(gca,'FontSize',10)
    end
end

