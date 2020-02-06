%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                  PROCESS DATA - CONCATENATED TRIALS                     %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% In this analysis, the trials for each subject are concatenated into a
% single file. Hinf is run on each before concatenating to remove bias and
% eyeblinks. Then ICA is run. DIPFIT has not been run since we do not yet
% have subject's head model.

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
datadir  = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_RAW_SYNCHRONIZED_EEG_FMRI_DATA');
savedir  = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_PROCESS_SYNCHRONIZED_EEG_FMRI_DATA');
basepath = fullfile(drive,'Dropbox','Research','Analysis','MATLAB FUNCTIONS');

% Add paths
%addpath(genpath(fullfile(basepath,'Brainstorm','brainstorm3','toolbox')));
%addpath(genpath(fullfile(basepath,'Custom MATLAB Functions')));
addpath('D:\Dropbox\Research\Analysis\NEUROLEG\utils');
addpath(genpath(fullfile(basepath,'shoeeg')));
%addpath(fullfile(basepath,'eeglab'));
addpath(fullfile(basepath,'eeglab2019_1'));
eeglab;
close all;
clc;

% Clean up
%clearvars -except drive datadir savedir basepath EEG

% Create empty EEG struct
EEGEMPTY = EEG; EMG = []; GONIO = []; STIM = []; OPAL = [];

% Get files for each subject
subs = {'TF01','TF02','TF03'};
    
% Loop through each subject, concatenate, and process
for aa = 1%2:length(subs)
    
    % Get variables
    vars = who;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                              %
    %  EEG DATA HAVE ALREADY       %
    %  BEEN HINF AND HP FILTERED   %
    %  @ 0.1 Hz.                   %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load(fullfile(datadir, [subs{aa}, '-ALLTRIALS-eeg.mat'  ]));
    load(fullfile(datadir, [subs{aa}, '-ALLTRIALS-emg.mat'  ]));
    load(fullfile(datadir, [subs{aa}, '-ALLTRIALS-gonio.mat']));
    load(fullfile(datadir, [subs{aa}, '-ALLTRIALS-opal.mat' ]));
    load(fullfile(datadir, [subs{aa}, '-ALLTRIALS-stim.mat' ]));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %            ASR             %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EEGOLD = EEG;
    EEG = clean_artifacts(EEG, ...
        'FlatlineCriterion', 10,...
        'Highpass',         'off',... % disabled
        'ChannelCriterion',  'off',... % disabled
        'LineNoiseCriterion',  'off',... % disabled
        'BurstCriterion',    10,...
        'WindowCriterion',   'off',...
        'BurstCriterionRefMaxBadChns', []);
    EEG.data = double(EEG.data);
    EEG.process = [EEG.process, 'ASR,burst=10'];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %            CAR             %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add channel of zeros for ref - proper rank
    EEG.nbchan = EEG.nbchan+1;
    EEG.data(end+1,:) = zeros(1, EEG.pnts);
    EEG.chanlocs(1,EEG.nbchan).labels = 'initialReference';
    EEG = pop_reref(EEG, []);
    EEG.refchan = EEG.data(end,:); % save ref channels
    EEG = pop_select( EEG,'nochannel',{'initialReference'});
    EEGCAR = EEG; EEG.data = double(EEG.data);
    EEG.process = [EEG.process, 'CAR'];
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   HP FILT @ 2 Hz FOR ICA   %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Higher HP filt band to improve ICA decomposition. Weights will be
    % applied to post ASR data after completing cleaning.
    EEG.preICAeeg = EEG.data;
    EEG.data = transpose(filterdata('data',EEG.data','srate',EEG.srate,...
            'highpass',2,'highorder',2,'visualize','off'));
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %         RELICA             %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %EEG = pop_relica(EEG,100);
    EEG = relica(EEG,100,'beamica','point',pwd,'local','parpools',1);
    
    EEG.icaact = EEG.icaweights*EEG.icasphere*EEG.data;
    % Check if ICA results are complex
    if any(~isreal(EEG.icaact))
        dataRank = rank(double(EEG.data'));
        error(['Imaginary activations. EEG data rank is ' num2str(dataRank)]);
    end
    EEG.process = [EEG.process, 'ICA'];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           DIPFIT           %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('\n===== Step 9: Run DIPFIT =====\n\n');
    % for BCI
    mrifile = [subs{aa} '-SurfVolMNI.nii'];
    dipfit_obj_bci = class_DIPFIT('input',EEG,'mri_input',mrifile);
    process(dipfit_obj_bci);
    EEG = dipfit_obj_bci.postEEG;
    
    % FINAL STEP - SAVE DATA
    %savefile(EEG,'EEG',savedir,[subs{aa} '-ALLTRIALSNOCAR-eeg.mat'])
    %savefile(EEG,'EEG',savedir,[subs{aa} '-ALLTRIALS-eeg.mat'])
    savefile(EEG,'EEG',savedir,[subs{aa} '-ALLTRIALSNOFILT-eeg.mat'])
    keepvars(vars);
    vars = who;
    
end

