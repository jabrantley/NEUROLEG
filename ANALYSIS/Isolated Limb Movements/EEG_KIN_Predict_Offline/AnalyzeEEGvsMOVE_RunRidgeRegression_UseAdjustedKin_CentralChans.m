%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%          ANALYZE EEG VS ISOLATED LIMB MOVEMENTS IN CHANEL SPACE         %
%                                                                         %
%               SEGMENT MOVEMENT WINDOW USING PHASE SHIFT                 %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1: Get cleaned data, segment movement windows. Address discrepancy between
%    movement onset cue and actual movement onset.
% 2: Get adjusted movement window, compute feature, train kalman filter

close all;
clear;
clc;

% Run parallel for
onCluster   = 1;
runParallel = 1;

% Define directory
thisdir = pwd;
idcs = strfind(pwd,filesep);
parentdir = thisdir(1:idcs(end-2));
addpath(genpath(fullfile(parentdir)));

% Set data dir
if onCluster
    rawdir  = fullfile('/project/contreras-vidal/justin/TEMPDATA/');
else
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
    rawdir   = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_RAW_SYNCHRONIZED_EEG_FMRI_DATA');
end

% Clean up
clearvars -except drive datadir rawdir savedir basepath EEG movedir parentdir ...
    onCluster runParallel

% Get files for each subject
subs = {'TF01','TF02','TF03'};

% Get variable names
vars = who;

% Kalman filter parameters
realtimefilt = 0;
envwindow    = 100;
zscore_data  = 1;
car_data     = 1;
useAug       = 0;
useUKF       = 0;
filter_order = 2; % bandpass filter
use_velocity = 1;
predict_type = 1; % Changes way state vector is updated. 1: use all last predicted vals. 2: use new at time t and old at t-1...t-Order
KF_ORDER     = 1;%[1,3,6,10];
KF_LAGS      = [1,2:2:10];%3,6,10];
KF_LAMBDA    = logspace(-2,2,5);

% Define movement pattern parameters
srate          = 1000;
numCycles      = 6;   % number of cycles
move_freq      = .5; % speed of moving dot in hz
window_buffer  = 3; % 1 second shift TO ACCOUNT FOR ONSET ERROR
trial_duration = 12; % instead of using exp dur from STIM, fix length for consistency

% Params for computing feature
update_rate = 1/50; % sampling time
window_overlap = 0; % % overlap 0 to 0.99

% Create movement pattern vector
timevec  = 0:1/srate:trial_duration; % time vector
sinwave  = cos(move_freq*2*pi*timevec + pi); % create sinwave
fullwave = [-1.*ones(1,window_buffer) sinwave -1.*ones(1,window_buffer)];
fullwave = rescale(fullwave);
dfullwave= diff([fullwave(1) fullwave]);
fulltime = 0:1/srate:(trial_duration+2*window_buffer/srate);

% Define frequency bands
lodelta = [.3 1.5];
delta   = [.3 4];
theta   = [4 8];
alpha   = [8 13];
himu    = [10 12];
beta    = [15 30];
gamma   = [30 55];
higamma = [65 90];
full    = [.3 50];
nodelta = [4 50];
BANDS   = {delta,theta,alpha,beta,gamma,higamma,full,nodelta,full,nodelta}; % full is used twice so one is env(full) and other is not

% Channels to keep for analysis NOTE: FT10 is in FCz location
chans2keep = {'F4','F2','Fz','F1','F3','FC3','FC1','FT10','FC2','FC4','C4','C2','Cz',...
    'C1','C3','CP3','CP1','CPz','CP2','CP4'};
channel_configs = {chans2keep};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%           SETUP PARALLEL           %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Setup parallel pool
if runParallel
    if onCluster
        poo = gcp('nocreate');
        if isempty(poo)
            try
                parpool(11);
            catch
                numCores = feature('numcores');
                parpool(numCores);
            end
        end
    else
        poo = gcp('nocreate');
        if isempty(poo)
            try
                parpool(4);
            catch
                numCores = feature('numcores');
                parpool(numCores);
            end
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%              COMPUTE LAG           %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lag1 = cell(1,length(subs));
lag2 = cell(1,length(subs));

% Loop through each subject, concatenate, and process
for aa = 1:length(subs)
    
    % Get variables
    vars = who;
    
    % Get eeg files for each subject
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-eeg.mat'   ]));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-stim.mat'  ]));
    % Load movement data
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-gonio.mat' ]));
    
    % Get trial information
    trialbreaks = EEG.trialbreaks;
    movetimes = cell(size(STIM,1),2);
    stimpattern = cell(size(STIM,1),1);
    movements = {'RK'};
    
    for aaa = 1%:length(movements) - only estimate lag for RK
        limb = movements{aaa};
        
        for bb = 1:size(STIM,1)
            
            % Get movement times from STIM
            rk_idx      = find(strcmpi(STIM(bb).states,limb)); % Get movements of right knee
            rk_onset    = STIM(bb).initialDelay + STIM(bb).onsets(rk_idx); % seconds
            rk_duration = STIM(bb).Duration(rk_idx); % seconds
            rk_time     = [rk_onset; rk_onset + rk_duration]'; % seconds [onset, offset]
            rk_samples  = floor(rk_time .* EEG.srate); % sample points
            
            % Store movement times
            movetimes{bb,1} = find(EEG.trialbreaks==bb);
            movetimes{bb,2} = rk_samples;
            
            % Get movement data
            movedata = GONIO(bb).data(aaa,:);
            
            % Create movement
            stimtime = ones(1,length(find(EEG.trialbreaks==bb)));
            stimpattern{bb} = cell(size(rk_onset)); % for storing prescribed pattern
            win_buff = 3*EEG.srate; % 1 second shift TO ACCOUNT FOR ONSET ERROR
            for cc = 1:length(rk_onset)
                % Create movement pattern vector
                timevec_temp = 0:1/EEG.srate:rk_duration(cc); % time vector
                sinwave_temp = cos(move_freq*2*pi*timevec_temp); % create sinwave
                dsinwave_temp = diff([0 sinwave_temp]); % velocity of wave
                stimpattern{bb}{cc} = [sinwave_temp; dsinwave_temp];
                
                % Store stim time
                stimtime(rk_samples(cc,1):rk_samples(cc,2)) = sinwave_temp;
                
                % Run xcorr for this window - add buffer to account for full
                % movement
                temp_time = rk_samples(cc,1)-win_buff:rk_samples(cc,2)+win_buff;
                [xcvalue,xclag] = xcorr(zscore(stimtime(temp_time)),zscore(movedata(temp_time)));
                %             [xcvalue,xclag] = xcorr(zscore(goniodata(temp_time)),zscore(stimtime(temp_time)));
                [~,maxIDX]      = max(xcvalue);
                IDXshift        = xclag(maxIDX);
                lag1{aaa,aa}    = [lag1{aaa,aa},IDXshift]; clear IDXshift
            end % cc = 1:length(rk_onset)
            
            % Run xcorr for full trial
            % [xcvalue,xclag] = xcorr(zscore(abs(stimtime-1)),zscore(filtdata2));
            [xcvalue,xclag] = xcorr(zscore(stimtime),zscore(movedata));
            [~,maxIDX]      = max(xcvalue);
            IDXshift        = xclag(maxIDX);
            lag2{aaa,aa}    = [lag2{aaa,aa}, IDXshift]; clear IDXshift
            
        end % bb = 1:size(STIM,1)
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%        SEGMENT MOVE WINDOW         %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
all_movetimes = cell(length(subs),1);
% Loop through each subject, concatenate, and process
for aa = 1:length(subs)
    
    % Get variables
    vars = who;
    
    % Get eeg files for each subject
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-eeg.mat'   ]));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-stim.mat'  ]));
    % Load movement data
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-gonio.mat' ]));
    
    % Get trial information
    trialbreaks = EEG.trialbreaks;
    stimpattern = cell(size(STIM,1),1);
    movements = {'RK','RA','LK','LA','BH'};
    movetimes = cell(length(movements),2);
    
    % Loop through each movement
    for aaa = 1:length(movements)
        limb = movements{aaa};
        movetimes{aaa,1} = cell(size(STIM,1),2);
        movetimes{aaa,2} = movements{aaa};
        
        % Loop through each trial
        for bb = 1:size(STIM,1)
            
            % Get movement times from STIM
            rk_idx      = find(strcmpi(STIM(bb).states,limb)); % Get movements of right knee
            rk_onset    = STIM(bb).initialDelay + STIM(bb).onsets(rk_idx); % seconds
            rk_duration = STIM(bb).Duration(rk_idx); % seconds
            rk_time     = [rk_onset; rk_onset + rk_duration + window_buffer]'; % seconds [onset, offset]
            rk_samples  = floor(rk_time .* EEG.srate); % sample points
            
            % Store movement times
            movetimes{aaa}{bb,1} = find(EEG.trialbreaks==bb);
            movetimes{aaa}{bb,2} = rk_samples;
            
        end % bb = 1:size(STIM,1)
    end
    all_movetimes{aa} = movetimes;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%        TRAIN KALMAN FILTER         %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop through each subject
for aa = 1:length(subs)
    
    % Get variables
    vars = who;
    
    % Get eeg files for each subject
    if realtimefilt
        load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-eeg.mat'   ]));
    else
        if onCluster
            load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-BRAINSTORM-eeg.mat'   ]));
        else
            load(fullfile(datadir, [subs{aa}, '-ALLTRIALS-BRAINSTORM-eeg.mat'   ]));
        end
        
    end
    
    % Load movement data
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-stim.mat'  ]));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-gonio.mat' ]));
    
    % Set feature window parameters
    window_size = update_rate * EEG.srate;
    window_shift = window_size - window_overlap*EEG.srate;
    
    % Get trial information
    trialbreaks = EEG.trialbreaks;
    stimpattern = cell(size(STIM,1),1);
    movements = {'RK','RA','LK','LA','BH'};
    movetimes = all_movetimes{aa};
    
    % Get channel locations
    eegchannels = {EEG.chanlocs.labels};
    montages    = [];
    for bb = 1:length(channel_configs)
        chans2keepIDX = zeros(size(channel_configs{bb}));
        for cc = 1:length(channel_configs{bb})
            chans2keepIDX(cc) = find(strcmpi(channel_configs{bb}(cc),eegchannels));
        end
        montages = cat(2,{chans2keepIDX});%{1:length(chans2keepIDX)};%, LM_IDX};
    end
    
    % Get filt bands and channel locations
    total = 1;
    combos = cell(length(BANDS)*length(montages),3);
    for bb = 1:length(BANDS)
        for cc = 1:length(montages)
            combos{total,1} = BANDS{bb};
            combos{total,2} = montages{cc};
            if any(bb == [1, 2, length(BANDS)-1,length(BANDS)]) % any(bb == length(BANDS))
                combos{total,3} = 0;
            else
                combos{total,3} = 1;
            end
            %combos{total,4} = ['IC: ' num2str(cc) '; RV: ' num2str(EEG.dipfit.model(cc).rv)];
            total = total + 1;
        end
    end
    total = total - 1;
    clear bb cc
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                                    %
    %        BEGIN PARALLEL LOOP         %
    %                                    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    eeg_data = EEG.data;
    
    % Common average reference
    if car_data
        meanEEG = repmat(mean(eeg_data,1),size(eeg_data,1),1);
        eeg_data = eeg_data - meanEEG;
    end
    
    % Slice
    
    
    % Initialize for storing R2
    R1_MEAN     = cell(length(movements),1);
    R1_ALL      = cell(length(movements),1);
    R2_MEAN     = cell(length(movements),1);
    R2_ALL      = cell(length(movements),1);
    PREDICT_ALL = cell(length(movements),1);
    KF_ALL      = cell(length(movements),1);
    
    % Loop through each movement
    for aaa = 1:length(movements)% 1:length(movements)
        
        % Initialize for storing R2
        R1_sub_test   = cell(total,1);
        R1_sub_all    = cell(total,1);
        R2_sub_test   = cell(total,1);
        R2_sub_all    = cell(total,1);
        predicted_sub = cell(total,1);
        predicted_subV = cell(total,1);
        %kf_sub        = cell(total,1);
        meanstd_sub   = cell(total,1);
        
        thismove = movements{aaa};
        parfor bb = 1:total
            %         for bb = 1:total
            bb
            disp([thismove ' Joint; Iteration: ' num2str(bb) '/' num2str(total)]);
            pause(1);
            
            % Get channels of interest
            eegdata = eeg_data(combos{bb,2},:);
            
            % VERY SLOW - USE FILTER FUNCTION FOR OFFLINE
            %             % Design filters
            %             bp_filt = make_ss_filter(filter_order,combos{bb,1},EEG.srate,'bandpass');
            %
            %             % Filter data
            %             filtdata = zeros(size(eegdata));
            %             for cc = 1:size(eegdata,1)
            %                 % filter data - state space approach
            %                 xnn_bp = zeros(filter_order*2,1);
            %                 filtdata(cc,:) = use_ss_filter(bp_filt,eegdata(cc,:),xnn_bp);
            %             end
            
            % Faster than SS approach but yields same results
            [b,a] = butter(2,combos{bb,1}/(srate/2),'bandpass');
            filtdata = zeros(size(eegdata));
            for cc = 1:size(eegdata,1)
                % filter data - not using state space approach but same
                % results
                if realtimefilt
                    filtdata(cc,:) = filter(b,a,eegdata(cc,:));
                else
                    filtdata(cc,:) = filtfilt(b,a,eegdata(cc,:));
                end
            end
            
            
            % Compute envelope for filtdata above delta
            if combos{bb,3} == 1
                [filtdata, ~] = envelope(filtdata',envwindow,'analytic');
                filtdata = filtdata';
                % elseif combos{total,3} == 0;
                % do nothing
            end
            
            % Initialize for storing data for each movement
            movedata = [];
            alleeg   = [];
            allmove  = [];
            count    = 1;
            
            % Initialize array for each fold
            %ALLFOLDS = cell(2,size(movetimes,1)*size(movetimes{1,2},1));
            ALLFOLDS = [];
            % Loop through each trial
            for cc = 1:size(movetimes{aaa},1)
                trialdata = filtdata(:,movetimes{aaa}{cc,1});
                trialgonio = zscore(GONIO(cc).data(1,:));
                trialgonio = abs(trialgonio-max(trialgonio));
                for dd = 1:size(movetimes{aaa}{cc,2},1)
                    % Get movement window
                    move_win  = movetimes{aaa}{cc,2}(dd,:);
                    t1 = move_win(1)-window_buffer;
                    t2 = round(move_win(1)+(trial_duration*EEG.srate)- 1/EEG.srate + window_buffer);
                    % Shift time according to computed phase lag
                    temp_time = (t1:t2) + round(abs(mean(lag2{aa})));
                    % Get data
                    tempeeg = trialdata(:,temp_time);
                    % Get gonio data, zscore, normalize
                    % fullwave = trialgonio(1,temp_time);
                    % Compute features (e.g., get values in window)
                    tstart = 1;
                    tend   = tstart + window_size; %window_shift;
                    alleeg_win = []; allkin_win = [];
                    while tend <= size(tempeeg,2)
                        % Get window of mean power/potential and corresponding kin val
                        alleeg_win = [alleeg_win, mean(tempeeg(:,tstart:tend),2)];
                        allkin_win = cat(2,allkin_win, mean(fullwave(:,tstart:tend),2)); % USING GONIO HERE INSTEAD
                        % Update start and end
                        tstart = tstart + window_shift;
                        tend   = tstart + window_size;
                    end
                    if zscore_data
                        alleeg_win = transpose(zscore(alleeg_win'));
                        %allkin_win = transpose(zscore(allkin_win'));
                    end
                    % Save to folds array
                    ALLFOLDS{1,count} = alleeg_win;
                    ALLFOLDS{2,count} = allkin_win;
                    count = count + 1;
                end % dd = 1:size(movetimes{aaa}{cc,2},1)
            end %  cc = 1:size(movetimes{aaa},1)
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %                                    %
            %        TRAIN KALMAN FILTER         %
            %                                    %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            traineeg = cat(2,ALLFOLDS{1,1:end-1});
            trainkin = cat(2,ALLFOLDS{2,1:end-1});
            % Get test data
            testeeg  = cat(2,ALLFOLDS{1,end});
            testkin  = cat(2,ALLFOLDS{2,end});
            % Get size of each fold
            foldIDX = cumsum([1 cellfun(@(x) size(x,2),ALLFOLDS(1,1:end-1))]);
           foldIDX = cumsum([1 cellfun(@(x) size(x,2),ALLFOLDS(1,1:end-1))]);
            % Add d(trainkin)/dt
            if use_velocity
                trainkinfull = cat(1,trainkin,diff([trainkin(1) trainkin]));
                testkinfull = cat(1,testkin,diff([testkin(1) testkin]));
            else
                trainkinfull = trainkin;
                testkinfull  = testkin;
            end
            
            % Smooth data to remove peaks
            trainkinfull(1,:) = smooth(trainkinfull(1,:),20);
            testkinfull(1,:)  = smooth(testkinfull(1,:),20);
            
            if use_velocity
                trainkinfull(2,:) = smooth(trainkinfull(2,:),20);
                testkinfull(2,:)  = smooth(testkinfull(2,:),20);
            end
            
            % Get mean and std of data
            meantrain = mean(trainkinfull,2);
            stdtrain  = std(trainkinfull,[],2);
            meantest = mean(testkinfull,2);
            stdtest  = std(testkinfull,[],2);
            allmeanstd = {[meantrain stdtrain]; [meantest stdtest]};
            
            if zscore_data
                trainkinfull = transpose(zscore(trainkinfull'));
                testkinfull = transpose(zscore(testkinfull'));
            end
            
            % Convert back into cell array
            trainkin = cell(1,length(foldIDX)-1);
            for idx = 1:length(foldIDX)-1
                trainkin{idx} = trainkinfull(:,foldIDX(idx):foldIDX(idx+1)-1);
            end
            
            % Run ridge regression
            all_R1_train = cell(length(KF_LAGS),length(KF_LAMBDA));
            all_R2_train = cell(length(KF_LAGS),length(KF_LAMBDA));
            median_r2_pos = zeros(length(KF_LAGS),length(KF_LAMBDA));
            median_r2_vel = zeros(length(KF_LAGS),length(KF_LAMBDA));
            for ii = 1:length(KF_LAGS)
                for jj = 1:length(KF_LAMBDA)
                    % Loop through each fold
                    R2 = zeros(2,length(trainkin));
                    R1 = zeros(2,length(trainkin));
                    for kk = 1:length(trainkin)
                        % Get validation data
                        tempTestEEG = cat(2,traineeg{kk});
                        tempTestKIN = cat(2,trainkin{kk});
                        % Get train data
                        tempTrainKIN = cat(2,trainkin{setxor(1:length(trainkin),kk)});
                        tempTrainEEG = cat(2,traineeg{setxor(1:length(trainkin),kk)});
                        % Lag data
                        lagTestEEG = KalmanFilter.lag_data(tempTestEEG,KF_LAGS(ii));
                        lagTrainEEG = KalmanFilter.lag_data(tempTrainEEG,KF_LAGS(ii));
                        % Cut data to remove lag period
                        trim_size = KF_LAGS(ii)+1;
                        cutTestEEG = lagTestEEG(:,trim_size:end-trim_size);
                        cutTestKIN = tempTestKIN(:,trim_size:end-trim_size);
                        cutTrainEEG = lagTrainEEG(:,trim_size:end-trim_size);
                        cutTrainKIN = tempTrainKIN(:,trim_size:end-trim_size);
                        % Compute ridge regression - position then velocity
                        mdl_pos = ridge(cutTrainKIN(1,:)',cutTrainEEG',KF_LAMBDA(jj),0);
                        % Predict on validation data
                        predict_pos = mdl_pos(1) + cutTestEEG'*mdl_pos(2:end);
                        % Save correlation and R2
                        R1(1,kk) = KalmanFilter.PearsonCorr(predict_pos,cutTestKIN(1,:));
                        R2(1,kk) = KalmanFilter.rsquared(predict_pos,cutTestKIN(1,:));
                        % Compute ridge regression - position then velocity
                        if use_velocity
                            mdl_vel = ridge(cutTrainKIN(2,:)',cutTrainEEG',KF_LAMBDA(jj),0);
                            predict_vel = mdl_vel(1) + cutTestEEG'*mdl_vel(2:end);
                            R1(2,kk) = KalmanFilter.PearsonCorr(predict_vel,cutTestKIN(2,:));
                            R2(2,kk) = KalmanFilter.rsquared(predict_vel,cutTestKIN(2,:));
                        end
                    end
                    all_R1_train{ii,jj} = R1;
                    all_R2_train{ii,jj} = R2;
                    median_r2_pos(ii,jj) = median(R2(1,:));
                    
                    if use_velocity
                        median_r2_vel(ii,jj) = median(R2(2,:));
                    end
                end % Lamda
            end % lags
            R1 = []; R2 = [];
            
            % Store R1 and R2 values from training
            R1_sub_all{bb} = all_R1_train;
            R2_sub_all{bb} = all_R2_train;
            
            % Get training data
            tempTrainEEG = cat(2,traineeg{:});
            tempTrainKIN = cat(2,trainkin{:});
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %                                %
            %    RETRAIN MODEL - POSITION    %
            %                                %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Find best params for position
            [idxRowPos, idxColPos] = find(median_r2_pos==max(median_r2_pos(:)));
            lagvalpos = KF_LAGS(idxRowPos);
            lamdavalpos = KF_LAMBDA(idxColPos);
            
            % Lag data
            lagTestEEG = KalmanFilter.lag_data(testeeg,lagvalpos);
            lagTrainEEG = KalmanFilter.lag_data(tempTrainEEG,lagvalpos);
            
            % Cut data to remove lag period
            trim_size = lagvalpos+1;
            cutTestEEG = lagTestEEG(:,trim_size:end-trim_size);
            cutTestKIN = tempTestKIN(:,trim_size:end-trim_size);
            cutTrainEEG = lagTrainEEG(:,trim_size:end-trim_size);
            cutTrainKIN = tempTrainKIN(:,trim_size:end-trim_size);
            
            % Compute ridge regression - position then velocity
            mdl_pos = ridge(cutTrainKIN(1,:)',cutTrainEEG',lamdavalpos,0);
            
            % Predict on validation data
            predict_pos = mdl_pos(1) + cutTestEEG'*mdl_pos(2:end);
            
            % Evaluate model
            R1_pos = KalmanFilter.PearsonCorr(predict_pos,cutTestKIN(1,:));
            R2_pos = KalmanFilter.rsquared(predict_pos,cutTestKIN(1,:));
            
            % Store prediction
            predicted_sub{bb,1} = [predict_pos'; cutTestKIN(1,:)];
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %                                %
            %    RETRAIN MODEL - VELOCITY    %
            %                                %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if use_velocity
                % Find best params for velocity
                [idxRowVel, idxColVel] = find(median_r2_vel==max(median_r2_vel(:)));
                lagvalvel = KF_LAGS(idxRowVel);
                lamdavalvel = KF_LAMBDA(idxColVel);
                
                % Lag data
                lagTestEEG = KalmanFilter.lag_data(testeeg,lagvalvel);
                lagTrainEEG = KalmanFilter.lag_data(tempTrainEEG,lagvalvel);
                
                % Cut data to remove lag period
                trim_size = lagvalvel+1;
                cutTestEEG = lagTestEEG(:,trim_size:end-trim_size);
                cutTestKIN = tempTestKIN(:,trim_size:end-trim_size);
                cutTrainEEG = lagTrainEEG(:,trim_size:end-trim_size);
                cutTrainKIN = tempTrainKIN(:,trim_size:end-trim_size);
                
                % Compute ridge regression - position then velocity
                mdl_vel = ridge(cutTrainKIN(2,:)',cutTrainEEG',lamdavalvel,0);
                
                % Predict on validation data
                predict_vel = mdl_vel(1) + cutTestEEG'*mdl_vel(2:end);
                
                % Save correlation and R2
                R1_vel = KalmanFilter.PearsonCorr(predict_vel',cutTestKIN(2,:));
                R2_vel = KalmanFilter.rsquared(predict_vel',cutTestKIN(2,:));
                
                predicted_subV{bb,1} = [predict_vel'; cutTestKIN(2,:)];
                
            end
            
            % Store R2 values
            R1_sub_test{bb} = [R1_pos; R1_vel];
            R2_sub_test{bb} = [R2_pos; R2_vel];
            
            % Mean and std deviation
            meanstd_sub{bb} = allmeanstd;
            
        end % bb = 1:total
        % Store results for each movement
        %R2_ALL{aaa} = R2_sub_all;
        %R2_MEAN{aaa} = R2_sub_mean;
        %PREDICT_ALL{aaa} = predicted_sub;
        filename = [subs{aa} '_RR_RESULTS_MOTORCHAN_TARGET_' movements{aaa} '_WIN' num2str(num2str(1/update_rate)) '_Z' num2str(zscore_data) '_CAR' num2str(car_data) '_V' num2str(use_velocity) '.mat'];
        save(filename,'R2_sub_all','R2_sub_test','R1_sub_all','R1_sub_test','predicted_sub','predicted_subV','combos','meanstd_sub');
        
    end % aaa = 1:length(movements)
    %filename = [subs{aa} '_KF_RESULTS_WIN' num2str(num2str(1/update_rate)) '_Z' num2str(zscore_data) '_CAR' num2str(car_data) '_AUG' num2str(useAug) '_UKF' num2str(useUKF) '.mat'];
    %save(filename,'R2_ALL','R2_MEAN','PREDICT_ALL');
end % aa = 1:length(subs)

