%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                  PROCESS DATA - CONCATENATED TRIALS                     %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% In this analysis, the trials for each subject are concatenated into a
% single file. Hinf is run on each before concatenating to remove bias and
% eyeblinks. Then ICA and DIPFIT are run

% NOTE: BASELINE EEG IS INCLUDED IN ANALYSIS. BASELINE FROM OTHER DATA ARE
% NOT INCLUDED BECAUSE THEY ARE NOT NEEDED FOR THIS ANALYSIS.

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
savedir  = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_CONCAT_SYNCHRONIZED_EEG_FMRI_DATA');
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
subjects = {'TF01','TF02','TF03'};

% Loop through each subject, concatenate, and process
for aa = 1:length(subjects)
    
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
    eegfiles = dir(fullfile(datadir,[subjects{aa} '-T*-eeg.mat']));
    
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  Load electrode locations  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if bb == 1
            EEGCONCAT.chanlocs = load(fullfile(datadir,strcat(splitname{1},'-chanlocs.mat')));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  Highpass Filter @ 0.3 Hz  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        EEG.data = transpose(filterdata('data',EEG.data','srate',EEG.srate,...
            'highpass',0.3,'highorder',2,'visualize','off'));
        EEG.eogdata = transpose(filterdata('data',EEG.eogdata','srate',EEG.srate,...
            'highpass',0.3,'highorder',2,'visualize','off'));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %         CONCATENATE        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        EEGCONCAT.data = cat(2,EEGCONCAT.data,EEG.data);
        EEGCONCAT.eogdata =  cat(2,EEGCONCAT.eogdata,EEG.eogdata);
        EEGCONCAT.numpnts{bb} = EEG.pnts;
        EEGCONCAT.trialbreaks =  cat(2,EEGCONCAT.trialbreaks,trial_cnt.*ones(1,size(EEG.data,2)));
        EEGCONCAT.allevents = EEG.event;
        EEGCONCAT.event = cat(2,EEGCONCAT.event,EEG.event);
        all_latency = [EEG.event.latency];
        if bb == 1
            adjusted_latency = all_latency;
        else
            adjusted_latency = all_latency + updated_latency(end);
        end
        updated_latency = cat(2,updated_latency,adjusted_latency);
        
        if ~strcmpi(splitname{2},'T00') % baseline trials not included
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %          Find EMG          %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            emgfile = fullfile(datadir,strjoin({splitname{1:2},'emg.mat'},'-'));
            load(emgfile);
            EMGCONCAT = cat(1,EMGCONCAT,EMG);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %          Find GONIO        %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            goniofile = fullfile(datadir,strjoin({splitname{1:2},'gonio.mat'},'-'));
            load(goniofile);
            GONIOCONCAT = cat(1,GONIOCONCAT,GONIO);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %          Find OPAL         %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            opalfile = fullfile(datadir,strjoin({splitname{1:2},'opal.mat'},'-'));
            load(opalfile);
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
    
    % Clean up workspace
    keepvars(vars2);
    
    % Update EEGCONCAT
    EEGCONCAT.nbchan = size(EEG.data,1);
    EEGCONCAT.pnts = size(EEG.data,2);
    EEGCONCAT.xmin = 0;
    EEGCONCAT.xmax = EEGCONCAT.pnts / EEGCONCAT.srate;
    % Update events
    for bb = 1:length(EEGCONCAT.event)
        EEGCONCAT.event(bb).latency = updated_latency(bb);
    end
    
    % Update name
    EEG   = EEGCONCAT;
    EMG   = EMGCONCAT;
    GONIO = GONIOCONCAT;
    OPAL  = OPALCONCAT;
    STIM  = STIMCONCAT;
    
    % Clean up workspace
    keepvars(vars);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     H-infinity filter      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EEG.data = double(EEG.data);
    bipolarEOG = [EEG.eogdata(3,:)-EEG.eogdata(4,:);
        EEG.eogdata(1,:)-EEG.eogdata(2,:);
        ones(1,size(EEG.data,2))];
    hinfdata = hinfinity(EEG.data',bipolarEOG','parallel','on');
    %EEG.prehinf = EEG.data;
    EEG.data = hinfdata';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Highpass Filter @ 1 Hz   %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EEG.data = transpose(filterdata('data',EEG.data','srate',EEG.srate,...
        'highpass',1.0,'highorder',2,'visualize','off'));
    
    % Add additional information to structure
    EEG.filename = 'TF01-ALLTRIALS-eeg.mat';
    EEG = eeg_checkset(EEG); EEG.data = double(EEG.data);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %            ASR             %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EEG = clean_artifacts(EEG, ...
        'FlatlineCriterion', 10,...
        'Highpass',         'off',... % disabled
        'ChannelCriterion',  'off',... % disabled
        'LineNoiseCriterion',  'off',... % disabled
        'BurstCriterion',    8,...
        'WindowCriterion',   'off',...
        'BurstCriterionRefMaxBadChns', []);
    EEG.data = double(EEG.data);
    
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           DIPFIT           %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('\n===== Step 9: Run DIPFIT =====\n\n');
    % for BCI
    dipfit_obj_bci = class_DIPFIT('input',EEG);
    process(dipfit_obj_bci);
    EEG = dipfit_obj_bci.postEEG;
    
    % FINAL STEP - SAVE DATA
    savefile(EEG,'EEG',savedir,thisfile)
    keepvars(vars);
    vars = who;
    
end

