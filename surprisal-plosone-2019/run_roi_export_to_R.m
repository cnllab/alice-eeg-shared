%% Export spatio-temporal ROIs for statistical analysis in R
%
% creates "roi-output.csv" in the current directory

% ROIs are pre-defined based on the union of significant effects 
% observed for all target parameters for both content and function words
% For each statistical test {cfg_content cfg_func ngram_content ngram_fun rnn_content
% rnn_func}:
%   - If there is a reliable cluster, continue
%   - select top 5 chans based on proportion significant across time
%       - special: for cfg/content-words, select 2 sets based on distinct topographic split across midline 
%   - average mV across all chans for entire cluster time interval

addpath('path/to/fieldtrip/toolbox'); % https://github.com/fieldtrip/fieldtrip
ft_defaults


addpath('../helpers/') % add helper scripts

load datasets.mat % 

% Directory for pre-processed data
data_dir   = 'path/to/preprocessed/data';

%% Setup

% load pre-defined ROIs as roi_def
load('roi_definitions.mat')

% data filepaths; includes datasets that didn't meet behavioral criteria
d = [strcat(data_dir, '/', use), ...
     strcat(data_dir, '/', low_perf)];
is_high_perf = [repmat(1, [length(use) 1]); ...
                repmat(0, [length(low_perf) 1])];

% these are going to be combined together into an output table
j               = 0; % track size of new table

subject         = {};
performance     = [];
roi             = {};
order           = []; 
iscontent       = []; 
sentence        = []; 
position        = []; 
frq             = []; 
wm_frq          = []; 
wp_frq          = []; 
sndpwr          = []; 
ngram           = []; 
rnn             = []; 
cfg             = []; 
amp             = [];

% Iterate over datasets and extract mV per ROI
for s = 1:length(d) % for each DATASET...
    load (d{s}, 'dat', 'proc');
    disp(['Processing subject ' proc.subject '...\n']);
%    dat = ft_struct2double(dat);

    for r = 1:length(roi_def) % for each ROI...
        chan_idx = match_str(dat.label, roi_def(r).chans);
        time_idx = find(ismembertol(dat.time, roi_def(r).times, 0.0001));
        nTrials = size(dat.trial, 1);

        for t = 1:nTrials % for each TRIAL...
            j = j + 1; % increment to next row
            
            data_block = dat.trial(t, chan_idx, time_idx);
            amp(j) = mean(data_block(:));
            
            subject{j}         = proc.subject;
            performance(j)     = is_high_perf(s);
            roi{j}             = roi_def(r).label;
            order(j)           = dat.trialinfo(t, 5); % check col indices 
            iscontent(j)       = dat.trialinfo(t, 13);% against proc.varnames
            sentence(j)        = dat.trialinfo(t, 12);
            position(j)        = dat.trialinfo(t, 11); 
            frq(j)             = dat.trialinfo(t, 6); 
            wm_frq(j)          = dat.trialinfo(t, 7); 
            wp_frq(j)          = dat.trialinfo(t, 8); 
            sndpwr(j)          = dat.trialinfo(t, 9); 
            ngram(j)           = dat.trialinfo(t, 14);
            rnn(j)             = dat.trialinfo(t, 15);
            cfg(j)             = dat.trialinfo(t, 16);
        end % end TRIAL
    end % end ROI
    clear dat proc
end % end DATASET
          
% convert from row to column vectors
amp         = amp';
subject     = subject';
performance = performance';
roi         = roi';
order       = order';
iscontent   = iscontent';
sentence    = sentence';
position    = position';
frq         = frq';
wm_frq      = wm_frq';
wp_frq      = wp_frq';
sndpwr      = sndpwr';
ngram       = ngram';
rnn         = rnn';
cfg         = cfg';

output = table( amp, subject, performance, roi, order, iscontent, ...
                sentence, position, frq, wm_frq, wp_frq, sndpwr, ...
                ngram, rnn, cfg);

writetable(output, 'roi-output.csv');

%% plot ROIs
% top of Fig 4

load (d{1}, 'dat');
tmp = ft_timelockanalysis([], dat);

cfg        = [];
cfg.layout = 'easycapM10-acti61_elec.sfp';
cfg.center = 'yes';
lay        = ft_prepare_layout(cfg);

for r = 1:length(roi_def)
    cfg = []; 
    cfg.parameter = 'avg';
    cfg.layout = lay;
    cfg.style = 'blank';
    cfg.marker = 'off';
    cfg.highlight = 'on';
    cfg.highlightsymbol = '.';
    cfg.highlightsize = 26;
    cfg.highlightchannel = roi_def(r).chans;
    cfg.comment = 'no';

    title([num2str(min(roi_def(r).times)) '-' num2str(max(roi_def(r).times))])

    ft_topoplotER(cfg, tmp); % data file is arbitrary for func to work
    set(gcf,'units','inches','position',[0,0,2,2])
    saveas(gcf, ['figs/elecs_' roi_def(r).label '.png']);
    close gcf
end

