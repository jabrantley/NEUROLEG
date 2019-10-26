%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                  PROCESS DATA - CLEAN EEG AFTER ICA                     %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% In this analysis, ICA was run and bad ICS were removed from data.

close all;
clear;
clc;

% Define drive
if strcmpi(getenv('username'),'justi')% WHICHPC == 1
    drive = 'D:';
elseif strcmpi(getenv('username'),'jabrantl') %WHICHPC == 2
    drive = 'E:';
elseif strcmpi(computer,'MACI64') % macbook
    drive = '/Volumes/STORAGE/';
end

% Define directories
datadir  = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_PROCESS_SYNCHRONIZED_EEG_FMRI_DATA');
basepath = fullfile(drive,'Dropbox','Research','Analysis','MATLAB FUNCTIONS');
addpath(datadir);

% Add paths
addpath(genpath(fullfile(basepath,'Brainstorm','brainstorm3','toolbox')));
addpath(genpath(fullfile(basepath,'Custom MATLAB Functions')));
addpath(genpath(fullfile(basepath,'shoeeg')));
addpath(fullfile(basepath,'eeglab'));
eeglab;
close all;
clc;

% Clean up
clearvars -except drive datadir savedir basedir EEG

% Get all mat files
eegfiles = dir(fullfile(datadir, '*-eeg.mat'));

% Get variable names
vars = who;

%% Load subject data
ii = 3;
disp(eegfiles(ii).name)
load(fullfile(datadir,eegfiles(ii).name));

%% Analyze ICs
EEG.reject.gcompreject = zeros( size(EEG.icawinv,2),1);

eegplot(EEG.data,'srate',EEG.srate,'winlength',10)

EEG.icaact = EEG.icaweights*EEG.icasphere*EEG.data;
eegplot(EEG.icaact,'srate',EEG.srate,'dispchans',1,'winlength',10)
mrifile = 'TF01-SurfVolMNI.nii';
dipplot(EEG.dipfit.model,'mri',mrifile,'normlen','on','coordformat','MNI')
EEG = JB_selectcomps(EEG,1:size(EEG.icawinv,2));

%%
icnum = 1;
figure; plot(EEG.icaact(icnum,:));


