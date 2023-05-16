%% Run preprocessing for Alice EEG datasets

addpath('~/Documents/matlab/toolbox/fieldtrip'); % https://github.com/fieldtrip/fieldtrip
ft_defaults
addpath('../helpers/') % add helper scripts

% Filenames for raw datasets

raw_dir   = 'path/to/raw/data/directory';
raw_files = dir([raw_dir '/*.eeg']);
raw_files = {raw_files.name};

% Filenames for processing parameters (OPTIONAL)

proc_dir   = 'path/to/preprocessing/directory';
proc_files = dir([proc_dir '/*.mat']);
proc_files = {proc_files.name};

% Destination for processed data

dest_dir = 'path/to/directory/to/save/preprocessed/data';

%% Run single-subject analysis
% If running from scratch, loop over raw_files
% If reproducing original analysis, loop over proc_files (excludes data
% deemed too noisy to process)

for f = 1:length(proc_files)
    [path name ext] = fileparts(proc_files{f});
    dataset = [raw_dir '/' name '.eeg']; % points to raw data
    load([proc_dir '/' name ext]);       % OPTIONAL: loads proc object with preprocessing parameters
    
    %check_bad_refs(dataset);
    [dat, proc] = timelock_single(dataset, proc);
    save([dest_dir '/' name '.mat'], 'dat', 'proc');
end

% Checked against saved preprocessed mat files

%% Summarize subject exclusions (anonymized)
% 49 datasets
%  -10 due to poor behavioral performance
% = 39 good performers
%  -6 due to excessive noise
% = 33 DATASETS FOR FINAL ANALYSIS ("use")
% ... out of 42 that could be fully pre-processed
% ... 8/10 poor performers had adequately noise-free data ("low_perf")

use = { 'S01.mat', 'S03.mat', 'S04.mat', ...
        'S05.mat', 'S06.mat', 'S08.mat', ...
        'S10.mat', 'S11.mat', 'S12.mat', ...
        'S13.mat', 'S14.mat', 'S15.mat', ...
        'S16.mat', 'S17.mat', 'S18.mat', ...
        'S19.mat', 'S20.mat', 'S21.mat', ...
        'S22.mat', 'S25.mat', 'S26.mat', ...
        'S34.mat', 'S35.mat', 'S36.mat', ...
        'S37.mat', 'S38.mat', 'S39.mat', ...
        'S40.mat', 'S41.mat', 'S42.mat', ...
        'S44.mat', 'S45.mat', 'S48.mat' };

low_perf = {'S07.mat', 'S09.mat', 'S23.mat', ...
            'S24.mat', 'S27.mat', 'S30.mat', ...
            'S32.mat', 'S43.mat' }; % also S46 & S47 but they are also excluded due to noise

high_noise = {'S02.mat', 'S28.mat', 'S29.mat', ...
              'S31.mat', 'S33.mat', 'S46.mat', ...
              'S47.mat', 'S49.mat'};

save('datasets.mat', 'use', 'low_perf', 'high_noise');


