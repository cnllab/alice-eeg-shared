function [] = run_paramaterized_regressors(regFile, regColumns, regPredictors, datFiles, folder) 

%% function [] = run_paramaterized_regressors(regfile, regcolumns, regpredictors, datfiles, folder) 

% - regFile: tab delimited file with regressors to test (one at a time)
% - regColumns: Column start index or start and end indices into regfile
% - regPredictors: names of CONTROL predictors to include in single-subject
% regressions 
% - datFiles: cell array that points to cleaned single-trial Alice data
% - folder: folder to put all output
%
% Saves into target folder...
%   - stats for each regressor
%   - summary of "p < 0.05" per regressor
%   - results fig for "sig" effects
%
% Last updated 1/25/18

%% set up variables

keyFile = 'AllAlice Triggers Spreadsheet_Order.csv';
orderColumn = 5;    % index to dat.trialinfo; see proc.varnames
lexfuncColumn = 13; % same
numPermutations = 1000; % number permutations to run for statistics
globalAlpha = 0.05;

reg = readtable(regFile, 'filetype', 'text');
switch(length(regColumns))
    case 1
        R = reg(:, regColumns:end);
    case 2
        R = reg(:, regColumns(1):regColumns(2));
end

regValues = table2array(R);

nReg = size(R, 2);
regNames = R.Properties.VariableNames';

%% Get the "Order" values to use as a key (4th numeric column)
[key] = csvread(keyFile, 1, 1); % ignore first row, first col
order = key(:,4); % "order" column in keyfile

clear key reg

%% Add new annotations and run regressions
       
% loop over datasets (est. 4 min per datafile)
for d = 1:length(datFiles)
    load(datFiles{d}, 'dat', 'proc');
    sid = proc.subject;

    %% add the regressors to trialinfo
    datOrder = dat.trialinfo(:,orderColumn); % Order in data
    keeps = ismember(order, datOrder);       % logical for if the target word is in the dataset
    dat.trialinfo = horzcat(dat.trialinfo, regValues(keeps,:));                
    proc.varnames = [proc.varnames, regNames'];

    %% Replace NaN with zeros
    dat.trialinfo(isnan(dat.trialinfo)) = 0;

    %% select just content words
    cfg = [];
    cfg.trials = dat.trialinfo(:,lexfuncColumn) == 1; % LEX
    sub_l = ft_selectdata(cfg, dat);

    trialcount_lex(d) = size(sub_l.trialinfo, 1);
    
    % loop over regressors (est. XX s per regressor)
    for r = (1:nReg)
        regName = cell2mat(regNames(r));
        fprintf('\nRegressing %s for %s...\n\n', regName, sid);

        %% get predictor indices, including new predictor
        theseNames = regPredictors;
        theseNames{end+1} = regName;
        theseCols = find(ismember(proc.varnames, theseNames));

        %% do regression & control            
        % no residulization
        dat_l_b     = do_alice_regression(sub_l, theseCols, theseNames, {});
        dat_l_cb    = do_alice_regression(sub_l, theseCols, theseNames, {}, 1);

        %% save betas 
        % betaFiles tracks subjects nested under regressors
        sid = proc.subject;
        betaFiles{r}{d} = [folder '/' regName '_' sid '_betas.mat'];
        save(betaFiles{r}{d}, 'dat_l_b', 'dat_l_cb');%
        clear dat_l_b dat_l_cb 
    end
    clear dat proc sub_l
end
fprintf('Completed per-subject regressions\n');

save([folder '/trialcount.mat'], 'trialcount_lex'); 

%% Group analysis per regressor

% debugging:
%betaFiles = {};
%for r = 1:nReg
%    regName = regNames{r};
%    for d = 1:length(datFiles)
%        load(datFiles{d}, 'proc');
%        sid = proc.subject;
%        betaFiles{r}{d} = [folder '/' regName '_' sid '_betas.mat'];
%    end
%end

isSig = zeros(length(regNames), 1);
minP = ones(length(regNames), 1); 

for r = (1:nReg)
    regName = cell2mat(regNames(r));
    fprintf('\nRunning group stats for %s\n\n', regName);

    %% load betas for group analysis 
    % betaFiles: subjects nested under regressors
    betas_l = {};
    conbetas_l = {};
    for i = 1:length(betaFiles{r})
        load(betaFiles{r}{i});
        betas_l{i} = flip_betas(dat_l_b);
        conbetas_l{i} = flip_betas(dat_l_cb);    
    end

    %% Run target group statistics
    betaName = ['beta_' regName];
    stat = do_beta_stats(betas_l, conbetas_l, betaName, numPermutations);
    
    %% Summarize results
    minP(r) = min(stat.prob(:));
    isSig(r) = minP(r) < globalAlpha;
    
    if isSig(r)
        [sigtimes sigchans sigchanprop polarity pvals] = get_sig_clusters2(stat);
        % make plot
        plot_group_betas(betas_l, betaName, sigchans{1}, sigtimes{1}, sigchanprop{1}, '\beta, \muV');
        print([folder '/' regName '_betaplot'], '-dpng', '-r100');
        close gcf
    end
    
    %% Save statistics
    statFileName = [folder '/' regName '_stat.mat'];    
    save(statFileName, 'stat');
    
end
fprintf('\nCompleted group stats\n', regName);

%% Save summary table (don't overwrite!)
tablename = '/results-summary0';
isfile = exist([folder tablename '.txt'], 'file');
i = 1;
while isfile % check if file exists
    tablename = [tablename(1:end-1) num2str(i)];
    isfile = exist([folder tablename '.txt'], 'file');
    i = i+1;
end

summaryTable = table(regNames, isSig, minP);
writetable(summaryTable, [folder tablename '.txt']);

fprintf('Files saved to %s.\n', folder)
fprintf('All done.\n')
