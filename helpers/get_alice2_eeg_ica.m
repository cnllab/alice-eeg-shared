function [unmixing topolabel rej_comp notes] = get_alice2_eeg_ica(dataset, artifact, picks);

%% function [unmixing topolabel notes] = get_alice2_eeg_ica(dataset, artifact);
% Helper function runs ICA on EEG data
% following standard procedure in the CNL lab
%
% dataset - filename to raw data
% artifact - matrix of artifacts [beg_sample, end_sample] returned by
% fieldtrip artifact rejection tools
%
% output: unmixing - unmixing matrix
%         topolabel - channel labels matched to unmixing matrix
%         (both are outputs of "ft_componentanalysis")
%         rej_comp - components to remove
%         notes - tracks which components were removed and why
%

rank = length(picks) - 1; % -1 for ref chan

%% Re-load raw in 2 s segments with demeaning

% new trial definition: 2 s segments
cfg = [];
cfg.dataset = dataset;
cfg.channel = picks;
cfg.trialdef.triallength = 4;
    cfg = ft_definetrial(cfg);
    
cfg.artfctdef.summary.artifact = artifact; % minimal artifact rejection
    cfg = ft_rejectartifact(cfg);
    
cfg.implicitref                             = '29';

% load...
raw = ft_preprocessing(cfg);

% ...re-ref and demean...
cfg = [];
cfg.reref = 'yes';
cfg.refchannel                             = {'25', '29'};
cfg.demean = 'yes';
cfg.channel = picks; % bug in ft_preprocessing can fail to exclude channels...
raw = ft_preprocessing(cfg, raw);

%% ICA (resample to 150Hz)
cfg                              = [];
cfg.resamplefs                   = 150;
cfg.detrend                      = 'no';
raw_ds                           = ft_resampledata(cfg, raw);

% ICA decomp

cfg = [];
cfg.method = 'runica';
cfg.runica.pca = rank;
    comp                               = ft_componentanalysis(cfg, raw_ds);

% view components

cfg                                    = [];
cfg.viewmode                           = 'component';
cfg.compscale                          = 'local';
cfg.elecfile                           = 'easycapM10-acti61_elec.sfp'; 
cfg.renderer                           = 'painters'; 
ft_databrowser(cfg, comp);

% ICA bookkeeping

%rej_comp  = input('Components to Remove (e.g. [1 2]): ');
%notes  = input('Comments: ', 's');

prompt   = {'Components to Remove:','Comments:'};
title    = 'Input';
dims     = [1 35; 2 35];
definput = {'[1 2]',''};
answer   = inputdlg(prompt,title,dims,definput);

rej_comp = str2num(answer{1});
notes    = answer{2};

unmixing = comp.unmixing;
topolabel = comp.topolabel;


