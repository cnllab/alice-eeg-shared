function [] = add_sig_chans(lay, channels, alpha, pointsymbol, pointcolor, pointsize)

%% Adds channels to an ft_topoplotER with alpha
% - copies almost verbatim from ft_plot_lay()!
% - MUST be called directly after ft_topoplotER

hold on

% get just the needed chans
[dum labelindex] = match_str(channels, lay.label);
templay.pos      = lay.pos(labelindex,:);
templay.width    = lay.width(labelindex);
templay.height   = lay.height(labelindex);
templay.label    = lay.label(labelindex);

lay = templay;

% JRB: set some options to make it work...
hpos   = 0; 
vpos   = 0;
height = [];
width  = [];
point  = true;

% JRB: copied from ft_plot_lay...

allCoords = lay.pos;
if isfield(lay, 'mask') && ~isempty(lay.mask)
  for k = 1:numel(lay.mask)
    allCoords = [allCoords; lay.mask{k}];
  end
end
if isfield(lay, 'outline') &&~isempty(lay.outline)
  for k = 1:numel(lay.outline)
    allCoords = [allCoords; lay.outline{k}];
  end
end

naturalWidth  = (max(allCoords(:,1))-min(allCoords(:,1)));
naturalHeight = (max(allCoords(:,2))-min(allCoords(:,2)));

if isempty(width) && isempty(height)
  xScaling = 1;
  yScaling = 1;
elseif isempty(width) && ~isempty(height)
  % height specified, auto-compute width while maintaining aspect ratio
  yScaling = height/naturalHeight;
  xScaling = yScaling;
elseif ~isempty(width) && isempty(height)
  % width specified, auto-compute height while maintaining aspect ratio
  xScaling = width/naturalWidth;
  yScaling = xScaling;
else
  % both width and height specified
  xScaling = width/naturalWidth;
  yScaling = height/naturalHeight;
end

X      = lay.pos(:,1)*xScaling + hpos;
Y      = lay.pos(:,2)*yScaling + vpos;
Width  = lay.width*xScaling;
Height = lay.height*yScaling;
Lbl    = lay.label;

if point
  if ~isempty(pointsymbol) && ~isempty(pointcolor) && ~isempty(pointsize) % if they're all non-empty, don't use the default
    % JRB: only change is here -- adding alpha support
    for i = 1:length(X)
        sc1 = scatter(X(i), Y(i), 'marker', pointsymbol, 'MarkerFaceColor', pointcolor, 'MarkerEdgeColor', pointcolor, 'SizeData', pointsize);
        sc1.MarkerFaceAlpha = alpha(i); 
        sc1.MarkerEdgeAlpha = alpha(i);
    end
  else
    plot(X, Y, 'marker', '.', 'color', 'b', 'linestyle', 'none');
    plot(X, Y, 'marker', 'o', 'color', 'y', 'linestyle', 'none');
  end
end

hold off
