function [trl varnames missingtrials] = get_alice2_trials(dataset, triggerfile, triggers, epoch)

%% function [trl varnames] = get_alice2_trials(dataset, triggerfile, triggers, epoch)
% Function returns a fieldtrip trl object corresponding a given set of
% triggers
%
% dataset - brainvision eeg dataset
% triggerfile - excel file containing stim timing and triggering details
% triggers - cell array of triggers to create epochs around (e.g. {'1' '2' '3' '4'})
% epoch - epoch size in seconds (e.g. [-.3 1])
%
% trl - fieldtrip style trl file for each epoch with trigger in 'triggers'
% varnames - column names for per-trial info coded in spreadsheet
% missingtrials - count of trials that were expected but not found in the
% dataset
%
% Alice2 Trigger Design
%   Story presented in 12 chunks
%   indexed by triggers 1-12
%
% Basic algorithm:
% for each t in 'triggers'
%   find each entry e in 'triggerfile'
%   for each e
%       find passage p
%       find offset time s
%       get onset time o for p
%       create adjusted time a by adding p to s
%       create epoch h based on 'epoch' around a 
%       write h as an entry in trl
%   end loop on e
% end loop on t
%

% get passage onset markers
cfg = [];
cfg.dataset = dataset;
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.eventvalue = ''; % get all events
cfg.trialdef.prestim = 0;
cfg.trialdef.poststim = 1;

cfg = ft_definetrial(cfg);
hdr = ft_read_header(cfg.dataset); % for sampling rate

po = cfg.trl(:,1); % get passage onsets

% correct passage onsets for eprime lag
po(1)     = po(1) + 0.060 * hdr.Fs;         % 60 ms delay for passage 1
po(2:end) = po(2:end) + 0.050 * hdr.Fs;     % 50 ms delay for passage 2:12


% get trigger reference file
predictors = readtable(triggerfile); %raw contains all info as cell array

triggers   = cellfun(@str2num, triggers);
alltrigs   = predictors.Trigger;
alltimes   = predictors.onset;
allpassage = predictors.Segment;

%datatypes  = varfun(@class, predictors, 'OutputFormat', 'cell');
%usecolumns = find(strcmp(datatypes, 'double')); % only use numeric cols

% define trials for target triggers
trl = [];
j = 1;                              % index for trl
for t = triggers                    % for each trigger
    entry = find(t == alltrigs);    % get all occurances of t in the spreadsheet
    for e = entry'                  % for each occurance of t
        l = ceil(alltimes(e) * hdr.Fs); % get the lag for e relative to passage beginning; conv sec to samples
        p = allpassage(e);              % get the passage containing e
        if p <= length(po)
            a = po(p) + l;           % po (passage onset) + l (item lag) =
                                     %   a (stim onset) in samples relative to start of recording
                                     % TODO: passage index or passage
                                     % trigger value?
        else
            warning('Missing passage: %g', p)
            continue;
        end
        trl(j,1) = a + (epoch(1) * hdr.Fs); % epoch onset
        trl(j,2) = a + (epoch(2) * hdr.Fs); % epoch offset
        trl(j,3) = epoch(1) * hdr.Fs; % epoch zero point
        trl(j,4) = t; % trigger
        trl(j,5) = p; % passage
        trl(j,6) = alltimes(e); % lag in sec
        for k = 5:size(predictors,2)        % all other numerical elements from spreadsheet
            trl(j, k+2) = predictors{e, k}; % skip [word, trigger, segment, onset]
        end
        j = j + 1;
    end
end

[b i]    = sort(squeeze(trl(:,1)));
trl      = trl(i,:);
varnames = {'trigger', 'passage', 'onset', predictors.Properties.VariableNames{5:end}};

fprintf('\nFound %g events matching selected triggers\n', size(trl,1));

%% Re-create sentence and position values here
% Note: this is flawed for four subjects with buggy triggers: S26, S34, S35, S36
% Because of buggy triggers, their word-order column is not monotonic
% ... and the original code, copied below, ignored the ordering of the word
% order column when adding in sentence and position information
% this created incorrect sentence and position information for ~20 or so
% epochs
% - Included here to fully recreate the original analysis

position = predictors.Position;
sentence = predictors.Sentence;

order_col    = 3 + find(strcmp(varnames, 'Order'));
sentence_col = 3 + find(strcmp(varnames, 'Sentence'));
position_col = 3 + find(strcmp(varnames, 'Position'));

ord       = predictors.Order; % get Order for alignment 
dat_ord   = trl(:,8); % Order in trl from above
keeps     = ismember(ord, dat_ord); 
        % logical for if the target word is in the dataset

% plot(trl(:,position_col)) % shows out-of-order words on problematic subjects
% plot(position(keeps))     % "corrected" to original analysis

% replace sentence and position with these new values
trl(:,position_col) = position(keeps);
trl(:,sentence_col) = sentence(keeps);

%% Round down sampleinfo to integers

trl(:,1:3) = floor(trl(:,1:3));


%% Check that we have all the requested data

hdr = ft_read_header(dataset);
ntotalsamples = hdr.nSamples;
keeptrial = trl(:,2) <= ntotalsamples;

% if sum(keeptrial) < size(trl,1)
%     warning('%g epochs not found in dataset.', size(trl,1)-sum(keeptrial));
% end

trl = trl(keeptrial,:);

numdesiredtrials = sum(ismember(alltrigs, triggers));
missingtrials = numdesiredtrials - size(trl,1);

if missingtrials > 0
    warning('%g epochs not found in dataset.', missingtrials);
end


%% wrap-up
fprintf('\nFound %g events matching selected triggers\n', size(trl,1));