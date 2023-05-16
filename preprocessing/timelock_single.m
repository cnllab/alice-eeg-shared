function [dat, proc] = timelock_single(dataset, proc)

%% function [dat, proc] = timelock_single(dataset, proc)
% Runs a set of preprocessing and data analysis steps on Alice data,
%
% dataset - full path to raw data
% proc - (optional) prePROCessing parameters from a previous run of this
% script
%
% Errata
%   proc.rank is WRONG: can manually recalculate as 
%       rank =  proc.tot_chans - 1 -
%                length(proc.ica.rejcomp) - 
%                length(proc.rejections.badchans) % includes bad impedences

proc.implicitref            = '29';
proc.refchannels            = {'25' '29'};
channels                    = {'all', '-VEOG', '-AUD', '-Aux5'};

[path, name, ext] = fileparts(dataset);
proc.subject      = name;
proc.dataset      = [name ext];


%% load raw & preprocess

cfg                                     = [];
cfg.dataset                             = dataset;
cfg.channel                             = channels;
cfg.reref                               = 'yes';
cfg.refchannel                          = proc.refchannels; % linked mastoids
cfg.implicitref                         = proc.implicitref;
cfg.hpfreq                              = 0.1;
cfg.hpfiltord                           = 3;
cfg.hpfilter                            = 'yes';
    dat_raw = ft_preprocessing(cfg);

% check filter response profile
%[z,p,k] = butter(3,0.1/250,'high');
%sos = zp2sos(z,p,k);
%fvtool(sos,'Analysis','freq', 'Fs', 500)

% View raw data
%cfg = [];
%cfg.viewmode = 'butterfly';
%    ft_databrowser(cfg, dat_raw);

%% define epochs

%if ~exist('proc') || ~isfield(proc, 'trl')
triggerfile                             = 'AliceChapterOne-EEG.csv';
epoch                                   = [-.3 1];
triggers                                = {'1'}; 
[trl, varnames]                         = get_alice2_trials(dataset, triggerfile, triggers, epoch);
trl(:,end+1) = 1:size(trl, 1);% index all trials
proc.trl = trl;
proc.varnames = {varnames{:}, 'trial_index'}; % exclude AUDIOTEXT column that is not imported
%end

cfg = [];
cfg.trl = proc.trl;
dat_all = ft_redefinetrial(cfg, dat_raw);
    
proc.tot_trials = length(dat_all.trial);
proc.tot_chans = length(dat_all.label);

%% Mark/remove high impedence chans

if ~exist('proc') || ~isfield(proc, 'impedence')
    [proc.impedence.bads proc.impedence.imps proc.impedence.labels] = get_high_impedence(dataset, 25);
    % try regular data, then try tones if no impedences
    if isempty(proc.impedence.imps)
        tonesfile = get_alice_tones_file(dataset);
        if exist('tonesfile', 'file') == 2
            [proc.impedence.bads proc.impedence.imps proc.impedence.labels] = get_high_impedence(tonesfile, 25);
            proc.impedence.note = 'From tones data!';
            warning('Using impedences from tones data')
        else
            proc.impedence.bads = {};
            proc.impedence.imps = [];
            proc.impedence.labels = {};
            proc.impedence.note = 'No impedences available.';
            warning('No impedences available.')
        end
    end
    
    picks = setdiff(dat_all.label, proc.impedence.bads);
    cfg = [];
    cfg.channel = picks;
    dat_all = ft_selectdata(cfg, dat_all);
end



%% Initial artifact rejection
% dat_all -> dat_rej1
%
% NOTE: trialinfo column 39 1-indexes all trials

trial_idx = find(strcmp(proc.varnames, 'trial_index'));
dofinalsweep = 0;  % flag to do second stage of artifact rejection, below

if ~exist('proc') || ~isfield(proc, 'rejections')
    dummy                = ft_rejectvisual([], dat_all);
    proc.rejections.first.artfctdef     = dummy.cfg.artfctdef; % used for ICA, below
    proc.rejections.first.trialpicks    = dummy.trialinfo(:, trial_idx); 
    proc.rejections.first.chanpicks     = dummy.label;
    clear dummy
    dofinalsweep = 1; % flag to do second stage of artifact rejection, below
end

% knock out any trials with NaN (e.g. at edge of recording session)
if ~exist('proc') || ~isfield(proc, 'rejections.nan_trials')
    proc.rejections.nan_trials = [];
    for i = 1:length(dat_all.trial)
        if any(isnan(dat_all.trial{i}(:)))
            proc.rejections.nan_trials = [proc.rejections.nan_trials i];
        end
    end
end

% track high impedence with picks!
if ~isempty(proc.impedence.bads)
    keep_chans = setdiff(proc.rejections.first.chanpicks, proc.impedence.bads);
else
    keep_chans = proc.rejections.first.chanpicks;
end

% track first round trial rejections
[~, ~, keep_trials] = intersect(proc.rejections.first.trialpicks, ...
                                dat_all.trialinfo(:,trial_idx));
% ...and remove any trials with NaNs
keep_trials = setdiff(keep_trials, proc.rejections.nan_trials);
%   this should == trialpicks; parallels usage for final rejections

cfg         = [];
cfg.trials  = keep_trials;
cfg.channel = keep_chans; 
dat_rej1    = ft_selectdata(cfg, dat_all);

%% ICA
% data_rej1 -> data_ica
% unmixing matrix computed over a downsampled dataset
% 
if ~exist('proc') || ~isfield(proc, 'ica')
    [proc.ica.unmixing, proc.ica.topolabel, proc.ica.rejcomp, proc.ica.comments] = ...
        get_alice2_eeg_ica(dataset, proc.rejections.first.artfctdef.summary.artifact, keep_chans);
end


% unmix the lightly cleaned data...
cfg = [];
cfg.unmixing = proc.ica.unmixing;
cfg.topolabel = proc.ica.topolabel;
    comp = ft_componentanalysis(cfg, dat_rej1);

% ...then reject components
cfg                                     = [];
cfg.component                           = proc.ica.rejcomp; % Excluded Components
    dat_ica = ft_rejectcomponent(cfg, comp);

clear comp

%% Final artifact rejection
% dat_ica -> dat_rej2
%

if dofinalsweep
    cfg = [];
    cfg.channel = proc.rejections.first.chanpicks;
    dummy = ft_rejectvisual([], dat_ica);
    proc.rejections.final.artfctdef = dummy.cfg.artfctdef;
    proc.rejections.final.trialpicks = dummy.trialinfo(:, trial_idx);
    proc.rejections.final.chanpicks  = dummy.label;
    clear dummy
end

[~, ~, keep_trials] = intersect(proc.rejections.final.trialpicks, dat_ica.trialinfo(:,trial_idx));
%   converts trialpicks to indices into dat_ica
cfg = [];
cfg.trials = keep_trials;
cfg.channel = proc.rejections.final.chanpicks; 
    dat_rej2 = ft_selectdata(cfg, dat_ica);


% some stats to track
proc.rejections.numtrialrej = length(dat_all.trial) - length(dat_rej2.trial);
proc.rejections.badchans = setdiff(dat_all.label, dat_rej2.label);


%% Bad channels are replaced with nearest neighbour interpolation
% dat_rej2 stays dat_rej2

% ADD: track rank for further data decomposition (e.g. ica, beamforming &c.)
proc.rank = min(length(proc.rejections.final.chanpicks), length(proc.ica.rejcomp) ) - 1; % -1 for online reference

missing = union(proc.impedence.bads, proc.rejections.badchans);

if ~isempty(missing)
    cfg                                     = [];
    cfg.method                              = 'template';         
    cfg.channel                             = {'all'};   
    cfg.elecfile                            = 'easycapM10-acti61_elec.sfp';
    cfg.template                            = 'easycapM10-acti61_neighb.mat';

    neighbours                              = ft_prepare_neighbours(cfg);

    cfg = [];
    cfg.method                           = 'spline';
    cfg.missingchannel                   = missing;
    cfg.neighbours                       = neighbours;
    cfg.elecfile                         = 'easycapM10-acti61_elec.sfp';

    dat_rej2                           = ft_channelrepair(cfg, dat_rej2);
end


%% Filter time-domain data for single-trial analysis
% no baseline correction!
% data_rej2 -> dat

cfg = [];
cfg.preproc.lpfilter = 'yes';
cfg.preproc.lpfreq = 40;
cfg.keeptrials = 'yes';
    dat = ft_timelockanalysis(cfg, dat_rej2);


%% Go to single precision to save disk space

dat = ft_struct2single(dat);
