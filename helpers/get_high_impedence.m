function [bads imps labels] = get_high_impedence(dataset, t)

%% function bads = get_high_impedence(dataset, t)
% Gets sensors with high impedences from BrainProducts .eeg data
%
% dataset - filename of data (suffixed with .eeg, vmrk, or no suffix)
% t - threshold for "high" impedence, channels with impedence >= this value
%       (default = 25)
% are returned
%
% bads - cell array with names of bad channels
% 
% updated 9/3/15

% dataset = 'R0003_20150603_TonesTest61_01.eeg'

if nargin < 2
    t = 25;
end

[path name sfx] = fileparts(dataset);

switch sfx
    case '.eeg'
        dataset([end-3:end+1]) = '.vhdr';
    case '.vhdr' % do nothing
    otherwise
        dataset = [dataset '.vhdr'];
end

%% import impedences

idx = 1;
fid = fopen(dataset);
C = textscan(fid, '%s', 'delimiter', '\n');
numlines = length(C{1});
for i = 1:numlines
    ln = sscanf(C{1}{i}, '%s %*[n^]');
    if (strcmp(ln, 'Impedance') == 0)
        idx = idx + 1;
    else
        break; % idx+1 will begin the relevant lines
    end
end

% Check that impedences were found
if idx >= numlines
    warning('No impedences recorded with this dataset! [press space to continue]')
    bads = [];
    imps = [];
    labels = [];
    pause
    return
end

labels = {};
imps = zeros(numlines-idx, 1);

for i = 1:(numlines-idx - 1) % last line needs special treatment...
    ln = textscan(C{1}{idx+i}, '%s %s %s %*[n^]');
    labels{i} = ln{2}{1}(1:(end-1)); % skip trailing colon
    if strcmp(ln{3}{1}, 'Disconnected!')
        warning('Disconnection during impedence recording; no impedences recorded! [press space to continue]')
        bads = []; % disconnected electrodes -> exit with a warning
        imps = [];
        labels = [];
        pause;
        return
    elseif strcmpi(ln{3}{1}, 'out of range!') || strcmpi(ln{3}{1}, 'out')
        imps(i) = 999; % handle out-of-range values
    else
        imps(i) = str2num(ln{3}{1});
    end
end

%finally, do ground
ln = textscan(C{1}{numlines}, '%s %s %*[n^]');
labels{end+1} = ln{1}{1}(1:end-1);
imps(end) = str2num(ln{2}{1});

fclose(fid);

%% which are over threshold?

badidx = find(imps >= t);
bads = labels(badidx);

%% If REF was bad, throw a warning
isref = strfind(bads, 'REF');
if ~isempty(cell2mat(isref)) % is REF amongst the bads?
    warning('Reference channel exceeds impedence threshold!')
end

        