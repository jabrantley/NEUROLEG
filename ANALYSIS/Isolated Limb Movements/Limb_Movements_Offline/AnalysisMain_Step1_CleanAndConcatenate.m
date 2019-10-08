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
addpath(genpath(fullfile(basepath,'Brainstorm','brainstorm3','toolbox')));
addpath(genpath(fullfile(basepath,'Custom MATLAB Functions')));
addpath(genpath(fullfile(basepath,'shoeeg')));
addpath(fullfile(basepath,'eeglab'));
eeglab;
close all;
clc;

% Clean up
clearvars -except drive datadir savedir basedir EEG

% Create empty EEG struct
EEGEMPTY = EEG; EMG = []; GONIO = []; STIM = []; OPAL = [];

% Get files for each subject
subs = {'TF01','TF02','TF03'};
    
% Loop through each subject, concatenate, and process
for aa = 1:length(subs)
    
    % Get variables
    vars = who;
    
    % Create empty EEG struct
    EEGCONCAT             = EEGEMPTY;
    EEGCONCAT.srate       = 200;
    EEGCONCAT.eogdata     = [];
    EEGCONCAT.trialbreaks = [];
    updated_latency       = [];
    
    % Initialize data structures for concatenated data
    EMGCONCAT   = [];
    GONIOCONCAT = [];
    OPALCONCAT  = [];
    STIMCONCAT  = [];
    
    % Get variables
    vars2 = who;
    
    % Get eeg files for each subject
    eegfiles = dir(fullfile(datadir,[subs{aa} '-T*-eeg.mat']));
    
    % Create counter for non-EEG data
    trial_cnt = 1;
    
    % Loop through each subject
    for bb = 1:length(eegfiles)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %          Load EEG          %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        thisfile  = eegfiles(bb).name;
        splitname = strsplit(thisfile,'-');
        load(fullfile(datadir,thisfile));
        EEG.data  = double(EEG.data);
        EEGRAW    = EEG;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %     Get trigger times      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get index of start and stop or S2 and S4 in events struct
        if strcmpi(splitname{2},'T00')
            start_idx = find(strcmpi({EEG.event.type},'Start'));
            stop_idx  = find(strcmpi({EEG.event.type},'Stop'));
            
        else
            start_idx = find(strcmpi({EEG.event.type},'S  2'));
            stop_idx  = find(strcmpi({EEG.event.type},'S  4'));
        end
        % Get start and stop sample index
        start = EEG.event( start_idx ).latency;
        stop  = EEG.event( stop_idx  ).latency;
        % Get events struct
        event_old = EEG.event;
        % Find events to remove
        % events2remove = setdiff(1:length(event_old),[start_idx,stop_idx]);
        events2remove = [find(1:length(event_old)<start_idx),...
            find(1:length(event_old)>stop_idx)];
        % Remove events
        event_old(events2remove) = [];
        % Shift latency by start time
        shifted_latency = [event_old.latency] - event_old(1).latency + 1;
        % Adjust latency of each event
        for kk = 1:length(event_old)
            event_old(kk).latency =  shifted_latency(kk);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  Highpass Filter @ 0.3 Hz  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        EEG.data = transpose(filterdata('data',EEG.data','srate',EEG.srate,...
            'highpass',0.01,'highorder',2,'visualize','off'));
        EEG.eogdata = transpose(filterdata('data',EEG.eogdata','srate',EEG.srate,...
            'highpass',0.01,'highorder',2,'visualize','off'));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %     H-infinity filter      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Run Hinf now so convergence period can be cut from beginning of
        % data.
        EEG.data = double(EEG.data);
        bipolarEOG = [EEG.eogdata(3,:)-EEG.eogdata(4,:);
            EEG.eogdata(1,:)-EEG.eogdata(2,:);
            ones(1,size(EEG.data,2))];
        hinfdata = hinfinity(EEG.data',bipolarEOG','parallel','on','gamma',1.05);
        %EEG.prehinf = EEG.data;
        EEG.data = hinfdata';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %   Cut Data @ Start/Stop    %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        eeg_trim = EEG.data(:,start:stop);
        eog_trim = EEG.eogdata(:,start:stop);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %         CONCATENATE        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        EEGCONCAT.data = cat(2,EEGCONCAT.data,eeg_trim);
        EEGCONCAT.eogdata{bb} =  eog_trim;
        EEGCONCAT.numpnts{bb} = size(eeg_trim,2);
        EEGCONCAT.trialbreaks =  cat(2,EEGCONCAT.trialbreaks,bb-1.*ones(1,size(eeg_trim,2)));
        all_latency = [event_old.latency];
        if bb == 1
            adjusted_latency = all_latency;
        else
            adjusted_latency = all_latency - all_latency(1) + 1 + updated_latency(end);
        end
        updated_latency = cat(2,updated_latency,adjusted_latency);
        
        EEGCONCAT.allevents = event_old;
        EEGCONCAT.event = cat(2,EEGCONCAT.event,event_old);
        
        if ~strcmpi(splitname{2},'T00') % baseline trials not included
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %          Find EMG          %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            emgfile = fullfile(datadir,strjoin({splitname{1:2},'emg.mat'},'-'));
            load(emgfile);
            tempEMG = EMG.data(:,start:stop);
            EMG.data = tempEMG;
            EMGCONCAT = cat(1,EMGCONCAT,EMG);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %          Find GONIO        %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            goniofile = fullfile(datadir,strjoin({splitname{1:2},'gonio.mat'},'-'));
            load(goniofile);
            tempGONIO = GONIO.data(:,start:stop);
            GONIO.data = tempGONIO;
            GONIOCONCAT = cat(1,GONIOCONCAT,GONIO);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %          Find OPAL         %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            opalfile = fullfile(datadir,strjoin({splitname{1:2},'opal.mat'},'-'));
            load(opalfile);
            % Get opal fields
            opal_fields = fields(OPAL);
            for aaa = 1:length(opal_fields)
                % Loop through opal fields
                if isempty(OPAL.(opal_fields{aaa}))
                    % do nothing
                elseif isa(OPAL.(opal_fields{aaa}),'double')
                    tempOPAL = OPAL.(opal_fields{aaa});
                    OPAL.(opal_fields{aaa}) = tempOPAL(:,start:stop);
                    
                elseif isa(OPAL.(opal_fields{aaa}),'struct')
                    opal_fields_fields = fields(OPAL.(opal_fields{aaa}));
                    for bbb = 1: length(opal_fields_fields)
                        tempOPAL = OPAL.(opal_fields{aaa}).(opal_fields_fields{bbb});
                        if isa(tempOPAL,'double')
                            OPAL.(opal_fields{aaa}).(opal_fields_fields{bbb}) = tempOPAL(:,start:stop);
                        else
                            % do nothing
                        end
                    end
                end
            end
            OPALCONCAT = cat(1,OPALCONCAT,OPAL);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %          Find STIM         %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            stimfile = fullfile(datadir,strjoin({splitname{1:2},'stim.mat'},'-'));
            load(stimfile);
            STIMCONCAT = cat(1,STIMCONCAT,STIM);
            
            % Increment counter
            trial_cnt = trial_cnt + 1;
        end
    end
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Load electrode locations  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load(fullfile(datadir,strcat(splitname{1},'-chanlocs.mat')));
    EEGCONCAT.chanlocs = chanlocs;
    
    % Clean up workspace
    keepvars(vars2);
    
    % Update EEGCONCAT
    EEGCONCAT.nbchan = size(EEGCONCAT.data,1);
    EEGCONCAT.pnts = size(EEGCONCAT.data,2);
    EEGCONCAT.xmin = 0;
    EEGCONCAT.xmax = EEGCONCAT.pnts / EEGCONCAT.srate;
    EEGCONCAT.process = {'Cut@ExpStart/Stop','Concatenate','HPFilt@0.1Hz','Hinf'};
    
    % Update events
    for bb = 1:length(EEGCONCAT.event)
        EEGCONCAT.event(bb).latency = updated_latency(bb);
    end
    
    % Final struct update
    EEGCONCAT      = eeg_checkset(EEGCONCAT);
    EEGCONCAT.data = double(EEGCONCAT.data);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                            %
    %     DATA HAVE ALREADY      %
    %     BEEN HINF AND HP       %
    %     FILTERED.              % 
    %                            %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EEG = EEGCONCAT;
    % Update missing information in EEG struct
    EEG = eeg_checkset(EEG);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %            ASR             %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EEG = clean_artifacts(EEG, ...
        'FlatlineCriterion', 10,...
        'Highpass',         'off',... % disabled
        'ChannelCriterion',  'off',... % disabled
        'LineNoiseCriterion',  'off',... % disabled
        'BurstCriterion',    10,...
        'WindowCriterion',   'off',...
        'BurstCriterionRefMaxBadChns', []);
    EEG.data = double(EEG.data);
    EEG.process = [EEG.process, 'ASR'];
    
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
    %            ICA             %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EEG = pop_runica(EEG,'icatype','runica');
    EEG.icaact = EEG.icaweights*EEG.icasphere*EEG.data;
    % Check if ICA results are complex
    if any(~isreal(EEG.icaact))
        dataRank = rank(double(EEG.data'));
        error(['Imaginary activations. EEG data rank is ' num2str(dataRank)]);
    end
    EEG.process = [EEG.process, 'ICA'];
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %           DIPFIT           %
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     fprintf('\n===== Step 9: Run DIPFIT =====\n\n');
%     % for BCI
%     dipfit_obj_bci = class_DIPFIT('input',EEG);
%     process(dipfit_obj_bci);
%     EEG = dipfit_obj_bci.postEEG;
%     
    % FINAL STEP - SAVE DATA
    savefile(EEG,'EEG',savedir,[subs{aa} '-ALLTRIALS-eeg.mat'])
    keepvars(vars);
    vars = who;
    
end

