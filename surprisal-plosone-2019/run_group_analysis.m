%% Alice EEG: Group Analysis PLoS ONE Surprisals paper
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTANT NOTE
% The single-subject control regressions in the statistical analysis have 
% a random component and the seed from the original analysis was not saved. 
% Accordingly, statistical tests (e.g. timing and topography of effects) 
% may quantitatively differ from the published results.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('path/to/fieldtrip/toolbox'); % https://github.com/fieldtrip/fieldtrip
ft_defaults

addpath('../helpers/') % add helper scripts

load datasets.mat % 

% Directory for pre-processed data
data_dir   = 'path/to/preprocessed/data';

% Directory for regression results
betas_dir = 'path/to/single/subject/regression/results';

% Directory for statistical output
stats_dir = 'path/to/save/group/statistics/results';

%% Load single-subject regression coefficients (N=33)

betas = dir([betas_dir '/*_betas.mat']);
betas = {betas(:).name};

% make sure we have just the high-performing participants
check_datasets = extractBetween(betas, 1, 3);
high_perf      = extractBetween(use, 1, 3);
keeps          = ismember(check_datasets, high_perf);

betas = betas(keeps);

betas_l = {}; 
betas_f = {};
conbetas_l = {}; 
conbetas_f = {};

% load beta values
for i = 1:length(betas)
    load([betas_dir '/' betas{i}]);
    betas_l{i}    = flip_betas(dat_l_b); 
    betas_f{i}    = flip_betas(dat_f_b);
    conbetas_l{i} = flip_betas(dat_l_cb); 
    conbetas_f{i} = flip_betas(dat_f_cb);
end

% compute layout and neighbors for cluster stats
cfg        = [];
cfg.layout = 'easycapM10-acti61_elec.sfp';
cfg.center = 'yes';
lay        = ft_prepare_layout(cfg);

cfg        = []; 
cfg.method = 'triangulation'; 
cfg.layout = lay;
nb = ft_prepare_neighbours(cfg);

%% CONTENT WORD FREQUENCY (Fig 3A)

stat_frq_l = do_beta_stats(betas_l, conbetas_l, 'beta_frq', 10000);
min(stat_frq_l.prob(:)) %
[sigtimes sigchans sigchanprop, polarity pvals] = get_sig_clusters2(stat_frq_l)
   sigtimes{1} %
   plot_stat_multiplot(stat_frq_l);
   print('figs/freq_lex_multiplot', '-dpng', '-r0');
   plot_group_betas(betas_l, 'beta_frq', sigchans{1}, sigtimes{1}, sigchanprop{1}, '\beta, \muV/count');
   print('figs/freq_lex_betaplot', '-dpng', '-r300');
    % expect central positivity ~ 300-400 ms 

%% CONTENT: NGRAM

stat_ngram_l = do_beta_stats(betas_l, conbetas_l, 'beta_ngram', 10000);
min(stat_ngram_l.prob(:)) % expect n.s.

%% CONTENT: RNN

stat_rnn_l = do_beta_stats(betas_l, conbetas_l, 'beta_rnn', 10000);
min(stat_rnn_l.prob(:)) % expect n.s.

%% CONTENT: CFG (Fig 3C)

stat_cfg_l = do_beta_stats(betas_l, conbetas_l, 'beta_cfgp', 10000);
min(stat_cfg_l.prob(:)) % 
[sigtimes sigchans sigchansprop polarity pvals] = get_sig_clusters2(stat_cfg_l)   
    sigtimes{1} % 
    plot_stat_multiplot(stat_cfg_l);
    print('figs/cfg_lex_multiplot', '-dpng', '-r0');
    plot_group_betas(betas_l, 'beta_cfgp', sigchans{1}, sigtimes{1}, sigchansprop{1}, '\beta, \muV/bit');
    print('figs/cfg_lex_betaplot1', '-dpng', '-r300');
    % expect frontal negativity ~ 200-400 ms


%% FUNCTION: NGRAM (Fig 3E)
% NOTE about replication: 
% Whether both of the originally reported effects cross the the p < 0.05 
% threshold appears to be variable across alternative shufflings of the 
% control regressions

stat_ngram_f = do_beta_stats(betas_f, conbetas_f, 'beta_ngram', 10000);
min(stat_ngram_f.prob(:)) % 
[sigtimes sigchans sigchansprop polarity pvals] = get_sig_clusters2(stat_ngram_f)   
    plot_stat_multiplot(stat_ngram_f);
    print('figs/ngram_func_multiplot', '-dpng', '-r0');
    sigtimes{1} %
    plot_group_betas(betas_f, 'beta_ngram', sigchans{1}, sigtimes{1}, sigchansprop{1}, '\beta, \muV/bit');
    print('figs/ngram_func_betaplot1', '-dpng', '-r300');
    %  expect right frontal positivity ~ 200-400 ms
    sigtimes{2} %
    plot_group_betas(betas_f, 'beta_ngram', sigchans{2}, sigtimes{2}, sigchansprop{2}, '\beta, \muV/bit');
    print('figs/ngram_func_betaplot2', '-dpng', '-r300');
    %  expect medio-frontal positivity ~ 100-150 ms
    
%% FUNCTION: RNN (Supplemental Figures)
% NOTE about replication: 
% whether this effect crosses the p < 0.05 threshold appears
% to be variable across alternative shufflings of the control regressions

stat_rnn_f = do_beta_stats(betas_f, conbetas_f, 'beta_rnn', 10000);
min(stat_rnn_f.prob(:)) % p = 0.0130
    [sigtimes sigchans sigchansprop polarity pvals] = get_sig_clusters2(stat_rnn_f)   
    sigtimes{1} % (1) 174-252 ms positivity
    plot_stat_multiplot(stat_rnn_f);
    print('figs/rnn_func_multiplot', '-dpng', '-r0');
    plot_group_betas(betas_f, 'beta_rnn', sigchans{1}, sigtimes{1}, sigchansprop{1}, '\beta, \muV/bit');
    print('figs/rnn_func_betaplot', '-dpng', '-r300');
    % expect right frontal positivity ~150 - 250 ms 
    % (resembles ngram)

%% FUNCTION: CFG (Supplemental Figures)
% NOTE about replication: 
% Whether this effect crosses the p < 0.05 threshold appears
% to be variable across alternative shufflings of the control regressions

stat_cfg_f = do_beta_stats(betas_f, conbetas_f, 'beta_cfgp', 10000);
min(stat_cfg_f.prob(:)) % 
    [sigtimes sigchans sigchansprop polarity pvals] = get_sig_clusters2(stat_cfg_f)   
    sigtimes{1} % 
    plot_stat_multiplot(stat_cfg_f);
    print('figs/cfg_func_multiplot', '-dpng', '-r0');
    plot_group_betas(betas_f, 'beta_cfgp', sigchans{1}, sigtimes{1}, sigchansprop{1}, '\beta, \muV/bit');
    print('figs/cfg_func_betaplot', '-dpng', '-r300');
    % expect medio-frontal positivity ~ 200-300 ms
    % (resembles ngram effect)

save('group-stats.mat', 'stat_frq_l', ...
                'stat_cfg_f', 'stat_cfg_l', ...
                'stat_ngram_f', 'stat_ngram_l', ...
                'stat_rnn_l', 'stat_rnn_f');


%% Prepare for rERP plots

parameters = {'beta_intercept', 'beta_sentence', 'beta_pos', 'beta_frq', ...
              'beta_wm_frq', 'beta_wp_frq', 'beta_sndpwr', ...
              'beta_ngram', 'beta_rnn', 'beta_cfgp', 'beta_RMS'};
          
for i = 1:length(parameters)
    cfg = [];
    cfg.parameter = parameters{i};
    gavg_l{i} = ft_timelockgrandaverage(cfg, betas_l{:});
    if strcmp(parameters{i}, 'beta_RMS')
        continue
    else
        gavg_f{i} = ft_timelockgrandaverage(cfg, betas_f{:});
    end
end

cfg        = [];
cfg.layout = 'easycapM10-acti61_elec.sfp';
cfg.center = 'yes';
lay        = ft_prepare_layout(cfg);

%% rERP for CFG surprisal (Fig 3D)
% CFG for lexical data
% (mean = 3.289 bits)
% Plot: left frontal channel
% All other effects centered

chanpick = '44';
chnidx = find(strcmp(chanpick, gavg_l{1}.label));

center = 3.689; % mean value of cfg_surp_pos
bits = [1 4 7]; % bit values to plot
multiplier = bits-center; % multiplier for line-plots

for i = 1:length(bits) % for each separate estimate
    traces{i} = gavg_l{1}.avg(chnidx,:) + ... % intercept
               multiplier(i) * gavg_l{10}.avg(chnidx,:); % CFG!
               %1 * gavg{2}.avg(chnidx,:) + ... % sentence
               %1 * gavg{3}.avg(chnidx,:) + ... % word position
               %1 * gavg{4}.avg(chnidx,:) + ... % frequency
               %1 * gavg{5}.avg(chnidx,:) + ... % prev freq
               %1 * gavg{6}.avg(chnidx,:) + ... % next freq
               %1 * gavg{7}.avg(chnidx,:) + ... % sound power
end

% Plot traces

h = figure;
time = gavg_l{1}.time * 1000;

% add traces
plot(time, traces{1}, 'k-', 'linewidth', 2); % 2 bits
hold on
plot(time, traces{2}, 'k--', 'linewidth', 2); % 4 bits
plot(time, traces{3}, 'k:', 'linewidth', 2); % 8 bits
box off
hold off

% annotation etc.

lgd = legend({'1 bit', '4 bits', '7 bits'}, 'fontsize', 24);
title(lgd, 'CFG surprisal')
legend boxoff
%title('Estimated ERP, front midline');
xlim([-200 1000]);
xlabel('time, ms', 'fontsize', 24)
ylabel('amplitude, \muV', 'fontsize', 24)
set(gca, 'fontsize', 24); 

% set Y-axis to 3 ticks
ylim([-1 1.5]);
L = get(gca,'YLim');
set(gca,'YTick',[L(1) 0 L(2)])

hline(0, 'color', 'k', 'linestyle', ':');
vline(0, 'color', 'k', 'linestyle', ':');
hline(L(1), 'color', 'w', 'linewidth', 2); % erase x-axis line

% add inset 
axes('Position',[.4 .71 .2 .2])
box off

cfg = [];
cfg.layout = lay;
cfg.style = 'blank';
cfg.comment = 'no';
cfg.marker = 'off';
cfg.highlight = 'on';
cfg.highlightsymbol = '*';
cfg.highlightchannel = chanpick;

ft_topoplotER(cfg, gavg_l{1});

set(gcf, 'Position', [0 0 150 150]);
set(gcf, 'PaperPositionMode', 'auto');
exportgraphics(gcf,'temp.png')
insert = imread('temp.png');
%A = squeeze(insert(:,:,1) == 255 & ...
%            insert(:,:,2) == 255 & ...
%            insert(:,:,3) == 255);
%insert = image(insert);
%insert.AlphaData = A;
imshow(insert)
delete('temp.png')

set(h, 'color', 'w');
set(h, 'PaperPositionMode', 'auto');
print('figs/traces-cfg', '-dpng', '-r300');

%% rERP for Word Frequency (Fig 3B)

% Plot: midline frontal channel
% All other effects centered
chanpick = '33';
chnidx = find(strcmp(chanpick, gavg_l{1}.label));

center = 10.80016; % mean of just lex word LogHalFreq in master spreadhseet 
values = [log(200) log(20000) log(2000000)]; % word counts in HAL
multiplier = values - center; % multiplier for line-plots

for i = 1:length(values) % for each separate estimate
    traces{i} = 1 * gavg_l{1}.avg(chnidx,:) + ... % intercept
               multiplier(i) * gavg_l{4}.avg(chnidx,:); % Freq!
end

%
h = figure;
time = gavg_l{1}.time * 1000;

% add traces
plot(time, traces{1}, 'k-', 'linewidth', 2); % 20 wpm
hold on
plot(time, traces{2}, 'k--', 'linewidth', 2); % 2000 wpm
plot(time, traces{3}, 'k:', 'linewidth', 2); % 200000 wpm
box off
hold off

% legend, annotation etc.

%annotation('arrow', [.46 .43], [.15 .19]);

lgd = legend({'200', '20,000', '2,000,000'}, 'fontsize', 24);
title(lgd, 'Word frequency')
legend boxoff
%title('Estimated ERP, front midline');
xlim([-200 1000]);
xlabel('time, ms', 'fontsize', 24)
ylabel('amplitude, \muV', 'fontsize', 24)
set(gca, 'fontsize', 24);

% set Y-axis to 3 ticks
ylim([-1 1.5]);
L = get(gca,'YLim');
set(gca,'YTick',[L(1) 0 L(2)])

hline(0, 'color', 'k', 'linestyle', ':');
vline(0, 'color', 'k', 'linestyle', ':');
hline(L(1), 'color', 'w', 'linewidth', 2); % erase x-axis line

% add inset 
axes('Position',[.35 .71 .2 .2])
box off

cfg = [];
cfg.layout = lay;
cfg.style = 'blank';
cfg.comment = 'no';
cfg.marker = 'off';
cfg.highlight = 'on';
cfg.highlightsymbol = '*';
cfg.highlightchannel = chanpick;

ft_topoplotER(cfg, gavg_l{1});

set(gcf, 'Position', [0 0 150 150]);
set(gcf, 'PaperPositionMode', 'auto');
exportgraphics(gcf,'temp.png')
insert = imread('temp.png');
%A = squeeze(insert(:,:,1) == 255 & ...
%            insert(:,:,2) == 255 & ...
%            insert(:,:,3) == 255);
%insert = image(insert);
%insert.AlphaData = A;
imshow(insert)
delete('temp.png')

set(h, 'color', 'w');
set(h, 'PaperPositionMode', 'auto');
print('figs/traces-freq', '-dpng', '-r300');


%% rERP for NGRAM, function-word (Fig 3F)
% Plot: right frontal channel
% All other effects centered

chanpick = '8';
chnidx = find(strcmp(chanpick, gavg_f{1}.label));

center = 3.050318; % mean of just function word 3gram-pos in master spreadhseet 
values = [1 4 7]; % bits of surprisal
multiplier = values - center; % multiplier for line-plots

for i = 1:length(values) % for each separate estimate
    traces{i} = 1 * gavg_f{1}.avg(chnidx,:) + ... % intercept
               multiplier(i) * gavg_f{8}.avg(chnidx,:); % ngram surprisal!
end

%
h = figure;
time = gavg_f{1}.time * 1000;

% add traces
plot(time, traces{1}, 'k-', 'linewidth', 2); % 1 bit
hold on
plot(time, traces{2}, 'k--', 'linewidth', 2); % 4 bits
plot(time, traces{3}, 'k:', 'linewidth', 2); % 7 bits
box off
hold off

% legend, annotation etc.

%annotation('arrow', [.46 .43], [.15 .19]);

lgd = legend({'1 bit', '4 bits', '7 bits'}, 'fontsize', 24);
title(lgd, 'NGram Surprisal')
legend boxoff
%title('Estimated ERP, front midline');
xlim([-200 1000]);
xlabel('time, ms', 'fontsize', 24)
ylabel('amplitude, \muV', 'fontsize', 24)
set(gca, 'fontsize', 24);

% set Y-axis to 3 ticks
ylim([-1 1.5]);
L = get(gca,'YLim');
set(gca,'YTick',[L(1) 0 L(2)])

hline(0, 'color', 'k', 'linestyle', ':');
vline(0, 'color', 'k', 'linestyle', ':');
hline(L(1), 'color', 'w', 'linewidth', 2); % erase x-axis line

% add inset 
axes('Position',[.15 .71 .2 .2])
box off

cfg = [];
cfg.layout = lay;
cfg.style = 'blank';
cfg.comment = 'no';
cfg.marker = 'off';
cfg.highlight = 'on';
cfg.highlightsymbol = '*';
cfg.highlightchannel = chanpick;

ft_topoplotER(cfg, gavg_f{1});

set(gcf, 'Position', [0 0 150 150]);
set(gcf, 'PaperPositionMode', 'auto');
exportgraphics(gcf,'temp.png')
insert = imread('temp.png');
%A = squeeze(insert(:,:,1) == 255 & ...
%            insert(:,:,2) == 255 & ...
%            insert(:,:,3) == 255);
%insert = image(insert);
%insert.AlphaData = A;
imshow(insert)
delete('temp.png')

set(h, 'color', 'w');
set(h, 'PaperPositionMode', 'auto');
print('figs/traces-ngram', '-dpng', '-r300');

