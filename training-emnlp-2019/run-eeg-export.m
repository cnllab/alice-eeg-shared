%% Alice EEG: Export ROI data for Text Genre/Training analysis
%
% Last tested: MATLAB 2022a, Fieldtrip 3be5222fc

addpath('path/to/fieldtrip/toolbox'); % https://github.com/fieldtrip/fieldtrip
ft_defaults

addpath('../helpers/') % add helper scripts

load('datasets.mat', 'use') % preprocessed data to analyze

% Directory for pre-processed data
data_dir   = 'path/to/preprocessed/data';

datFiles = strcat(data_dir, use);

%% ROI Export
% Export 2 ROIs; from Hale et al. 2018 Proc ACL

ANTchans  = {'20', '21', '7', '8', '9', '36', '2', '6', '44', '45', '34', '35', '1'};
ANTtimes  = 0.200:0.002:0.400;

N400chans = {'33', '3', '38', '39', '40', '41', '42', '5', '4'};
N400times = 0.300:0.002:0.500;

export_alice_to_R(datFiles, ...
                  {'../alice-rnng-eeg-analysis/regressions-rnng/alice180-predictors-rnng.csv'}, ...
                  {3, 3}, ...
                  {N400chans, ANTchans}, ...
                  {N400times, ANTtimes}, ...
                  'all', ...
                  'forR-rnng-training-roi.csv', ...
                  {'N400', 'ANT'});
 
%% Plot ROI locations 

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

cfg.highlightchannel = ANTchans; 
ft_topoplotER(cfg, dat); 
title ANT;

clear dat proc