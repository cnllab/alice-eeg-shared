function [out] =  do_alice_regression(dat, cols, names, residcols, docontrol)

%% out = function do_alice_regression(cfg, dat);
% perform single-trial regression between some (set of) variables
% encoded in 'trialinfo' and each datapoint across time and channels
%
% All predictors are centered before being fit.
%
%   dat - output from ft_timelockanalysis with keeptrials='yes'
%   cols - column indices into 'trialinfo' indicating which factors
%       to include as regression predictors against single-trial data
%   names - cell array of names for each predictor (these need to be
%       valid matlab variable names)
%   residcols - (optional) cell array with N vector pairs
%       First member: Column index into 'cols' indicating term to be residualized
%       Second member: Column indices into 'cols' against each will be residualized
%   docontrol - (optional) logical indicating whether a "control" model
%   should be fit by permuting the order of the predictor variables.
%
% out - timelockanalysis structure with new 'beta' field with beta weights
%       per timepoint/channel for each factor in the regression.
%       individual trials are NOT returned
%
% NOTE: The "control" option is used to generate datasets for cluster-based permutation
% testing. The values in each column indicated by "controlcols" are randomly permuted
% prior to being fit against the data. The result is a set of beta values
% for each predictor under the null hypothesis that the (now permuted)
% predictor has no relationship to the data. These datasets can be treated
% as belonging to a within-subjects control condition (standing in for if
% the subjects had listend to a different story but then were analyzed with
% the same computational model); by permuting these datasets a-la Maris &
% Oostenveld, we generate a null distribution of effects.
%
% 1/25/16

% cols = [8, 9, 21];
% names = {'len', 'frq', 'cfgsurp'};


if nargin < 5 || isempty(docontrol)
    docontrol = 0;
else
    docontrol = 1;
end

if nargin < 4 || isempty(residcols)
    doresid = 0;
else
    doresid = 1;
end

if length(cols) ~= length(names)
    error('must provide the same number of column indices and column names');
end

dat = ft_struct2double(dat);

nfactors = length(cols) + 1; %+1 for the intercept
ntrials = size(dat.trialinfo, 1);

%% Sort out predictors

X = [ones(ntrials, 1), dat.trialinfo(:,cols)];

% center predictors
for i = 2:size(X,2)
    X(:,i) = X(:,i) - mean(X(:,i), 'omitnan');
end

% if requested, do residualization
if doresid
    Xr = X;
    for i = 1:length(residcols)
        [~, ~, r] = regress(X(:,residcols{i}{1}), X(:,residcols{i}{2}));
        Xr(:,residcols{i}{1}) = r; % replace with residuals
    end
    X = Xr;
end

% if requested, permute regressors for control regression
if docontrol
    randidx = randsample(1:size(X,1), size(X,1));
    X = X(randidx,:);
end

%% run regressions

switch dat.dimord
    case 'rpt_chan_time' % time-domain data
        nchans = length(dat.label);
        ntimes = length(dat.time);
        % 'betas': regressors x channels x time
        betas = zeros(nfactors, nchans, ntimes);
        for c = 1:nchans
            for t = 1:ntimes
                y = dat.trial(:,c,t);
                betas(:,c,t) = regress(y, X);
            end
        end
        out = ft_timelockanalysis([], dat);
    case 'rpt_chan_freq_time' % time-freq domain data
        nchans = length(dat.label);
        ntimes = length(dat.time);
        nfreqs = length(dat.freq);
        % 'betas': regressors x channels x frequencies x time
        betas = zeros(nfactors, nchans, nfreqs, ntimes);
        for c = 1:nchans
            for f = 1:nfreqs
                for t = 1:ntimes
                    y = dat.powspctrm(:,c,f,t);
                    if any(isnan(y))
                        betas(:,c,f,t) = NaN;
                    else
                        betas(:,c,f,t) = regress(y, X);
                    end
                end
            end
        end
        out = ft_freqdescriptives([], dat);
end
% each beta gets its own 2D/3D matrix in the time-locked output

out.betas.intercept = squeeze(betas(1,:,:,:)); %
for b = 2:nfactors
    eval(sprintf('out.betas.%s = squeeze(betas(b,:,:,:));', names{b-1}));
end

end
