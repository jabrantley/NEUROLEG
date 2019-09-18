%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%          ANALYZE EEG VS ISOLATED LIMB MOVEMENTS IN CHANEL SPACE         %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This code is for looking at EEG vs. joint movements in channel space.

close all;
clear;
clc;

% Define directory
thisdir = pwd;
idcs = strfind(pwd,'/');
parentdir = thisdir(1:idcs(end-2));

% if strcmpi(getenv('username'),'justi')% WHICHPC == 1
%     drive = 'D:';
% elseif strcmpi(getenv('username'),'jabrantl') %WHICHPC == 2
%     drive = 'E:';
% elseif strcmpi(computer,'MACI64') % macbook
%     drive = '/Volumes/STORAGE/';
% end

% Define directories
% datadir  = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_RAW_SYNCHRONIZED_EEG_FMRI_DATA');
datadir  = fullfile(parentdir,'TEMPDATA');
% basepath = fullfile(drive,'Dropbox','Research','Analysis','MATLAB FUNCTIONS');

% Add paths
%addpath(genpath(fullfile(basepath,'Brainstorm','brainstorm3','toolbox')));
addpath(genpath(fullfile(parentdir,'NEUROLEG')));
%addpath(genpath(fullfile(basepath,'Custom MATLAB Functions')));
%addpath(genpath(fullfile(basepath,'shoeeg')));
% addpath(fullfile(basepath,'eeglab'));
% eeglab;
% close all;
% clc;

% Clean up
% clearvars -except drive datadir savedir basedir EEG

% Get files for each subject
subjects = {'TF01','TF02','TF03'};

% Define frequency bands
delta = [.3 4];
alpha = [8 13];
himu  = [10 12];
theta = [4 8];
beta  = [15 30];
gamma = [30 55];
higamma = [65 100];
full  = [.3 55];
BANDS = {delta,theta,alpha,beta,gamma,full};
% bcs =  blindcolors;
% bcs = bcs([2,3,4,8,6,7],:);

% Channels to keep for analysis NOTE: FT10 is in FCz location
chans2keep = {'FC3','FC1','FT10','FC2','FC4','C4','C2','Cz',...
    'C1','C3','CP3','CP1','CPz','CP2','CP4'};
leftMotor  = {'FC3','FC1','FT10','Cz',...
    'C1','C3','CP3','CP1','CPz'};

% Filter parameters
filter_order = 2;
use_velocity = 1;
predict_type = 1; % Changes way state vector is updated. 1: use all last predicted vals. 2: use new at time t and old at t-1...t-Order

% Kalman filter parameters
KF_ORDER  = [3,10];
KF_LAGS   = [3,10];
KF_LAMBDA = logspace(-2,2,5);

% Setup parallel pool
parpool(length(chans2keep)+2);
% parpool(8);

% Fix data using some kind of shifting: See here for how off it is
% plot(GONIO(1).data)
% highlight = nan(size(GONIO(1).data(1,:)));
% highlight(rk_samples(1,1):rk_samples(1,2))=GONIO(1).data(rk_samples(1,1):rk_samples(1,2))
% hold on; plot(highlight)
% sinwave = 10*cos(move_freq*2*pi*(0:1/EEG.srate:rk_duration(1)));
% nanwave(rk_samples(1,1):rk_samples(1,2)) = sinwave;
% hold on; plot(nanwave)

% Initialize for storing R2
R2_ALL = cell(length(subjects),1);

% Loop through each subject
for aa = 1:length(subjects)
    
    % Get variables
    vars = who;
    
    % Load data
    load(fullfile(datadir,[subjects{aa},'-ALLTRIALS-eeg.mat']));
    load(fullfile(datadir,[subjects{aa},'-ALLTRIALS-emg.mat']));
    load(fullfile(datadir,[subjects{aa},'-ALLTRIALS-gonio.mat']));
    load(fullfile(datadir,[subjects{aa},'-ALLTRIALS-opal.mat']));
    load(fullfile(datadir,[subjects{aa},'-ALLTRIALS-stim.mat']));
    
    % Get channel locations
    eegchannels = {EEG.chanlocs.labels};
    chans2keepIDX = zeros(size(chans2keep));
    for bb = 1:length(chans2keep)
        chans2keepIDX(bb) = find(strcmpi(chans2keep(bb),eegchannels));
    end
    leftMotorIDX = zeros(size(leftMotor));
    for bb = 1:length(leftMotor)
        leftMotorIDX(bb) = find(strcmpi(leftMotor(bb),eegchannels));
    end
    
    % Get trial information
    trialbreaks = EEG.trialbreaks;
    movetimes = cell(size(STIM,1),2);
    stimpattern = cell(size(STIM,1),1);
    for bb = 1:size(STIM,1)
        
        % Get movement times from STIM
        rk_idx      = find(strcmpi(STIM(bb).states,'RK')); % Get movements of right knee
        rk_onset    = STIM(bb).initialDelay + STIM(bb).onsets(rk_idx); % seconds
        rk_duration = STIM(bb).Duration(rk_idx); % seconds
        rk_time     = [rk_onset; rk_onset + rk_duration]'; % seconds [onset, offset]
        rk_samples  = floor(rk_time .* EEG.srate); % sample points
        
        % Store movement times
        movetimes{bb,1} = find(EEG.trialbreaks==bb);
        movetimes{bb,2} = rk_samples;
        
        numCycles = 6;   % number of cycles
        move_freq = .5; % speed of moving dot in hz
        stimpattern{bb} = cell(size(rk_onset)); % for storing prescribed pattern
        for cc = 1:length(rk_onset)
            timevec = 0:1/EEG.srate:rk_duration(cc)+1/EEG.srate; % time vector
            sinwave = cos(move_freq*2*pi*timevec); % create sinwave
            dsinwave = diff([0 sinwave]); % velocity of wave
            stimpattern{bb}{cc} = [sinwave; dsinwave];
        end % cc = 1:length(rk_onset)
    end % bb = 1:size(STIM,1)
    
    % Common average reference
    meanEEG = repmat(mean(EEG.data,1),size(EEG.data,1),1);
    EEG.data = EEG.data - meanEEG;
    allfilt = cell(length(BANDS),1);
    
    % Initialize for storing R2
    R2_sub = cell(length(BANDS),length(chans2keep)+2);
    % Loop through each frequency band
    for bb = 1:length(BANDS)
        
        % Design filters
        bp_filt = make_ss_filter(filter_order,BANDS{bb},EEG.srate,'bandpass');
        
        % Get EEG data for channels to keep
        eegdata  = EEG.data(chans2keepIDX,:);
        filtdata = zeros(size(eegdata));
        for cc = 1:size(eegdata,1)
            % filter data - state space approach
            xnn_bp = zeros(filter_order*2,1);
            filtdata(cc,:) = use_ss_filter(bp_filt,eegdata(cc,:),xnn_bp);
        end
        allfilt{bb} = filtdata;
        
        % Initialize for storing data for each movement
        movedata = [];
        alleeg   = [];
        allgonio = [];
        count = 1;
        for cc = 1:size(movetimes,1)
            % Get data for each trial
            trialdata = filtdata(:,movetimes{cc,1});
            goniodata = GONIO(cc).data;
            % Get data for movements
            window_buffer = 1*EEG.srate; % 1 second DILATION TO ACCOUNT FOR ONSET ERROR
            for dd = 1:size(movetimes{cc,2},1)
                temp_times = movetimes{cc,2}(dd,1)-window_buffer : movetimes{cc,2}(dd,2)+window_buffer;
                alleeg   = cat(2,alleeg,trialdata(:,temp_times));
                allgonio = cat(2,allgonio,goniodata(:,temp_times));
                movedata{count,1} = trialdata(:,temp_times);
                movedata{count,2} = goniodata(:,temp_times);
                count = count + 1;
            end
        end
        
        % Loop through channels and movement windows
        % figure('color','w');
        window_size = 200;
        window_overlap = 0.5;
        window_shift = floor(window_overlap * window_size);
        
        % Train / test split
        test_trials = 4;
        train_trials  = size(movedata,1) - test_trials;
        
        % window for hilbert 
        envwindow = EEG.srate;
        
        %ax = tight_subplot(3,5);
        parfor cc = 1:length(chans2keep)+2 % for each channel
            
            % Initialize 
            testeeg  = [];
            testkin  = [];
            testidx  = [];
            trainidx = [];
            traineeg = [];
            trainkin = [];
            
            for dd = 1:size(movedata,1) % for each movement window
                
                % Use individual channels
                if cc <= length(chans2keep)
                    tempeeg = movedata{dd}(cc,:);
                    % Use all channels
                elseif cc == length(chans2keep)+1
                    tempeeg = movedata{dd};
                    % Use only left motor area for right leg move
                elseif cc == length(chans2keep)+2
                    tempeeg = movedata{dd}([1,2,3,8,9,10,11,12,13],:);
                end % end if cc <=
                
                % If delta then use raw potential, otherwise use envelope
                if bb == 1
                    datavec = tempeeg;
                else
                    [datavec, ~]= envelope(tempeeg,envwindow,'analytic'); % applies hilbert with specified window size: 1 second
                end % if bb == 1
                
                % Split training and testing
                if dd <= train_trials
                    traineeg = cat(2,traineeg,datavec);
                    trainkin = cat(2,trainkin,movedata{dd,2}(1,:));
                    trainidx = cat(2,trainidx,size(datavec,2));
                else
                    testeeg = cat(2,testeeg,datavec);
                    testkin = cat(2,testkin,movedata{dd,2}(1,:));
                    testidx = cat(2,testidx,size(datavec,2));
                end % if dd < ...
                
            end % dd = 1:size(movedata,1)
            
            % Kalman Filter object
            KF = KalmanFilter('state',trainkin,'observation',traineeg,...
                'augmented',1,'method','unscented');
            % Perform grid search
            foldIdx = cumsum([1 sum(trainidx(1:6)) sum(trainidx(7:end))-1]);
            KF.grid_search('order',KF_ORDER,'lags',KF_LAGS,'lambdaB',KF_LAMBDA,...
                'lambdaF',KF_LAMBDA,'kfold',foldIdx,'testidx',1)
            
            % Store R2 values
            R2_sub{bb,cc} = KF.R2_Train;
            
            % clean up
            % clear testeeg testkin testidx traineeg trainkin trainidx
            
        end % cc = 1:length(chans2keep)
        
    end % end BANDS{bb}
    
    % Store R2 values
    R2_ALL{aa} = R2_sub;
end

save('allR2.mat','R2_ALL')

delete(gcp);



