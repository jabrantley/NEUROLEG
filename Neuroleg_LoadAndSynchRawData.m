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
% Trigger layout:
%
%        Start synch trigger                         End synch trigger
%               |                                          |
%               |    Start trial            Stop trial     |
%               |         |                     |          |
%               V         V                     V          V
%
% EEG:  -------S1------- S2--------------------S4---------S1------------
%
%
%                                  oPar.
%            oPar.         | ----- ExpDur ----- |            oPar.
% STIM:   startTrigger---START-----------------STOP-------stopTrigger
%(oPar)                  oPar.
%                      RunStartT
%
%      1        __                                          __
%              |  |                                        |  |
% BIO: 0 ______|  |________________________________________|  |_________
%
%
%
%       Rising ^  | Falling                         Rising ^  | Falling
%        Edge  |  | Edge                             Edge  |  | Edge
% OPAL:  ______|  v________________________________________|  v_________
%
%
%
% Written by: Justin Brantley - justin.a.brantley@gmail.com
% 08/07/2019: Date created

close all;
clear variables;
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
    
    % Save non-trial specific data
    savefile( impedance,  'impedance',  savedir,[subs{ii} '-impedance.mat'])
    savefile( chanlocs,   'chanlocs',   savedir,[subs{ii} '-chanlocs.mat'])
    copyfile(fullfile(experimentlog.folder,experimentlog.name),...
        fullfile(savedir,experimentlog.name));
    
    
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
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                                                                     %
    %                           Synchronize Data                          %
    %                                                                     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % NOTE: This assumes that the rising edge at the beginning and end
    % of trial are perfectly synched and do not require time lagging.
    % Only resampling is done to make timeseries same length.
    % Loop through EEG files using eegfiles(*).name to get other data
    for jj = 1:length(eegfiles)
        
        % Trial name
        eegfile = eegfiles(jj).name;
        splitname = strsplit(eegfile,'.vhdr');
        trialname = splitname{1};
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                                                 %
        %               Load and Trim EEG                 %
        %                                                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Load EEG
        EEG = pop_loadbv(eegdir,eegfile);
        % Find EEG S1 trigger
        eegSynch   = find(strcmpi({EEG.event.type},'S  1'));
        % Cut data at triggers
        eegStart  = EEG.event(eegSynch(1)).latency;
        eegStop   = EEG.event(eegSynch(2)).latency;
        eegtrim   = double(EEG.data(:,eegStart:eegStop));
        eegtime   = (0:1:size(eegtrim,2)-1)./EEG.srate;
        event_old = EEG.event;
        % Adjust markers
        for kk = 1:length(EEG.event)
            EEG.event(kk).latency = EEG.event(kk).latency - eegStart + 1;
        end
        % Remove any before S1
        EEG.event(1:eegSynch(1)-1) = [];
        EEG.event(eegSynch(2)+1:end) = [];
        % Update urevent
        EEG.urevent = EEG.event;
        EEG.eventdescription = {EEG.event.type};
        
        % Get trial start (S2) and trial stop (S4) markers
        trialStart = find(strcmpi({EEG.event.type},'S  2'));
        trialStop  = find(strcmpi({EEG.event.type},'S  4'));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                                                 %
        %       Load, Trim, and Resample Biometrics       %
        %                                                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Define EMG path and load
        biometricsfile = fullfile(biometricsdir,[trialname '.txt']);
        biometrics = loadBiometrics(biometricsfile);
        biometrics.srate = 1000;
        
        % Get EMG triggers: TTL pulse on digital channel
        biometricsSynch = find(diff([0 biometrics.trigger'])==1);
        biometricsStart = biometricsSynch(1);
        if strcmpi(subs{ii},'TF03') && strcmpi(trialname,'Walk01')
             biometricsStop  = biometricsSynch(3); % TF03, Walk01 had extra trigger
        else
             biometricsStop  = biometricsSynch(2);
        end
        % Check if large difference between trigger times
        trig_diff_EEG_BIO = abs(((eegStop - eegStart) -(biometricsStop - biometricsStart)) / 1000);
        if trig_diff_EEG_BIO > 0.5
            error('Difference between EEG and Biometrics is greater than 0.5 seconds.')
        end
        biometricstrim = double(biometrics.rawdata(biometricsStart:biometricsStop,:));
        biometricstime   = (0:1:size(biometricstrim,1)-1)./biometrics.srate;
        
        % Resample to EEG time
        biometrics_resampled = resampledata(biometricstrim',eegtime,EEG.srate);
        
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                                                 %
        %          Load, Trim, and Resample OPAL          %
        %                                                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Load OPAL
        opalfile = fullfile(opaldir,[trialname '.h5']);
        opalLoaded = 0;
        if exist(opalfile,'file')==2
            % load opal data
            opal = loadOpal(opalfile);
            opalLoaded = 1;
            opaltimeold = (opal.time - opal.time(1))./1e6;
            % Get number of opal sensors
            numIMUs = length(opal.acc);
            % Initialize empty cell for gravity compensated acc
            opal.acc_gc = cell(numIMUs,1);
            % Gravity compensation
            for kk = 1:numIMUs
                % Get IMU data
                IMU = [opal.acc{kk}, opal.gyr{kk}, opal.mag{kk}];
                % Orientation using Extended Kalman Filter
                acc_gc = Orientation_Estimation(IMU); clear IMU
                %                 % Resample data to EEG sampling rate
                %                 acc_temp   = resample(opal.acc{kk},opaltimeold,EEG.srate);
                %                 gyr_temp   = resample(opal.gyr{kk},opaltimeold,EEG.srate);
                %                 mag_temp   = resample(opal.mag{kk},opaltimeold,EEG.srate);
                %                 accgc_temp = resample(acc_gc,opaltimeold,EEG.srate);
                % Store trimmed data in opal structure
                %                 opal.acc{kk}    = acc_temp;%(timesIDX,:);
                %                 opal.gyr{kk}    = gyr_temp;%(timesIDX,:);
                %                 opal.mag{kk}    = mag_temp;%(timesIDX,:);
                opal.acc_gc{kk} = acc_gc;%_temp;%(timesIDX,:);
                clear acc_temp gyr_temp mag_temp accgc_temp
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                                                 %
        %             Load stimulus pattern               %
        %                                                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Load stimulus
        stimLoaded = 0;
        if ~strcmpi(trialname,'PreRest') && ~strcmpi(trialname,'Walk01')
            stimLoaded = 1;
            stimfile = [subs{ii} '-' trialname '_AmpMapping.mat'];
            load(fullfile(stimulusdir,stimfile));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                                                 %
        %            Downsample data to 200 Hz            %
        %                                                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        new_srate = 200; % Hz
        % Downsample EEG
        eegDS = transpose(resample(eegtrim',new_srate,EEG.srate));
        % Create new EEG time vector
        timevec = (0:1:size(eegDS,2)-1)./new_srate;
        % Downsample biometrics and resample to EEG
        bioDS = resample(biometrics_resampled',new_srate,EEG.srate);
        bioDS = resampledata(bioDS',timevec,new_srate);
        
        % Downsample opal and resample to EEG
        if opalLoaded
            opalDS = struct('time',timevec,...
                'acc',[],'gyr',[],'mag',[],'acc_gc',[],...
                'id',[]);
            % Resample OPAL time to EEG sampling rate
            opaltimenew = opaltimeold(1):1/new_srate:opaltimeold(end);
            % Get OPAL triggers
            opalSynch = find(strcmpi({opal.triggers.label},'Received external trigger 0V->+V edge'));
            opalStart = opaltimenew >= (opal.triggers(opalSynch(1)).time - opal.time(1))/1e6; % values greater than first time
            if strcmpi(subs{ii},'TF03') && strcmpi(trialname,'Walk01')
                opalStop  = opaltimenew <= (opal.triggers(opalSynch(3)).time - opal.time(1))/1e6; % values less than last time
            else
                opalStop  = opaltimenew <= (opal.triggers(opalSynch(2)).time - opal.time(1))/1e6; % values less than last time
            end
            timesIDX  = find(bsxfun(@eq,opalStart,opalStop));
            opaltimes = opaltimenew(timesIDX); % get overlapping values
            trig_diff_EEG_OPAL = abs((eegStop - eegStart)/1000 - (opaltimes(end)-opaltimes(1)));
            if trig_diff_EEG_OPAL > 0.5
                error('Difference between EEG and OPAL is greater than 0.5 seconds.')
            end
            for kk = 1:numIMUs
                % Downsample acceleration and then resample to EEG size
                acctemp           = resample(opal.acc{kk},opaltimeold,new_srate);%,new_srate,EEG.srate);
                opalDS.acc{kk}    = resampledata(acctemp',timevec,new_srate);
                % Downsample gyroscope then resample to EEG size
                gyrtemp           = resample(opal.gyr{kk},opaltimeold,new_srate);
                opalDS.gyr{kk}    = resampledata(gyrtemp',timevec,new_srate);
                % Downsample magnetometer then resample to EEG size
                magtemp           = resample(opal.mag{kk},opaltimeold,new_srate);
                opalDS.mag{kk}    = resampledata(magtemp',timevec,new_srate);
                % Downsample gravity compensated acc then resample to EEG size
                acc_gc_temp       = resample(opal.acc_gc{kk},opaltimeold,new_srate);
                opalDS.acc_gc{kk} = resampledata(acc_gc_temp',timevec,new_srate);
            end
            opalDS.id = opal.id;
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                                                 %
        %            Rename variables and save            %
        %                                                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Update EEG struct
        EEG.data = eegDS;
        EEG.times = 1:size(EEG.data,2);
        EEG.pnts = size(EEG.data,2);
        EEG.srate = new_srate;
        EEG.eogdata = EEG.data([17,22,28,32],:);
        EEG.data([17,22,28,32],:) = [];
        
        % Separate gonio and EMG
        isGonio = find(strcmpi(chanunits,'deg'));
        isEMG   = find(strcmpi(chanunits,'mV'));
        
        % Get gonio
        GONIO.data  = bioDS(isGonio,:);
        GONIO.joint = channames(isGonio);
        GONIO.srate = new_srate;
        
        % Get EMG
        EMG.data   = bioDS(isEMG,:);
        EMG.muscle = channames(isEMG);
        EMG.srate  = new_srate;
        
        % Update opal
        if opalLoaded
            OPAL = struct('Head',[],'LeftToe',[],'LeftHeel',[],...
                'RightToe',[],'RightHeel',[],'Extra',[]);
            % Get ID and name
            opalID = {'Head','719','LeftToe','741','LeftHeel','738',...
                'RightHeel','742','RightToe','722','Extra','738'};
            for kk = 1:numIMUs
                findID = find(strcmpi(opal.id{kk}(end-2:end),opalID));
                opalname = opalID{findID-1};
                OPAL.(opalname) = struct('acc',opalDS.acc{kk},...
                    'gyr',opalDS.gyr{kk},...
                    'mag',opalDS.mag{kk},...
                    'acc_gc',opalDS.acc_gc{kk},...
                    'id',opalDS.id{kk});
            end
            OPAL.time = opalDS.time;
        end
        % SAVE FILES
        alltrialname = {'PreRest','T00','Trial01','T01','Trial02','T02',...
            'Trial03','T03','Trial04','T04','Walk01','W01'};
        
        % Create new trial name
        newtrialname = alltrialname{find(strcmpi(trialname,alltrialname))+1};
        
        % save files - if greater than 2GB, using -v7.6 switch
        savefile( EEG,   'EEG',   savedir,[subs{ii} '-' newtrialname '-eeg.mat'])
        savefile( EMG,   'EMG',   savedir,[subs{ii} '-' newtrialname '-emg.mat'])
        savefile( GONIO, 'GONIO', savedir,[subs{ii} '-' newtrialname '-gonio.mat'])
        if opalLoaded
            savefile( OPAL,  'OPAL',  savedir,[subs{ii} '-' newtrialname '-opal.mat'])
        end
        if stimLoaded
            savefile( oPar,  'STIM',  savedir,[subs{ii} '-' newtrialname '-stim.mat'])
        end
    end
    
end % end ii
