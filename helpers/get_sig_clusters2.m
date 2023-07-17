function [sigtimes sigchans sigchansprop polarity pvals] = get_sig_clusters(stat, alpha, chnthresh)

%% function [sigtimes sigchans] = get_sig_clusters(stat)
% Extracts sigtimes and sigchans from a fieldtrip stat object
% For each significant cluster, polarity = 1, -1 (pos, neg)
%
% sigtimes describe the temporal limits of the cluster(s) exceeding alpha
% - sigchans exceed alpha for any time
% - sigchansprop is a proportion of time over the whole cluster that each chan was sig 

if nargin < 3
    chnthresh = 0.5;
end

if nargin < 2
    alpha = 0.05;
end

% initialize vars
sigtimes     = {};
sigchans     = {};
sigchansprop = {};
polarity     = [];
pvals        = [];
c = 0; % tracks # sig clusters

% positive clusters
for i = 1:length(stat.posclusters)
    if stat.posclusters(i).prob < alpha
        c = c + 1;
        sigtimes_idx    = any(stat.posclusterslabelmat == i, 1);
        nsigtimes       = sum(sigtimes_idx);
        sigchans_prop   = sum(stat.posclusterslabelmat(:, sigtimes_idx) == i, 2) / nsigtimes;
        sigchans_idx    = sigchans_prop > 0;
        sigtimes{c}     = stat.time(sigtimes_idx);
        sigchans{c}     = stat.label(sigchans_idx);
        sigchansprop{c} = sigchans_prop(sigchans_idx);
        polarity(c)     = 1; % for positive
        pvals(c)        = stat.posclusters(i).prob;
    else
        break % clusters are ordered by alpha
    end
end
    
% negative clusters
for i = 1:length(stat.negclusters)
    if stat.negclusters(i).prob < alpha
        c = c + 1;
        sigtimes_idx    = any(stat.negclusterslabelmat == i, 1);
        nsigtimes       = sum(sigtimes_idx);
        sigchans_prop   = sum(stat.negclusterslabelmat(:, sigtimes_idx) == i, 2) / nsigtimes;
        sigchans_idx    = sigchans_prop > 0;
        sigtimes{c}     = stat.time(sigtimes_idx);
        sigchans{c}     = stat.label(sigchans_idx);
        sigchansprop{c} = sigchans_prop(sigchans_idx);
        polarity(c)     = -1; % for negative
        pvals(c)        = stat.negclusters(i).prob;
    else
        break % clusters are ordered by alpha
    end
end