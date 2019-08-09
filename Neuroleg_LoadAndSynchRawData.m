%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                     LOAD AND SYNCHRONIZE DATA                           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The purpose of this file is to load the raw data, synch at the hardware
% triggers, and labels using software markers. Raw synched data will be
% saved with the following extension:
%
%            TF0{a}-T/W{b}-{c}.{ext}
%
% where,
%            a: subject number
%            b: T (trial) or W (walk) + trial number
%            c: filetype (e.g., eeg, emg, kin, chanlocs, impedance, etc.)
%            d: extension (e.g., .mat, .pdf, .mp4, etc.)
%
% Written by: Justin Brantley - justin.a.brantley@gmail.com
% 08/07/2019: Date created

close all;
clear all;
clc;

% Define dropbox drive
if strcmpi(getenv('username'),'justi')% WHICHPC == 1
    drive = 'D:';
elseif strcmpi(getenv('username'),'jabrantl') %WHICHPC == 2
    drive = 'E:';
end

% Get files in directory
addpath(genpath(cd));

% Define directories - use data located on NAS
datadir  = '\\bmi-nas-01\Contreras-UH\Neural Control of Powered Artifical Legs\EEG-FMRI-WALK DATA';
savedir  = '\\bmi-nas-01\Contreras-UH\Neural Control of Powered Artifical Legs\EEG-FMRI-WALK DATA\_RAW_SYNCHRONIZED_DATA';

% Add eeglab
addpath(fullfile(drive,'Dropbox\Research\Analysis\MATLAB FUNCTIONS','eeglab'));
eeglab; close all; clc
clearvars -except drive datadir savedir

% Specify subjects
subs = {'TF01','TF02','TF03'};

% Loop through each subject
for ii = 1:length(subs)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                                                                     %
    %             Get subject data that is not trial specific             %
    %                                                                     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Impedance path
    impedancedir  = fullfile(datadir,subs{ii},'UH','IMPEDANCE');
    impedancepre  = importdata(fullfile(impedancedir,[subs{ii} '-PreImpedance.txt']),'\t');
    impedancepost = importdata(fullfile(impedancedir,[subs{ii} '-PostImpedance.txt']),'\t');
    impedance = struct('channames',{impedancepre.textdata{19:end,2}}',...
        'pre',impedancepre.data,'post',impedancepost.data);
    
    % Import chanlocs
    captrakdir = fullfile(datadir,subs{ii},'UH','CAPTRAK');
    captrakfile = dir(fullfile(captrakdir,'*.bvct'));
    chanlocs = readcaptrak(fullfile(captrakdir,captrakfile.name));
    
    % Get experiment log
    experimentlog = dir(fullfile(datadir,subs{ii},'UH','EXPERIMENTLOG','*.pdf'));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                                                                     %
    %                Load EEG, BIOMETRICS, OPAL, and STIMULUS             %
    %                                                                     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    % EEG path
    eegdir = fullfile(datadir,subs{ii},'UH','EEG'); % define eeg path
    eegfiles = dir(fullfile(eegdir,'*.vhdr')); % get all header files
    
    % Biometrics path
    biometricsdir = fullfile(datadir,subs{ii},'UH','BIOMETRICS','Export'); % define emg path
      
    % Opal path
    opaldir = fullfile(datadir,subs{ii},'UH','OPAL');
    
    % Stimulus path
    stimulusdir = fullfile(datadir,subs{ii},'UH','STIMULUS');
    
    % Loop through EEG files using eegfiles(*).name to get other data
    for jj = 2:length(eegfiles)
        
        % Trial name
        eegfile = eegfiles(jj).name;
        splitname = strsplit(eegfile,'.vhdr');
        trialname = splitname{1};
        
        % Load EEG
        EEG = pop_loadbv(eegdir,eegfile);
        
        % Define EMG path and load
        biometricsfile = fullfile(biometricsdir,[trialname '.txt']);
        biometrics = loadBiometrics(biometricsfile,8);
        
        % Get channel names and units
        hdr = biometrics.header;
        channames = cell(size(hdr,1)-2,1);
        chanunits = cell(size(hdr,1)-2,1);
        for kk = 2:size(hdr,1)-1
            splitname1 = strsplit(hdr{kk},',');
            splitname2 = strsplit(splitname1{1},'''');
            splitname3 = strsplit(splitname1{3},':');
            % Get sensor name
            channames{kk-1} = splitname2{2};
            % Get units
            chanunits{kk-1} = splitname3{2}(2:end);
        end
        clear splitname1 splitname2 splitname3 hdr
        
        % Load OPAL
        opalfile = fullfile(opaldir,[trialname '.h5']);
        if exist(opalfile,'file')==2
            % load opal data
            opal = loadOpal(opalfile);
            % Get number of opal sensors
            numIMUs = length(opal.acc);
            % Initialize empty cell for gravity compensated acc
            opal.acc_gc = cell(numIMUs,1);
            % Gravity compensation
            for kk = 1%:numIMUs
                % Get IMU data
                IMU = [opal.acc{1}, opal.gyr{1}, opal.mag{1}];
                % Orientation using Extended Kalman Filter
                acc_gc = Orientation_Estimation(IMU);
                % Store in opal structure
                opal.acc_gc{kk} = acc_gc;
            end
        end
        
        % Load stimulus
        if ~strcmpi(trialname,'PreRest')
            stimfile = [subs{ii} '-' trialname '_AmpMapping.mat'];
            load(fullfile(stimulusdir,stimfile));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                                                                 %
        %                  Synchronize data at triggers                   %
        %                                                                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Find EEG S1 trigger
        eegSynch   = find(strcmpi({EEG.event.type},'S  1'));
        % Cut data at triggers
        eegStart  = EEG.event(eegSynch(1)).latency;
        eegStop   = EEG.event(eegSynch(2)).latency;
        eegtrim   = double(EEG.data(:,eegStart:eegStop));
        event_old = EEG.event;
        % Adjust markers
        for kk = 1:length(EEG.event)
            EEG.event(kk).latency = EEG.event(kk).latency - eegStart + 1;
        end
        % Remove any before S1
        EEG.event(1:eegSynch(1)-1) = [];
        EEG.event(eegSynch(2)+1:end) = [];
        % Get EMG triggers: TTL pulse on digital channel
        emgSynch   = find(diff([0 biometrics.trigger'])==1);
        % Get OPAL triggers
        opalSynch  = find(strcmpi({opal.triggers.label},'Received external trigger 0V->+V edge'));
        
        
        % Get trial start (S2) and trial stop (S4) markers
        trialStart = find(strcmpi({EEG.event.type},'S  2'));
        trialStop  = find(strcmpi({EEG.event.type},'S  4'));
        
        
        
    end
    
end % end ii
