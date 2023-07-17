function h = plot_group_betas(betas, parameter, channels, sigtimes, chanprop, ylab, xlimits)
%% function h = plot_group_betas(betas, parameter, channels, sigtimes, chanprop, ylab, xlimits)
%
% Plot group-level betas over time
%
% NOTEs: times given in sec, but plotted in milliseconds!
        

if nargin < 7
    xlimits = [-0.2 1];
end

if nargin < 6
    ylab = 'amplitude, \muV';
end

if nargin < 5
    chanprop = 1;
end

if nargin < 4
    sigtimes = [0.3 0.5];
end

if nargin < 3
    channels = {'33'}; % default = vertex
end

nchans = length(channels);
nsubj  = length(betas);

times    = betas{1}.time * 1000; % to milliseconds
sigtimes = sigtimes * 1000; % to milliseconds
xlimits  = xlimits * 1000;

cfg           = [];
cfg.parameter = parameter;
gavg          = ft_timelockgrandaverage(cfg, betas{:});

Y = zeros(nsubj, length(times));

for s = 1:nsubj
    [~, ai] = intersect(betas{s}.label, channels);
    Bvals   = eval(sprintf('betas{s}.%s(ai, :)', parameter));
    Y(s,:)  = sum(Bvals .* chanprop, 1) / sum(chanprop); % channels weighted by prop significant
end

Ym   = mean(Y, 1);
Yse  = std(Y, 1) / sqrt(nsubj);
Yciu = Ym + 1.96*Yse;
Ycil = Ym - 1.96*Yse;

[~, sigidx] = intersect(times, sigtimes);
sigX        = [times(sigidx), fliplr(times(sigidx))];
sigY        = [Yciu(sigidx), fliplr(Ycil(sigidx))];

cfg        = [];
cfg.layout = 'easycapM10-acti61_elec.sfp';
cfg.center = 'yes';
lay        = ft_prepare_layout(cfg);

%% Make the lineplot

h = figure;
patch(sigX, sigY, [0 0 0], 'FaceAlpha', 0.4, 'EdgeAlpha', 0);
patch([times, fliplr(times)], [Yciu, fliplr(Ycil)], [0 0 0], 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
hold on;
plot(times, Ym, 'k', 'linewidth', 2)

yl =  ylim; % use for topoplot

vline(0, 'color', 'k', 'linestyle', ':', 'linewidth', 1);
hline(0, 'color', 'k', 'linestyle', ':', 'linewidth', 1);
hline(min(yl), 'color', 'w', 'linewidth', 2); % erase x-axis line

xlabel('time, ms', 'fontsize', 24)
ylabel(ylab, 'fontsize', 24)
xlim(xlimits);
set(gca, 'fontsize', 24);
set(gcf, 'color', 'w');

% set Y-axis to 3 ticks
L = get(gca,'YLim');
if 0 > L(1) && 0 < L(2)
    set(gca,'YTick',[L(1) 0 L(2)]);
else
    set(gca,'YTick',[L(1) L(2)]);
end

% set title
paramtitle = strrep(parameter, 'beta_', '');
title(paramtitle, 'fontsize', 24);
%plot(times, Y, 'color', [0 0 0 .1])
%hold on
%harea = area(sigX, sigY, 'FaceColor', [.5 .5 .5]);
%children=get(harea,'children');
%set(children,'FaceAlpha',0.05)
box off
hold off

% Make the topoplot
% inset into lineplot

% create smaller axes in top right, and plot on it
a = axes('Position',[.65 .65 .3 .3]);
box off

cfg         = [];
cfg.layout  = lay;
cfg.xlim    = [sigtimes(1) sigtimes(end)] / 1000; % back to sec scale here
cfg.zlim    = [-.5 .5] * min(abs(yl));
cfg.style   = 'straight';
cfg.comment = 'no';
cfg.marker  = 'off';

%cfg.highlight = 'on';
%cfg.highlightsymbol = '.';
%cfg.highlightsize = 12;
%cfg.highlightchannel = channels; % cell array of cell arrays
ft_topoplotER(cfg, gavg); 
add_sig_chans(lay, channels, chanprop, 'o', 'k', 24);

set(gcf, 'PaperPosition', [0 0 1 1]);
set(gcf, 'PaperPositionMode', 'manual');
exportgraphics(gcf,'temp.png')
close gcf
insert = imread('temp.png');
%A = squeeze(insert(:,:,1) == 255 & ...
%            insert(:,:,2) == 255 & ...
%            insert(:,:,3) == 255);
%insert = image(insert);
%insert.AlphaData = A;
imshow(insert)
delete('temp.png')

h = gcf;

set(h, 'PaperPositionMode', 'auto');
