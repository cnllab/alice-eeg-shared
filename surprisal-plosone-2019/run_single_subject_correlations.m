%% Alice EEG: Single-subject regressions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTANT NOTE
% The single-subject control regressions in the statistical analysis have 
% a random component and the seed from the original analysis was not saved. 
% Accordingly, statistical tests (e.g. timing and topography of effects) 
% may quantitatively differ from the published results.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('path/to/fieldtrip/toolbox'); % https://github.com/fieldtrip/fieldtrip
ft_defaults

addpath('../helpers/') % add helper scripts

% Directory for pre-processed data
data_dir   = 'path/to/preprocessed/data/directory';

% Destination for regression results
dest_dir = 'path/to/save/single/subject/regression/results';

%% Set up for regressions

load('datasets.mat') % object 'use' has the usable datasets

% load one subject's data to set up for running regressions
load([data_dir '/' use{1}], 'dat', 'proc'); 

% get column numbers for target variables
islex      = find(strcmp(proc.varnames, 'IsLexical'));
order      = find(strcmp(proc.varnames, 'Order'));
frq        = find(strcmp(proc.varnames, 'LogFreq'));
wm_frq     = find(strcmp(proc.varnames, 'LogFreq_Prev'));
wp_frq     = find(strcmp(proc.varnames, 'LogFreq_Next'));
sndpwr     = find(strcmp(proc.varnames, 'SndPower'));
sentence   = find(strcmp(proc.varnames, 'Sentence'));
pos        = find(strcmp(proc.varnames, 'Position'));

ngram      = find(strcmp(proc.varnames, 'NGRAM'));
rnn        = find(strcmp(proc.varnames, 'RNN'));
cfgp       = find(strcmp(proc.varnames, 'CFG'));

%% Main analysis: whole-head regressions

cols     = [sentence pos frq wm_frq wp_frq sndpwr ngram rnn cfgp];
colnames = {'sentence', 'pos', 'frq', 'wm_frq', 'wp_frq', 'sndpwr', 'ngram', 'rnn', 'cfgp'};
% Iterate over the last 3 cols for separate
% regressions-per-target-term:
separate_regs = {logical([ 1 1 1 1 1 1 0 0 0]), ... % just controls
                 logical([ 1 1 1 1 1 1 1 0 0]), ... % just add ngram
                 logical([ 1 1 1 1 1 1 0 1 0]), ... % just add rnn
                 logical([ 1 1 1 1 1 1 0 0 1])};    % just add cfg
% ...no residualization!

% % Correlation Matrix
% % load arbitrary subject's data
% corr(dat.trialinfo(:,cols))
% 
% ans =
% 
%    1.0000    0.0219   -0.0200   -0.0146   -0.0223   -0.0141   -0.0045    0.0029   -0.0043
%    0.0219    1.0000   -0.0508    0.0037   -0.0215   -0.0230   -0.0568   -0.0690   -0.0257
%   -0.0200   -0.0508    1.0000   -0.1481   -0.1502   -0.0080   -0.0059   -0.0340    0.0764
%   -0.0146    0.0037   -0.1481    1.0000    0.0020   -0.0173   -0.1520   -0.1679   -0.0505
%   -0.0223   -0.0215   -0.1502    0.0020    1.0000   -0.0071   -0.0282   -0.0086   -0.0249
%   -0.0141   -0.0230   -0.0080   -0.0173   -0.0071    1.0000    0.0481    0.0460    0.0044
%   -0.0045   -0.0568   -0.0059   -0.1520   -0.0282    0.0481    1.0000    0.8431    0.2853
%    0.0029   -0.0690   -0.0340   -0.1679   -0.0086    0.0460    0.8431    1.0000    0.3313
%   -0.0043   -0.0257    0.0764   -0.0505   -0.0249    0.0044    0.2853    0.3313    1.0000

fails = []; trialcount_func = []; trialcount_lex = [];
for i = 1:length(use) %
    try
        % load original data
        load([data_dir '/' use{i}], 'dat', 'proc');
    
        % select just function words and just content words
        cfg        = []; 
        cfg.trials = dat.trialinfo(:,islex) == 0; % FUNC
        sub_f      = ft_selectdata(cfg, dat);
        cfg.trials = dat.trialinfo(:,islex) == 1; % LEX
        sub_l      = ft_selectdata(cfg, dat);
        
        trialcount_func(i) = size(sub_f.trialinfo, 1);
        trialcount_lex(i)  = size(sub_l.trialinfo, 1);
        
        % do regression & control (residcols is EMPTY)
        % Separate regression per target term!
        %   1 = ngram, 2 = rnn, 3 = cfg
        % We'll recombine the resulting betas sensibly below
        for r = 1:length(separate_regs)
            dat_f_b{r}  = do_alice_regression(sub_f, cols(separate_regs{r}), colnames(separate_regs{r}), []);
            dat_f_cb{r} = do_alice_regression(sub_f, cols(separate_regs{r}), colnames(separate_regs{r}), [], 1);         
            dat_l_b{r}  = do_alice_regression(sub_l, cols(separate_regs{r}), colnames(separate_regs{r}), []);
            dat_l_cb{r} = do_alice_regression(sub_l, cols(separate_regs{r}), colnames(separate_regs{r}), [], 1);
        end
        % save betas
        sid = proc.subject;
        save([dest_dir '/' sid '_betas.mat'],  ...
            'dat_f_b', ...
            'dat_f_cb', ...
            'dat_l_b', ...
            'dat_l_cb');%
        clear dat proc sub_f sub_l dat_l_b dat_l_cb dat_f_b dat_f_cb
    catch
        warning('dataset fail')
        fails = [fails i];
        continue
    end
end

% Tweak the resulting betas:
% - combine the SEPARATELY ESTIMATED target betas into one structure for
% easier processing down-stream
% - add RMS(coefs) across *both* function & content words 
%   ...add this to *content* data-structures

betas = dir([dest_dir '/*_betas.mat']); 
betas = {betas(:).name}; 

for b = 1:length(betas)
    load([dest_dir '/' betas{b}]);

    % combine separately-estimated terms
    % do this with eval() to loop     
    structs = {'dat_l_b', 'dat_l_cb', 'dat_f_b', 'dat_f_cb'};
    for s = 1:length(structs)
        eval(sprintf('old_%s = %s;', structs{s}, structs{s}));
        eval(sprintf('%s = old_%s{1};', structs{s}, structs{s}));
        eval(sprintf('%s.betas.ngram = old_%s{2}.betas.ngram;', structs{s}, structs{s}));
        eval(sprintf('%s.betas.rnn = old_%s{3}.betas.rnn;', structs{s}, structs{s}));
        eval(sprintf('%s.betas.cfgp = old_%s{4}.betas.cfgp;', structs{s}, structs{s}));
    end
    
    % Do RMS 
    observed = cat(3, dat_l_b.betas.ngram, ...
                      dat_l_b.betas.rnn, ...
                      dat_l_b.betas.cfgp, ...
                      dat_f_b.betas.ngram, ...
                      dat_f_b.betas.rnn, ...
                      dat_f_b.betas.cfgp );
    observed_rms = sqrt(mean(observed.^2, 3));
                  
    control = cat(3, dat_l_cb.betas.ngram, ...
                     dat_l_cb.betas.rnn, ...
                     dat_l_cb.betas.cfgp, ...
                     dat_f_cb.betas.ngram, ...
                     dat_f_cb.betas.rnn, ...
                     dat_f_cb.betas.cfgp );
    control_rms = sqrt(mean(control.^2, 3));
    
    dat_l_b.betas.RMS  = observed_rms;
    dat_l_cb.betas.RMS = control_rms;
    
    % testing: expect blue (real) > red (fake) line
    %plot(dat_l_b.time, mean(dat_l_b.betas.RMS, 1))
    %hold on;
    %plot(dat_l_b.time, mean(dat_l_cb.betas.RMS, 1), 'r')
    
    save([dest_dir '/' betas{b}], ...
        'dat_l_b', ...
        'dat_f_b', ...
        'dat_l_cb', ...
        'dat_f_cb');
    clear('observed_rms', 'control_rms', 'dat_l_b', 'dat_l_cb', 'dat_f_b', 'dat_f_cb');
end
    


