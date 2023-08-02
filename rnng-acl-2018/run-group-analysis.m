%% Alice EEG: Group Analysis for RNNG analysis
%
% Last tested: MATLAB 2022a, Fieldtrip 3be5222fc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTANT NOTES
% The statistical analysis has two stochastic components:
%  1. single-subject control regressions are randomly shuffled
%  2. whole-head group stats are based on 1000 random permutations
% Seeds for these randomizations from the original analysis were not saved,
% so expect output, including plots, to be quantitatively different (but
% qualitatively the same) as published results.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('path/to/fieldtrip/toolbox'); % https://github.com/fieldtrip/fieldtrip
ft_defaults

addpath('../helpers/') % add helper scripts

load('datasets.mat', 'use') % preprocessed data to analyze

% Directory for pre-processed data
data_dir   = 'path/to/preprocessed/data';

datFiles = strcat(data_dir, use);

%% FULL RNNG: Single subject regressions and group summary 
% 33 subjects x 25 models
% then 25 group-level permutation tests
            
tic
run_paramaterized_regressors('regressions-rnng/alice180-predictors-rnng.csv', ...
                             3, ... % starting column for ALL vars
                             {'Sentence', 'Position', 'LogFreq', 'LogFreq_Prev', 'LogFreq_Next', 'SndPower'}, ... % control predictors
                             datFiles, ...
                             'regressions-rnng') % output folder
toc % ~100 min on 2021 macbook pro

% this loop generates output corresponding to Table 3 and Figure 3A,B
% see note at bottom of file

%% RNNG-NOCOMP: Single-subject regressions and group summary 
% 33 subjects x 25 models
% then 25 group-level permutation tests

tic
run_paramaterized_regressors('regressions-rnng-nocomp/alice180-predictors-rnng-nocomp.csv', ...
                             3, ... % starting column for ALL vars
                             {'Sentence', 'Position', 'LogFreq', 'LogFreq_Prev', 'LogFreq_Next', 'SndPower'}, ... % control predictors
                             datFiles, ...
                             'regressions-rnng-nocomp') % output folder
toc % ~100 min on 2021 macbook pro

%% ROI Export

% Export based on 3 ROIs

N400chans = {'33', '3', '38', '39', '40', '41', '42', '5', '4'};
N400times = 0.300:0.002:0.500;

P600chans = {'4', '39', '13', '14', '54', '15', '16', '41', '40'};
P600times = 0.600:0.002:0.700; 

ANTchans  = {'20', '21', '7', '8', '9', '36', '2', '6', '44', '45', '34', '35', '1'};
ANTtimes  = 0.200:0.002:0.400;

export_alice_to_R(datFiles, ...
                  {'regressions-rnng/alice180-predictors-rnng.csv', ...
                   'regressions-rnng-nocomp/alice180-predictors-rnng-nocomp.csv'}, ...
                  {3, 3}, ...
                  {N400chans, P600chans, ANTchans}, ...
                  {N400times, P600times, ANTtimes}, ...
                  'all', ...
                  'forR-rnng-roi.csv', ...
                  {'N400', 'P600', 'ANT'});
%  NOTE: 'NOCOMP' predictors suffixed with '2'
 
%% Plot ROI locations (for fig 4)

load(datFiles{1})

cfg = [];
cfg.layout = 'easycapM10-acti61_elec.sfp';
cfg.style = 'blank';
cfg.marker = 'off';
cfg.highlight = 'on';
cfg.comment = 'no';

cfg.highlightchannel = N400chans;
ft_topoplotER(cfg, dat); 
title N400;

cfg.highlightchannel = P600chans; 
ft_topoplotER(cfg, dat); 
title P600;

cfg.highlightchannel = ANTchans; 
ft_topoplotER(cfg, dat); 
title ANT;

clear dat proc


%% FINDING PUBLISHED RESULTS

% Table 3 comes from regressions-rnng/results-summary0.txt
% Fig 3A from regressions-rnng/k20_distance_betaplot.png
% Fig 3B from regressions-rnng/k20_surprisal_betaplot.png
%
% PRECISE VALUES MAY DIFFER FROM PUBLICATION; SEE NOTE AT TOP

