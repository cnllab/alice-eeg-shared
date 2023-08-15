%% Alice EEG: Group Analysis for bracket count

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTANT NOTE
% The single-subject control regressions in the statistical analysis have 
% a random component and the seed from the original analysis was not saved. 
% Accordingly, statistical tests (e.g. timing and topography of effects) 
% may quantitatively differ from the published results.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('path/to/fieldtrip/toolbox'); % https://github.com/fieldtrip/fieldtrip
ft_defaults

addpath('../helpers') % add helper scripts

% Directory for pre-processed data
data_dir   = 'path/to/preprocessed/data';

% Directory for regression results
betas_dir = 'path/to/single/subject/regression/results';

% Directory for statistical output
stats_dir = 'path/to/save/group/statistics/results';

%% Prepare for stats

load datasets.mat % 

% Both LINEAR and LOG BRACKET COUNT
% Remember: no residulization
listing = dir([betas_dir '/' '*_betas.mat']);
betas   = {listing.name};
betas   = strcat(betas_dir, '/', betas);

betas_lin_l = {}; conbetas_lin_l = {};
betas_lin_f = {}; conbetas_lin_f = {};
betas_log_l = {}; conbetas_log_l = {};
betas_log_f = {}; conbetas_log_f = {};

%% load single-subject regression coefficients

for i = 1:length(betas)
    load(betas{i});
    betas_lin_l{i}    = flip_betas(dat_lin_l_b);
    conbetas_lin_l{i} = flip_betas(dat_lin_l_cb);    
    betas_lin_f{i}    = flip_betas(dat_lin_f_b);
    conbetas_lin_f{i} = flip_betas(dat_lin_f_cb);    

    betas_log_l{i}    = flip_betas(dat_log_l_b);
    conbetas_log_l{i} = flip_betas(dat_log_l_cb);    
    betas_log_f{i}    = flip_betas(dat_log_f_b);
    conbetas_log_f{i} = flip_betas(dat_log_f_cb);    
end

lay        = 'easycapM10-acti61.lay';
cfg        = [];
cfg.method = 'triangulation';
cfg.layout = lay;
nb = ft_prepare_neighbours(cfg);

%% WORD FREQUENCY 
% validation check; see Brennan & Hale 2019 PLoS One
stat_freq_l = do_beta_stats(betas_lin_l, conbetas_lin_l, 'beta_LogFreq', 1000);
    [sigtimes sigchans sigchansprop polarity pvals] = get_sig_clusters2(stat_freq_l)   
    plot_group_betas(betas_lin_l, 'beta_LogFreq', sigchans{1}, sigtimes{1}, sigchansprop{1});

%% CONTENT WORDS and LINEAR BRACKETS
% Fig 3A
stat_linbrack_l = do_beta_stats(betas_lin_l, conbetas_lin_l, 'beta_cfg_bu', 10000);
    [sigtimes sigchans sigchansprop polarity pvals] = get_sig_clusters2(stat_linbrack_l)   
    plot_group_betas(betas_lin_l, 'beta_cfg_bu', sigchans{1}, sigtimes{1}, sigchansprop{1}, '\beta, \muV/bracket');
    % 1: late centro-parietal positivity
    print('figs/cfg_bu_lex_betaplot01', '-dpng', '-r0');
    plot_group_betas(betas_lin_l, 'beta_cfg_bu', sigchans{2}, sigtimes{2}, sigchansprop{2}, '\beta, \muV/bracket');
    % 2: left anterior negativity
    print('figs/cfg_bu_lex_betaplot02', '-dpng', '-r0');


%% FUNCTION WORDS and LINEAR BRACKETS
% Fig 3B
stat_linbrack_f = do_beta_stats(betas_lin_f, conbetas_lin_f, 'beta_cfg_bu', 10000);
    [sigtimes sigchans sigchansprop polarity pvals] = get_sig_clusters2(stat_linbrack_f)   
    plot_group_betas(betas_lin_f, 'beta_cfg_bu', sigchans{1}, sigtimes{1}, sigchansprop{1}, '\beta, \muV/bracket');
    % 1: late centro-parietal positivity
    print('figs/cfg_bu_func_betaplot01', '-dpng', '-r0');
    plot_group_betas(betas_lin_f, 'beta_cfg_bu', sigchans{2}, sigtimes{2}, sigchansprop{2}, '\beta, \muV/bracket');
    % 2: (early) anterior negativity
    print('figs/cfg_bu_func_betaplot02', '-dpng', '-r0');

%% CONTENT WORDS and LOG BRACKETS
% Supplemental Fig S2A
stat_logbrack_l = do_beta_stats(betas_log_l, conbetas_log_l, 'beta_log_cfg_bu', 10000);
    [sigtimes sigchans sigchansprop polarity pvals] = get_sig_clusters2(stat_logbrack_l)   
    plot_group_betas(betas_log_l, 'beta_log_cfg_bu', sigchans{1}, sigtimes{1}, sigchansprop{1}, '\beta, \muV/(log bracket)');
    % 1: late centro-parietal positivity
    print('figs/log_cfg_bu_lex_betaplot01', '-dpng', '-r0');
    plot_group_betas(betas_log_l, 'beta_log_cfg_bu', sigchans{2}, sigtimes{2}, sigchansprop{2}, '\beta, \muV/(log bracket)');
    % 2: anterior negativity
    print('figs/log_cfg_bu_lex_betaplot02', '-dpng', '-r0');

%% FUNCTION WORDS and LOG BRACKETS
% Supplemental Fig S2B
stat_logbrack_f = do_beta_stats(betas_log_f, conbetas_log_f, 'beta_log_cfg_bu', 10000);
    [sigtimes sigchans sigchansprop polarity pvals] = get_sig_clusters2(stat_logbrack_f)   
    plot_group_betas(betas_log_f, 'beta_log_cfg_bu', sigchans{1}, sigtimes{1}, sigchansprop{1}, '\beta, \muV/(log bracket)');
    % 1: late centro-parietal positivity
    print('figs/log_cfg_bu_func_betaplot01', '-dpng', '-r0');

%% Wrap-up
save([stats_dir '/' 'wholehead_stats.mat'], ...
    'stat_linbrack_l', 'stat_linbrack_f', ...
    'stat_logbrack_l', 'stat_logbrack_f');

fprintf('[Finished whole-head statistical analysis]\n')