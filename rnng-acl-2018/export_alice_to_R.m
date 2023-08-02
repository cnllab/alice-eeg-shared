function [out] = export_alice_to_R(dataFiles, regFile, regColumns, chans, times, regressorNames, outputFile, dataNames)

%% function [out] = export_alice_to_R(dataFiles, regFile, regColumns, chans, times, regressorNames, outputFile, dataNames)
%
% regFile, regColumns can also be cell arrays (must be paired)
% chans, times, can also be cell arrays (must be paired)
% dataNames used to label outputs when multiple chans, times applied
%
%
% output will include columns named:
%   subject name
%   order index
%   lexfunc (1=lex, 0 = func)
%   data
%   and whatever is listed in regressorNames
%
% Internally, assumes that regFile, regColumn, chan, time are all cell
% arrays with multiple values to be brought together in the output
%
% 2/12/2018

%load('../ana5-surprisal-paper/datasets.mat', 'd');
%dataFiles = strcat('../ana5-surprisal-paper/', d);
%regFile = 'paramaterized2/alice180-predictors-log.txt';
%regColumns = 3;
%chans = {'1' , '2', '3', '4'};
%times = 0.200:0.002:0.400;
%regressorNames = {'LogFrqHAL', 'sentence', 'position', 'sndpwr','lstm256Surprisal'}
% outputFile = 'test-R-export.csv';

%% set up variables

keyFile = 'AllAlice Triggers Spreadsheet_Order.csv';
keyOrder = 4; % index to "Order" in keyFile
alwaysPredictors = {'Order', 'IsLexical'};

if nargin < 8;          dataNames = {'data'};      end
if ~iscell(regFile);    regFile = {regFile};       end
if ~iscell(regColumns); regColumns = {regColumns}; end
if ~iscell(chans);      chans = {chans};           end
if ~iscell(times);      times = {times};           end

%% add new annotations

for i = 1:length(regFile)
    reg = readtable(regFile{i}, 'filetype', 'text');
    switch(length(regColumns{i}))
        case 1
            R{i} = reg(:, regColumns{i}:end);
        case 2
            R{i} = reg(:, regColumns{i}(1):regColumns{i}(2));
    end
end

%make sure names aren't duplicated across regressorFiles
if length(R) > 1
    startNames = R{1}.Properties.VariableNames;
    append = 2; 
    for i = 2:length(R)
        newNames = R{i}.Properties.VariableNames;
        [~, sameIdx] = intersect(newNames, startNames);
        newNames(sameIdx) = strcat(newNames(sameIdx), num2str(append));
        R{i}.Properties.VariableNames = newNames;
        append = append+1;
    end
end

% stack regressors column-wise
R = [R{:}];

regValues = table2array(R);

nReg = size(R, 2);
regNames = R.Properties.VariableNames';

%% Get the "Order" values to use as a key 
[key] = csvread(keyFile, 1, 1); % ignore first row, first col
order = key(:,keyOrder); 

clear key reg

%% Loop over data files

Predictors = [];
Data       = {};
Subject    = {};

r = 1; % track new rows created in 'Data'

for d = 1:length(dataFiles)
    load(dataFiles{d}, 'dat', 'proc');
    sid = proc.subject;
    fprintf('Processing dataset %s...\n', sid)

    %% add new annotations to trialinfo
    orderColumn = find(strcmp('Order', proc.varnames));
    datOrder = dat.trialinfo(:,orderColumn);   % Order in data
    keeps = ismember(order, datOrder); % logical for if the target word is in the dataset
    dat.trialinfo = horzcat(dat.trialinfo, regValues(keeps,:));                
    proc.varnames = [proc.varnames, regNames'];
    
    %% Subset to target predictors
    % handle special keyword 'all'
    
    if strcmp(regressorNames, 'all')
        theseCols = 1:length(proc.varnames);
    else
        theseCols = find(ismember(proc.varnames, [alwaysPredictors, regressorNames]));
    end
    
    keepPred = dat.trialinfo(:,theseCols);

    if r == 1 % ensure table variable names are in the right order!
        predictorTableNames = proc.varnames(theseCols);
    end
    
    %% Fetch channel and time indices
    CIDX = {}; TIDX = {};
    for i = 1:length(chans)
        [~, CIDX{i}] = intersect(dat.label, chans{i});
        [~, TIDX{i}] = intersect(single(dat.time), single(times{i}));
    end
        
    %% loop over trials
    nTrial = size(dat.trial, 1);
    for t = 1:nTrial
        % for each <chan,time> pair...
        for i = 1:length(CIDX)
            selectedData = dat.trial(t,CIDX{i},TIDX{i});
            Data{i}(r) = mean(selectedData(:));
        end
        Subject{r} = proc.subject;
        Predictors(r,:) = keepPred(t,:);
        r = r+1; % move onto the next row in 'out;
    end

    clear dat proc
end

%% Save 

% prep data
Data = cellfun(@transpose,Data,'UniformOutput',false);
Data = [Data{:}];
dataNames = matlab.lang.makeValidName(dataNames);
table1 = array2table(Data, 'VariableNames', dataNames);

% prep subject IDs
table2 = table(Subject', 'VariableNames', {'subject'});

% prep predictors
predictorTableNames = matlab.lang.makeValidName(predictorTableNames);

%predictorTableNames = strrep(predictorTableNames, '.', '_');
%predictorTableNames = strrep(predictorTableNames, ' ', '_');
%predictorTableNames = strrep(predictorTableNames, '-', '_');
%predictorTableNames = strrep(predictorTableNames, '2', 'two');
%predictorTableNames = strrep(predictorTableNames, '3', 'three');

table3 = array2table(Predictors, 'VariableNames', predictorTableNames);

writetable([table1, table2, table3], outputFile);

fprintf('Exported data to %s\n', outputFile)
fprintf('All done.\n')