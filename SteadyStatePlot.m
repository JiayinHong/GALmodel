%% load GAL3, GAL4 level
load('../metaData/trait_extraction/GAL3pr_all_data.mat')
G3level = trait.basal_level;
load('../metaData/trait_extraction/GAL4pr_all_data.mat')
G4level = trait.basal_level;

%% load parameter, trait, and fit type
i_example = 36;
jobtag = mcmc_result{i_example, 'jobtag'};
param = mcmc_result{i_example, 'param_map'};
load(mcmc_result{i_example,'filepath'}{1},'GAL1_trait')  % load trait
fit_type = 'one_column';

%% plot for 11 species excluding R*
if 0
clear lo_state hi_state Mig1star
figure
set(gcf, 'position', [298 107 1182 856])
markersize = 10;
fontsize = 12;

subplot(4,5,1)
% show how GAL1 level fits, also get steady state concentrations for 11
% species
[lo_state(:,:), hi_state(:,:)] = param_fitting_plot(param, GAL1_trait, fit_type);
subplot(4,5,6)
% show how GAL3 level fits
param_fitting_plot_GAL234(param, GAL1_trait, 0, G3level, G4level, fit_type, 'G3');
subplot(4,5,11)
% show how GAL4 level fits
param_fitting_plot_GAL234(param, GAL1_trait, 0, G3level, G4level, fit_type, 'G4');

% show the steady state concentrations for 11 species and free+complex
species_list = {'G1', 'G2', 'G3', 'G4', 'G80', 'G3*', 'Mig1tot', 'C83', 'C84', 'glu', 'gal'};
n_species = length(species_list);
switch fit_type
    case 'one_row'
        n_condition = 12;
    case 'one_column'
        n_condition = 8;
    case 'one_cross'
        n_condition = 19;
end

subplot(4,5,2)
plot(1:n_condition, hi_state(:,1), '.', 'markersize', markersize)
xlim([0 n_condition+1])
set(gca, 'yscale', 'log')
title('G1', 'FontSize', fontsize)
grid on

ax9 = subplot(4,5,9);   % return the axis object of subplot(4,5,9),
                        % the one of species 'Mig1tot'

for i_species = 2:n_species
    if i_species > 8
        subplot(4, 5, i_species+3)
    elseif i_species > 4
        subplot(4, 5, i_species+2)
    else
        subplot(4, 5, i_species+1)
    end
    
    plot(1:n_condition, hi_state(:,i_species), '.', 'markersize', markersize)
    
    xlim([0 n_condition+1])
    %     set(gca, 'yscale', 'log')
    set(gca, 'FontSize', fontsize)
    title(species_list{i_species}, 'FontSize', fontsize)
    grid on
end

% ytickformat(ax9,'%.0f')     % specify the tick label format of 'Mig1tot'

% in matlab R2016a, the code above is not functional, use code below
shortTickLabel = cellfun(@(s) sprintf('%.6s',s), ax9.YTickLabel, 'UniformOutput',false);
ax9.YTickLabel = shortTickLabel;

% plot Mig1* level
subplot(4,5,15)
Mig1tot = hi_state(:,7);
glu_in = hi_state(:,10);
if range(Mig1tot) == 0  % steady state level = aR/gamma, no matter what condition
    Mig1star = glu_in .^ param.nRs ./ (param.KRs^param.nRs + glu_in .^ param.nRs) .* Mig1tot(1);
else
    error('There''s something wrong!')
end
plot(1:n_condition, Mig1star, '.', 'markersize', markersize)
xlim([0 n_condition+1])
set(gca, 'FontSize', fontsize)
title('Mig1*', 'FontSize', fontsize)
grid on

% plot free+complex steady state

subplot(4,5,17) % G3+G3*+C83

plot(1:n_condition, (hi_state(:,3) + hi_state(:,6) + hi_state(:,8)), '.', 'markersize', markersize)
xlim([0 n_condition+1])
set(gca, 'FontSize', fontsize)
title('G3+G3*+C83', 'FontSize', fontsize)
grid on

subplot(4,5,18) % G80+C83+C84

plot(1:n_condition, (hi_state(:,5) + hi_state(:,8) + hi_state(:,9)), '.', 'markersize', markersize)
xlim([0 n_condition+1])
set(gca, 'FontSize', fontsize)
title('G80+C83+C84', 'FontSize', fontsize)
grid on

subplot(4,5,19) % G4+C84

plot(1:n_condition, (hi_state(:,4) + hi_state(:,9)), '.', 'markersize', markersize)
% ytickformat('%.2f')     % specify the tick label format of 'G4+C84'
xlim([0 n_condition+1])
set(gca, 'FontSize', fontsize)
title('G4+C84', 'FontSize', fontsize)
grid on

jobtag = changeunderscore(jobtag{1});
[ax,h] = suplabel(sprintf('The no.%s example, %s', num2str(i_example), jobtag), 't');
h.FontSize = 13;
end
%% plot for 12 species including R*
clear lo_state hi_state
figure
set(gcf, 'position', [298 107 1182 856])
markersize = 10;
fontsize = 12;

subplot(4,5,1)
% show how GAL1 level fits, also get steady state concentrations for 12
% species
[lo_state(:,:), hi_state(:,:)] = param_fitting_plot(param, GAL1_trait, fit_type);
subplot(4,5,6)
% show how GAL3 level fits
param_fitting_plot_GAL234(param, GAL1_trait, 0, G3level, G4level, fit_type, 'G3');
subplot(4,5,11)
% show how GAL4 level fits
param_fitting_plot_GAL234(param, GAL1_trait, 0, G3level, G4level, fit_type, 'G4');

% show the steady state concentrations for 12 species and free+complex
species_list = {'G1', 'G2', 'G3', 'G4', 'G80', 'G3*', 'Mig1', 'Mig1*', 'C83', 'C84', 'glu', 'gal'};
n_species = length(species_list);
switch fit_type
    case 'one_row'
        n_condition = 12;
    case 'one_column'
        n_condition = 8;
    case 'one_cross'
        n_condition = 19;
end


for i_species = 1:n_species
    if i_species > 8
        subplot(4, 5, i_species+3)
    elseif i_species > 4
        subplot(4, 5, i_species+2)
    else
        subplot(4, 5, i_species+1)
    end
    
    plot(1:n_condition, hi_state(:,i_species), '.', 'markersize', markersize)
    
    xlim([0 n_condition+1])
    %     set(gca, 'yscale', 'log')
    set(gca, 'FontSize', fontsize)
    title(species_list{i_species}, 'FontSize', fontsize)
    grid on
end

% plot free+complex steady state

subplot(4,5,17) % G3+G3*+C83

plot(1:n_condition, (hi_state(:,3) + hi_state(:,6) + hi_state(:,9)), '.', 'markersize', markersize)
xlim([0 n_condition+1])
set(gca, 'FontSize', fontsize)
title('G3+G3*+C83', 'FontSize', fontsize)
grid on

subplot(4,5,18) % G80+C83+C84

plot(1:n_condition, (hi_state(:,5) + hi_state(:,9) + hi_state(:,10)), '.', 'markersize', markersize)
xlim([0 n_condition+1])
set(gca, 'FontSize', fontsize)
title('G80+C83+C84', 'FontSize', fontsize)
grid on

subplot(4,5,19) % G4+C84

plot(1:n_condition, (hi_state(:,4) + hi_state(:,10)), '.', 'markersize', markersize)
xlim([0 n_condition+1])
set(gca, 'FontSize', fontsize)
title('G4+C84', 'FontSize', fontsize)
grid on

ax20 = subplot(4,5,20); % R+R*

plot(1:n_condition, (hi_state(:,7) + hi_state(:,8)), '.', 'markersize', markersize)
xlim([0 n_condition+1])
set(gca, 'FontSize', fontsize)
title('Mig1+Mig1*', 'FontSize', fontsize)
grid on

shortTickLabel = cellfun(@(s) sprintf('%.6s',s), ax20.YTickLabel, 'UniformOutput',false);
ax20.YTickLabel = shortTickLabel;
