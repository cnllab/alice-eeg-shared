function stat = do_beta_stats(betas, conbetas, parameter, numrandomization, isLike)

%% function stat = do_beta_stats(betas, conbetas, parameter, numrandomization, isLike);
%
% Run fieldtrip cluster stats for Alice EEG betas

if nargin < 5
    isLike = 0; % if the value is a likelihood
end

cfg        = [];
cfg.layout = 'easycapM10-acti61_elec.sfp';
cfg.center = 'yes';
lay        = ft_prepare_layout(cfg);

cfg        = []; 
cfg.method = 'triangulation'; 
cfg.layout = lay;
nb = ft_prepare_neighbours(cfg);

cfg                  = [];
cfg.latency          = [0 1];
cfg.method           = 'montecarlo';
cfg.correctm         = 'cluster';
cfg.numrandomization = numrandomization;
cfg.neighbours       = nb;
cfg.clusteralpha     = 0.05;
if isLike %likelihoods are a one-tailed test
    cfg.tail = 1;
end
cfg.ivar        = 1;
cfg.uvar        = 2;
cfg.statistic   = 'depsamplesT';
cfg.design(1,:) = [ones(1, length(betas)), ones(1, length(conbetas)) * 2]; %
cfg.design(2,:) = [1:length(betas), 1:length(conbetas)];
cfg.parameter   = parameter;

switch betas{1}.dimord
  case 'chan_time'
  stat = ft_timelockstatistics(cfg, betas{:}, conbetas{:});

  case 'chan_freq_time'
  stat = ft_freqstatistics(cfg, betas{:}, conbetas{:});
end
