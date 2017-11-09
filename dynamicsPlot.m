%% load mcmc results
if 1
    mcmc_data_folder = '../results/fitGAL134-MediumStepSize/';
    jobtags = {'medium-wildtype_1c', 'medium-wildtype_1r', 'medium-wildtype_1r1c'};
%     jobtags = {'wildtype_96well', 'gal80d_96well', 'mig1d_96well'};
    mcmc_result = load_mcmc_result(mcmc_data_folder, jobtags);
%     mcmc_result = sortrows(mcmc_result, 'map_data_over_param', 'descend');
end

%% choose one example and load parameters
i_example = 54;
param = mcmc_result{i_example, 'param_map'};
jobtag = mcmc_result{i_example, 'jobtag'};
load(mcmc_result{i_example,'filepath'}{1},'GAL1_trait')  % load trait

%% choose one sugar condition, simulate the dynamics and plot
i_condition = 72;   % linear indexing

gluc_condition = GAL1_trait{i_condition,'gluc'};
galc_condition = GAL1_trait{i_condition,'galc'};
output = getInitParamsGalPathway(param);
init_val = output.y0_Gal;   % the high level fraction

load_global;
opt = odeset('NonNegative',1:11);
accurate_thresh = 10^-8;

param.exglu = gluc_condition * perc_to_nm;
param.exgal = galc_condition * perc_to_nm;
odefunc = @(t,y)GALode7(t,y,param);
curInitVal = init_val;

if param.exglu == 0
    % R*=0, glu=0
    tmp = [ones(1,9),0,1];
    curInitVal = curInitVal .* tmp;
end
if param.exgal == 0
    % Gal3*=0, C83=0, gal=0
    tmp = [ones(1,5),0,1,0,1,1,0];
    curInitVal = curInitVal .* tmp;
end
if param.aR == 0
    % Repressor=0, R*=0
    tmp = [ones(1,6),0,ones(1,4)];
    curInitVal = curInitVal .* tmp;
end
if param.a80 == 0 && param.ag80 == 0
    % Gal80=0, C83=0, C84=0
    tmp = [ones(1,4),0,ones(1,2),0,0,1,1];
    curInitVal = curInitVal .* tmp;
end

[t, y_current] = ode15s(odefunc, [0 10000], curInitVal, opt);
y_current(y_current<accurate_thresh) = 0;   % omit values that are too small

autofluorescence = get_auto_fluorescence(GAL1_trait);
y_current(:,1) = y_current(:,1)+autofluorescence;

%% plot 11 species
species_list = {'G1', 'G2', 'G3', 'G4', 'G80', 'G3*', 'Mig1tot', 'C83', 'C84', 'glu', 'gal'};
figure
set(gcf,'position',[144 138 1353 804])

fontsize = 12;
ax7 = subplot(4,4,7);   % return the axis object of subplot(4,4,7),
% the one of species 'Mig1tot'

for i_species = 1:length(species_list)
    subplot(4,4,i_species)
    plot(t,y_current(:,i_species),'LineWidth',1.5)
    set(gca, 'FontSize', fontsize)
    title(species_list{i_species})
    grid on
end

shortTickLabel = cellfun(@(s) sprintf('%.6s',s), ax7.YTickLabel, 'UniformOutput',false);
ax7.YTickLabel = shortTickLabel;

% plot Mig1* level
subplot(4,4,12)
Mig1tot = y_current(:,7);
glu_in = y_current(:,10);
if range(Mig1tot) < 1e-7
    Mig1star = glu_in .^ param.nRs ./ (param.KRs^param.nRs + glu_in .^ param.nRs) .* Mig1tot(1);
else
    error('There''s something wrong with Mig1 level!')
end

plot(t,Mig1star,'LineWidth',1.5)
set(gca, 'FontSize', fontsize)
title('Mig1*', 'FontSize', fontsize)
grid on

% plot free+complex steady state
subplot(4,4,13) % G3+G3*+C83
plot(t, (y_current(:,3) + y_current(:,6) + y_current(:,8)), 'LineWidth', 1.5)
set(gca, 'FontSize', fontsize)
title('G3+G3*+C83', 'FontSize', fontsize)
grid on

subplot(4,4,14) % G80+C83+C84
plot(t, (y_current(:,5) + y_current(:,8) + y_current(:,9)), 'LineWidth', 1.5)
set(gca, 'FontSize', fontsize)
title('G80+C83+C84', 'FontSize', fontsize)
grid on

subplot(4,4,15) % G4+C84
plot(t, (y_current(:,4) + y_current(:,9)), 'LineWidth', 1.5)
ytickformat('%.2f')     % specify the tick label format of 'G4+C84'
set(gca, 'FontSize', fontsize)
title('G4+C84', 'FontSize', fontsize)
grid on

subplot(4,4,16)     % galactose+G3*
plot(t, (y_current(:,11) + y_current(:,6)), 'LineWidth', 1.5)
set(gca, 'FontSize', fontsize)
title('gal+G3*', 'FontSize', fontsize)
grid on

jobtag = changeunderscore(jobtag{1});
[ax,h] = suplabel(sprintf('The no.%s example, %s, no.%s well', num2str(i_example), jobtag, num2str(i_condition)), 't');
h.FontSize = 13;

