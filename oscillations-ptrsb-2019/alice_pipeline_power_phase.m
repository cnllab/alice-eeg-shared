function [out_table] = alice_pipeline_power_phase(raw_file, proc_file, dest_dir)

%% function [out_table] = alice_pipeline_power_phase(raw_file, proc_file, dest_dir)
%
% Preprocessing and data analysis steps on Alice data returns 
% power time-series at five bands
%
% REQUIRES: proc - prePROCessing parameters; see preprocessing/ at
% https://github.com/jonrbrennan/alice-eeg-shared

load(proc_file, 'proc');
channels                                = {'all', '-VEOG', '-AUD', '-Aux5', '-OPTO'};

fprintf('Processing dataset %s... \n', proc.subject)

%% load raw & preprocess

cfg                                     = [];
cfg.dataset                             = raw_file;
cfg.channel                             = channels;
cfg.reref                               = 'yes';
cfg.refchannel                          = proc.refchannels; % linked mastoids
cfg.implicitref                         = proc.implicitref;
cfg.hpfreq                              = 0.1;
cfg.hpfiltord                           = 6;
cfg.hpinstabilityfix                    = 'split';
cfg.hpfilter                            = 'yes';
cfg.dftfilter                           = 'yes';
cfg.dftfreq                             = 60;
    dat_raw = ft_preprocessing(cfg);
    
% check filter response profile
%[z,p,k] = butter(3,0.1/250,'high');
%sos = zp2sos(z,p,k);
%fvtool(sos,'Analysis','freq', 'Fs', 500)

% View raw data
%cfg = [];
%cfg.viewmode = 'butterfly';
%    ft_databrowser(cfg, dat_raw);

%% Define trials

% need to use get_alice2_trials-style code to get actual sample value for
% each word (onset and offset) 
% approach:
%   onsets: first col of trl + baseline adjust
%   offsets: first col of trl +baseline adjust + ((tmax-tmin)*Fs) adjust

Fs           = dat_raw.fsample;
triggerfile  = 'AliceChapterOne-Nodecounts.csv';
triggers     = readtable(triggerfile);
word_rows    = triggers.Trigger == 1;
onset_times  = triggers.tmin(word_rows);
offset_times = triggers.tmax(word_rows);
order        = triggers.Order(word_rows);

trl           = proc.trl;

% handle subjs with < full number of trials
if size(trl,1) ~= size(order,1)
    keeps = ismember(order, trl(:,6));
    onset_times = onset_times(keeps);
    offset_times = offset_times(keeps);
    order = order(keeps);
end

% check alignment
% onset_times == trl(:,5)
% order == trl(:,6)

onset_samples = trl(:,1) - trl(:,3);
offset_adjust = floor((offset_times - onset_times) * Fs);
%offset_adjust = ceil((offset_times - onset_times) * Fs);
offset_samples = onset_samples + offset_adjust;

%% ICA
% unmixing matrix computed over a downsampled dataset
%

% remove channels originally rejected prior to ICA
picks = proc.ica.topolabel;
cfg = [];
cfg.channel = picks;
dat_rej = ft_selectdata(cfg, dat_raw);

% unmix the data...
cfg = [];
cfg.unmixing  = proc.ica.unmixing;
cfg.topolabel = proc.ica.topolabel;
    comp = ft_componentanalysis(cfg, dat_rej);

% ...then reject components
cfg                                     = [];
cfg.component                           = proc.ica.rejcomp; % Excluded Components
    dat_ica = ft_rejectcomponent(cfg, comp);

clear comp

%% Remove bad channels

picks       = setdiff(dat_ica.label, proc.rejections.badchans);
cfg         = [];
cfg.channel = picks;
dat_ica2    = ft_selectdata(cfg, dat_ica);


%% Bad channels are replaced with nearest neighbour interpolation

missing = union(proc.impedence.bads, proc.rejections.badchans);

if ~isempty(missing)
    cfg                                     = [];
    cfg.method                              = 'template';
    cfg.channel                             = {'all'};
    cfg.elec                                = 'easycapM10-acti61_elec.sfp';
    cfg.template                            = 'easycapM10-acti61_neighb.mat';

    neighbours                              = ft_prepare_neighbours(cfg);

    cfg = [];
    cfg.method                           = 'spline';
    cfg.missingchannel                   = missing;
    cfg.neighbours                       = neighbours;
    cfg.elec                             = 'easycapM10-acti61_elec.sfp';

    dat_ica2                           = ft_channelrepair(cfg, dat_ica2);
end


%% Band-pass and hilbert in 3 bands
% Incorporate trial rejections here

bandName = {'delta', 'theta', 'gamma'};
bands = {[1 4], [4 8], [30 50]};
hlb = {};

keep_trials = proc.rejections.final.trialpicks;
num_keeps = length(keep_trials);

for b = 1:length(bands)
  cfg               = [];
  cfg.bpfreq        = bands{b};
  cfg.bpfilter      = 'yes';
%  cfg.bpfilttype   = 'firws'; % see https://mailman.science.ru.nl/pipermail/fieldtrip/2015-September/009658.html
  cfg.bpfiltorder = 6;
  cfg.hilbert   = 'complex';
  filtered = ft_preprocessing(cfg, dat_ica2);
  
  chn = find(strcmp(filtered.label, '33'));
  
  hlb{b} = zeros(num_keeps, 5);
  for t = 1:num_keeps
      k = keep_trials(t);
      hlb{b}(t, 1) = abs(filtered.trial{1}(chn, onset_samples(k)));
      hlb{b}(t, 2) = angle(filtered.trial{1}(chn, onset_samples(k)));
      hlb{b}(t, 3) = abs(filtered.trial{1}(chn, offset_samples(k)));
      hlb{b}(t, 4) = angle(filtered.trial{1}(chn, offset_samples(k)));
      hlb{b}(t,5)  = order(k); % trial order as key!
  end
  
  hlb{b} = table(repmat(proc.subject, num_keeps, 1), ...
                 repmat(bandName{b}, num_keeps, 1), ...
                 hlb{b}(:,1), ...
                 hlb{b}(:,2), ...
                 hlb{b}(:,3), ...
                 hlb{b}(:,4), ...
                 hlb{b}(:,5), ...
                 'VariableNames', {'subject', 'band', 'ons_pwr', 'ons_phs', 'ofs_pwr', 'ofs_phs', 'order'} );
  
   clear filtered        
end

out_table = [hlb{1}; hlb{2}; hlb{3}];
out_file  = [dest_dir '/' proc.subject '.csv'];
writetable(out_table, out_file);

fprintf('Results saved to %s\n', out_file);