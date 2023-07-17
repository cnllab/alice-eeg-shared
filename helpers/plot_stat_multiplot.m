function h = plot_stat_multiplot(stat, mask);

%% function h = plot_stat_multiplot(stat, mask);
%
% Quick plot multiplot for fieldtrip stat objects

if nargin == 2
    stat.mask = mask;
end

cfg        = [];
cfg.layout = 'easycapM10-acti61_elec.sfp';
cfg.center = 'yes';
lay        = ft_prepare_layout(cfg);


h                 = figure;
cfg               = [];
cfg.parameter     = 'stat';
cfg.maskparameter = 'mask';
cfg.layout        = lay;

switch stat.dimord
    case 'chan_time'
    ft_multiplotER(cfg, stat); 

    case 'chan_freq_time'
    ft_multiplotTFR(cfg, stat);
end
set(gcf, 'color', 'w');

statname = inputname(1);
statname = strrep(statname, '_', '-');
title(statname);

set(h, 'PaperPositionMode', 'auto');