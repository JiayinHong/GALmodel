%% load mcmc results
mcmc_data_folder = '../results/singleTrans-96well/';
jobtags = {'wildtype_96well', 'gal80d_96well', 'mig1d_96well'};
mcmc_result = load_mcmc_result(mcmc_data_folder, jobtags);
mcmc_result = sortrows(mcmc_result, 'map_data_over_param', 'descend');
mcmc_result_filter = mcmc_result(mcmc_result.map_data_over_param > -86,:);

%% fetch parameter values - only MAP
param_val_all = [];
param_id_all = [];

for i_job = 1:length(jobtags)
    
    mcmc_result_tmp = mcmc_result_filter(ismember(mcmc_result_filter.jobtag, jobtags{i_job}),:);
    load(mcmc_result_tmp{1, 'filepath'}{1}, 'parameter_update');
    
    parameter_update_names = parameter_update.parameter_name;
    n_sample = height(mcmc_result_tmp);
    n_param_update = height(parameter_update);
    param_map_val = nan(n_sample, n_param_update);
    
    for i_sample = 1:n_sample
        param_map = mcmc_result_tmp{i_sample, 'param_map'};
        for i_param_update = 1:n_param_update
            param_map_val(i_sample, i_param_update) = log10(param_map.(parameter_update_names{i_param_update}));
        end
    end
    
    param_map_id = repmat(i_job,[n_sample,1]);
    param_val_all = [param_val_all; param_map_val];
    param_id_all = [param_id_all; param_map_id];
end

%% fetch parameter values - posterior distribution beyond a threshold
param_val_all = [];
param_id_all = [];
load(mcmc_result_filter{1, 'filepath'}{1}, 'parameter_update');
parameter_update_names = parameter_update.parameter_name;
n_param_update = height(parameter_update);

for i_job = 1:length(jobtags)
    
    mcmc_result_tmp = mcmc_result_filter(ismember(mcmc_result_filter.jobtag, jobtags{i_job}),:);
    n_chain = height(mcmc_result_tmp);
    
    for i_chain = 1:n_chain
        prob_list = mcmc_result_tmp{i_chain, 'prob_data_over_parameter_list'}{1};
        param_list = mcmc_result_tmp{i_chain, 'param_list'};
        filter_id = find(prob_list > -86);
        [~,I] = max(prob_list);
        II = find(I==filter_id);
        param_chain = nan(length(filter_id), n_param_update);
        
        for i_param_update = 1:n_param_update
            tmp = param_list.(parameter_update_names{i_param_update});
            param_chain(:, i_param_update) = log10(tmp(filter_id));
        end
        param_val_all =  [param_val_all; param_chain];
        param_chain_id = repmat(i_job, [length(filter_id),1]);
        param_chain_id(II) = 666;   % the ID of MAP
        param_id_all = [param_id_all; param_chain_id];
    end
    
    
end


%% PCA and plot
[coeff, score, latent] = pca(zscore(param_val_all));

fontsize = 12;
markersize = 15;

figure
plot([latent(1:10)/sum(latent) cumsum(latent(1:10))/sum(latent)]*100, 'LineWidth', 1.5);
set(gca,'FontSize', fontsize, 'FontWeight', 'bold')
xlabel('# of principal component');
ylabel('% of variance of dataset explained');
grid on
h=legend('Individual', 'Cumulative');
h.FontSize = fontsize;
h.FontWeight = 'bold';
h.Location = 'NorthWest';

% 3d PCA
cluster_names = {'wt', 'gal80d', 'mig1d'};
figure
set(gcf,'position',[945 424 762 502])
for i_job = 1:length(jobtags)
    scatter3(score(param_id_all==i_job,1),score(param_id_all==i_job,2),score(param_id_all==i_job,3));
    hold on
%     text(mean(score(param_id_all == i_job,1)), mean(score(param_id_all==i_job,2)), mean(score(param_id_all == i_job,3)), cluster_names{i_job}, 'color', 'k', 'fontsize', 15, 'fontweight', 'bold');
    
end
set(gca,'FontSize', fontsize, 'FontWeight', 'bold')

xlabel('1st PC')
ylabel('2nd PC')
zlabel('3rd PC')
legend(cluster_names, 'FontSize', fontsize, 'FontWeight', 'bold')
grid on
box on

%% 2d PCA highlight MAP
figure
set(gcf,'position',[484 152 1223 774])

subplot(2,2,1)
plot(score(:,1),score(:,2),'.','color',[0.7 0.7 0.7]);
hold on
plot(score(param_id_all==666,1),score(param_id_all==666,2),'d','MarkerFaceColor','red','markersize',6);
title('PC1 vs PC2', 'fontsize', 12)
legend({'non-MAP','MAP'}, 'FontSize', fontsize, 'FontWeight', 'bold', 'location', 'best')
grid on
set(gca,'fontsize',12)

subplot(2,2,2)
plot(score(:,1),score(:,3),'.','color',[0.7 0.7 0.7]);
hold on
plot(score(param_id_all==666,1),score(param_id_all==666,3),'d','MarkerFaceColor','red','markersize',6);
title('PC1 vs PC3', 'fontsize', 12)
legend({'non-MAP','MAP'}, 'FontSize', fontsize, 'FontWeight', 'bold', 'location', 'best')
grid on
set(gca,'fontsize',12)

subplot(2,2,3)
plot(score(:,2),score(:,3),'.','color',[0.7 0.7 0.7]);
hold on
plot(score(param_id_all==666,2),score(param_id_all==666,3),'d','MarkerFaceColor','red','markersize',6);
title('PC2 vs PC3', 'fontsize', 12)
legend({'non-MAP','MAP'}, 'FontSize', fontsize, 'FontWeight', 'bold', 'location', 'best')
grid on
set(gca,'fontsize',12)

% set(gca,'FontSize', fontsize, 'FontWeight', 'bold')

%% 2d PCA show density
pairscatter(score(:,1:3),[],[],'showDensity',true)
set(gcf, 'position', [360 130 780 568])

%% 2d PCA show cluster
figure
set(gcf,'position',[360 130 780 568])
for i_job = 1:length(jobtags)
    subplot(2,2,1)
    scatter(score(param_id_all==i_job,1),score(param_id_all==i_job,2))
    title('PC1 vs PC2', 'fontsize', 12)
    set(gca,'fontsize',12)
    hold on
    
    subplot(2,2,2)
    scatter(score(param_id_all==i_job,1),score(param_id_all==i_job,3))
    title('PC1 vs PC3', 'fontsize', 12)
    set(gca,'fontsize',12)
    hold on
    
    subplot(2,2,3)
    scatter(score(param_id_all==i_job,2),score(param_id_all==i_job,3))
    title('PC2 vs PC3', 'fontsize', 12)
    set(gca,'fontsize',12)
    hold on
end
    

% View the data and the original variables (parameters that varied during MCMC) 
% in the space of the first three principal components
% vbls = {'a80', 'ag80'};
% locb_all = [];
% for vbl = vbls
%     [~,locb] = ismember(vbl, parameter_update_names);
%     locb_all = [locb_all;locb];
% end
% 
% biplot(coeff(locb_all,1:2), 'scores', score(locb_all,1:2), 'varlabels', vbls)



