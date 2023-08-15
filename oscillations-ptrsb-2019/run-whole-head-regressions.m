%% Alice EEG: Single-subject whole-head regressions for bracket count

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTANT NOTE
% The single-subject control regressions in the statistical analysis have 
% a random component and the seed from the original analysis was not saved. 
% Accordingly, statistical tests (e.g. timing and topography of effects) 
% may quantitatively differ from the published results.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('path/to/fieldtrip/toolbox'); % https://github.com/fieldtrip/fieldtrip
ft_defaults

addpath('../helpers') % add helper scripts

% Directory for pre-processed data
data_dir   = 'path/to/preprocessed/data';

% Destination for regression results
dest_dir = 'path/to/directory/to/save/output';

%% Set up for regressions

load('datasets.mat', 'use');
use = strcat(data_dir, '/', use);

use_linear = {'Order', 'LogFreq', 'LogFreq_Prev', 'LogFreq_Next', 'SndPower', 'cfg_bu'};
use_log    = {'Order', 'LogFreq', 'LogFreq_Prev', 'LogFreq_Next', 'SndPower', 'log_cfg_bu'}; % created in the loop

% load node-counts
new = readtable('AliceChapterOne-Nodecounts.csv');
new = new(:,{'Order', 'cfg_bu'});

%% Run single-subject regressions

fails = [];
trialcount_func = [];
trialcount_lex = [];

for i = 1:length(use); %
    try
        % load original data
        load(use{i}, 'dat', 'proc');
        
        fprintf('Running regressions for %s\n', proc.subject);

        order_idx = find(strcmp('Order', proc.varnames));
        lexfunc_idx = find(strcmp('IsLexical', proc.varnames));

        ord           = new.Order;              % get Order for alignment
        dat_ord       = dat.trialinfo(:,order_idx);     % Order in data
        keeps         = ismember(ord, dat_ord); % logical for if the target word is in the dataset
        dat.trialinfo = horzcat(dat.trialinfo, new{keeps,'cfg_bu'});
        proc.varnames = [proc.varnames, 'cfg_bu'];
        
        dat.trialinfo(isnan(dat.trialinfo)) = 0;

        brack_idx   = find(strcmp('cfg_bu', proc.varnames));

        % add log close brackets (add small constant to avoid ~20 zeros)
        nvars = length(proc.varnames);
        log_brackets             = log(dat.trialinfo(:,brack_idx) + 0.0001);
        dat.trialinfo(:,nvars+1) = log_brackets;
        proc.varnames{nvars+1}   = 'log_cfg_bu';

        [~, use_linear_idx] = intersect(proc.varnames, use_linear);
        [~, use_log_idx]    = intersect(proc.varnames, use_log);
        
        use_linear_labels = proc.varnames(use_linear_idx); % so index and varname orders are matched
        use_log_labels    = proc.varnames(use_log_idx);

        % divide by word-type
        cfg = [];
        cfg.trials = dat.trialinfo(:,lexfunc_idx) == 1; % LEX
        sub_l = ft_selectdata(cfg, dat);
        cfg.trials = dat.trialinfo(:,lexfunc_idx) == 0; % FUNC
        sub_f = ft_selectdata(cfg, dat);
        
        trialcount_lex(i)  = size(sub_l.trialinfo, 1);
        trialcount_func(i) = size(sub_f.trialinfo, 1);
        
        % do regression & control
        residcols = {}; % no residualization

        dat_lin_l_b  = do_alice_regression(sub_l, use_linear_idx, use_linear_labels, residcols);
        dat_lin_l_cb = do_alice_regression(sub_l, use_linear_idx, use_linear_labels, residcols, 1);
        
        dat_lin_f_b  = do_alice_regression(sub_f, use_linear_idx, use_linear_labels, residcols);
        dat_lin_f_cb = do_alice_regression(sub_f, use_linear_idx, use_linear_labels, residcols, 1);

        dat_log_l_b  = do_alice_regression(sub_l, use_log_idx, use_log_labels, residcols);
        dat_log_l_cb = do_alice_regression(sub_l, use_log_idx, use_log_labels, residcols, 1);

        dat_log_f_b  = do_alice_regression(sub_f, use_log_idx, use_log_labels, residcols);
        dat_log_f_cb = do_alice_regression(sub_f, use_log_idx, use_log_labels, residcols, 1);

        % save betas
        sid = proc.subject;
        save([dest_dir '/' sid '_betas.mat'], 'dat_lin_l_b', 'dat_lin_l_cb', ...
                                              'dat_lin_f_b', 'dat_lin_f_cb', ...
                                              'dat_log_l_b', 'dat_log_l_cb', ...
                                              'dat_log_f_b', 'dat_log_f_cb');%
                                          
   clear   dat proc sub_l sub_f ... 
                dat_lin_l_b dat_lin_l_cb ...
                dat_lin_f_b dat_lin_f_cb ...
                dat_log_l_b dat_log_l_cb ...
                dat_log_f_b dat_log_f_cb;
   
    catch
        warning('dataset fail')
        fails = [fails i];
        continue
    end
end

save([dest_dir '/' 'trialcount.mat'], 'trialcount_lex', 'trialcount_func');

fprintf('[Finished single-subject regressions]\n');
