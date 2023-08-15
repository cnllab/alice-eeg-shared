%% Alice EEG: Compute power and phase per-trial and export for stats
% Loads raw data and returns power and phase in selected bands 
% at word onset and offset along-side single-trial annotations
%
% measures: instantaneous power, phase 
%
% bands: 
% - delta, 1-4
% - theta, 4-8
% - gamma, 30-50
%
% at: word onset, word offset
%
% Returns CSV file per-subject with 7 columns:
%   subject, band, onset_power, onset_phase, offset_power, offset_phase, trial_order

addpath('path/to/fieldtrip/toolbox'); % https://github.com/fieldtrip/fieldtrip
ft_defaults

addpath('../helpers') % add helper scripts

% Filenames for raw datasets
raw_dir   = 'path/to/raw/data';

% Filenames for prePROCessing parameters 
proc_dir   = 'path/to/preprocessing/directory';

% Destination for power and phase data
dest_dir = 'path/to/directory/to/save/output';

%% Prepare filenames

load('datasets.mat', 'use')
use_raw = strrep(use, '.mat', '.eeg')
raw_files = strcat(raw_dir, '/', use_raw);
proc_files = strcat(proc_dir, '/', use);

%% Process data per participant

for i = 22:length(use)
   alice_pipeline_power_phase(raw_files{i}, proc_files{i}, dest_dir);
end
fprintf('[Finished exporting single-subject power and phase data]\n')

