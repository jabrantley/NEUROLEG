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
onCluster   = 0;
runParallel = 1;

% Define directory
thisdir = pwd;
idcs = strfind(pwd,filesep);
parentdir = thisdir(1:idcs(end-2));
addpath(genpath(fullfile(parentdir)));

% Set data dir
if onCluster
    rawdir  = fullfile(parentdir,'TEMPDATA');
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
zscore_data  = 1;
car_data     = 1;
useAug       = 1;
useUKF       = 1;
filter_order = 2; % bandpass filter
use_velocity = 1;
predict_type = 1; % Changes way state vector is updated. 1: use all last predicted vals. 2: use new at time t and old at t-1...t-Order
KF_ORDER     = [3,5,10];
KF_LAGS      = [3,5,10];
KF_LAMBDA    = logspace(-2,2,5);

% Define movement pattern parameters
srate          = 1000;
% numCycles      = 6;   % number of cycles
% move_freq      = .5; % speed of moving dot in hz
window_buffer  = 3; % 1 second shift TO ACCOUNT FOR ONSET ERROR
% trial_duration = 12; % instead of using exp dur from STIM, fix length for consistency

% Params for computing feature
update_rate = 1/50; % sampling time
window_overlap = 0; % % overlap 0 to 0.99

% % Create movement pattern vector
% timevec  = 0:1/srate:trial_duration; % time vector
% sinwave  = cos(move_freq*2*pi*timevec + pi); % create sinwave
% fullwave = [-1.*ones(1,window_buffer) sinwave -1.*ones(1,window_buffer)];
% fullwave = rescale(fullwave);
% fulltime = 0:1/srate:(trial_duration+2*window_buffer/srate);

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
BANDS   = {lodelta,delta,theta,alpha,beta,gamma,higamma,full,nodelta,full,nodelta}; % full is used twice so one is env(full) and other is not

% Channels to keep for analysis NOTE: FT10 is in FCz location
% chans2keep = {'F4','F2','Fz','F1','F3','FC3','FC1','FT10','FC2','FC4','C4','C2','Cz',...
%     'C1','C3','CP3','CP1','CPz','CP2','CP4'};
% % leftMotor  = {'F4','F2','Fz','F1','F3','FC3','FC1','FT10','Cz',...
% %     'C1','C3'};
% channel_configs = {chans2keep};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%           SETUP PARALLEL           %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Setup parallel pool
if runParallel
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
    movements = {'RK'};
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
for aa = 3%1:length(subs)
    
    % Get variables
    vars = who;
    
    % Get eeg files for each subject
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-eeg.mat'   ]));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-stim.mat'  ]));
    % Load movement data
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-gonio.mat' ]));
    
    % Set feature window parameters
    window_size = update_rate * EEG.srate;
    window_shift = window_size - window_overlap*EEG.srate;
    
    % Get trial information
    trialbreaks = EEG.trialbreaks;
    stimpattern = cell(size(STIM,1),1);
    movements = {'RK'};
    movetimes = all_movetimes{aa};
    
    % Get channel locations
    montages = {EEG.chanlocs.labels};
    
    % Get filt bands and channel locations
%     total = 1;
%     combos = cell(length(BANDS),length(montages));
%     for bb = 1:length(BANDS)
%         combos{bb,1} = BANDS{bb};
%         for cc = 1:length(montages)
%             combos{cc,2} = cc;
%             if any(bb == [1, 2, length(BANDS)-1,length(BANDS)]) % any(bb == length(BANDS))
%                 combos{total,3} = 0;
%             else
%                 combos{total,3} = 1;
%             end
%             combos{total,4} = montages{cc};%['IC: ' num2str(cc) '; RV: ' num2str(EEG.dipfit.model(cc).rv)];
%             total = total + 1;
%         end
%     end
%     total = total - 1;
%     clear bb cc

%     total = 1;
%     combos = cell(length(BANDS)*length(montages),3);
%     for bb = 1:length(BANDS)
%         for cc = 1:length(montages)
%             combos{total,1} = BANDS{bb};
%             combos{total,2} = cc;
%             if any(bb == [1, 2, length(BANDS)-1,length(BANDS)]) % any(bb == length(BANDS))
%                 combos{total,3} = 0;
%             else
%                 combos{total,3} = 1;
%             end
%             combos{total,4} = montages{cc};%['IC: ' num2str(cc) '; RV: ' num2str(EEG.dipfit.model(cc).rv)];
%             total = total + 1;
%         end
%     end
%     total = total - 1;
%     clear bb cc
    

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
    
    % Slice data
    %eeg_data = mat2cell(eeg_data,ones(size(eeg_data,1),1),size(eeg_data,2));
    
    % Initialize for storing R2
    R2_MEAN     = cell(length(movements),1);
    R2_ALL      = cell(length(movements),1);
    PREDICT_ALL = cell(length(movements),1);
    
    % Loop through each movement
    for aaa = 1:length(movements)% 1:length(movements)
        
        % Initialize for storing R2
        R2_sub_mean   = cell(length(BANDS),length(montages));
        %R2_sub_mean   = cell(total,1);
        R2_sub_all    = cell(length(BANDS),length(montages)); % cell(total,1);
        predicted_sub = cell(length(BANDS),length(montages)); % cell(total,1);
        thismove = movetimes{aaa};% movements{aaa};
        %parfor bb = 1:total
             % Get filt bands and channel locations
        
        total = 1;
        for bb = 1:length(BANDS)
            % Get filter band
            thisband = BANDS{bb};
            % Use envelope if > delta or full band (except last two)
            if any(bb == [1, 2, length(BANDS)-1,length(BANDS)])
                useenv = 0;
            else
                useenv = 1;
            end
            
            for cc = 1:length(montages)
                 disp(['Filt band: [' num2str(thisband(1)) ', ' num2str(thisband(2)) '; Channel ' montages{cc} ])
%         for bb = 1:total
%             bb
%             disp([thismove ' Joint; Iteration: ' num2str(bb) '/' num2str(total)]);
%             pause(1);
            
            % Get channels of interest
            eegdata = eeg_data(cc,:);
            
            % Faster than SS approach but yields same results
            [b,a] = butter(2,thisband/(srate/2),'bandpass');
            filtdata = zeros(size(eegdata));
            for dd = 1:size(eegdata,1)
                % filter data - not using state space approach but same
                % results
                filtdata(dd,:) = filter(b,a,eegdata(dd,:));
            end
            
            
            % Compute envelope for filtdata above delta
            if useenv == 1
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
            for dd = 1:size(thismove,1)
                trialdata = filtdata(:,thismove{dd,1});
                trialgonio = zscore(GONIO(dd).data(1,:));
                trialgonio = abs(trialgonio-max(trialgonio));
                for ee = 1:size(thismove{dd,2},1)
                    % Get movement window
                    move_win  = thismove{dd,2}(ee,:);
                    % Get time
                    temp_time =  move_win(1):move_win(2);
                    % Get data
                    tempeeg = trialdata(:,temp_time);
                    % Get gonio data, zscore, normalize
                    fullwave = trialgonio(1,temp_time);
                    % Compute features (e.g., get values in window)
                    tstart = 1;
                    tend   = tstart + window_size; %window_shift;
                    alleeg_win = []; allkin_win = [];
                    while tend <= size(tempeeg,2)
                        % Get window of mean power/potential and corresponding kin val
                        alleeg_win = [alleeg_win, mean(tempeeg(:,tstart:tend),2)];
                        allkin_win = [allkin_win, mean(fullwave(:,tstart:tend),2)]; % USING GONIO HERE INSTEAD
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
            % Get train data
            traineeg = ALLFOLDS(1,1:end-1);
            trainkin = ALLFOLDS(2,1:end-1);
            % Get test data
            testeeg  = ALLFOLDS(1,end);
            testkin  = ALLFOLDS(2,end);
            % Get size of each fold
            foldIDX = cumsum([1 cellfun(@(x) size(x,2),traineeg)]);
            % Determine kalman filter type
            if useUKF
                kf_method = 'unscented';
            else
                kf_method = 'normal';
            end
            % Kalman Filter object
            KF = KalmanFilter('state',cat(2,trainkin{:}),'observation',cat(2,traineeg{:}),...
                'augmented',useAug,'method',kf_method);
            % Perform grid search
            KF.grid_search('order',KF_ORDER,'lags',KF_LAGS,'lambdaB',KF_LAMBDA,...
                'lambdaF',KF_LAMBDA,'testidx',1,'kfold',foldIDX);
            
            % Lag data
            lagKIN = KalmanFilter.lag_data(cat(2,testkin{:}),KF.order);
            lagEEG = KalmanFilter.lag_data(cat(2,testeeg{:}),KF.lags);
            
            % Trim off edges
            maxlag = max([KF.lags,KF.order]);
            lagKIN_cut = lagKIN(:,maxlag+1:end);
            lagEEG_cut = lagEEG(:,maxlag+1:end);
            
            % Predict data
            predicted = KF.evaluate(lagEEG_cut);
            
            % Store R2 values
            R2_sub_mean{bb,cc} = KF.R2_Train;
            R2_sub_all{bb,cc} = KF.R2_GridSearch;
            predicted_sub{bb,cc} = [predicted(1,:); lagKIN_cut(1,:)];
            %predicted_sub{bb,2} = KalmanFilter.rsquared(predicted(1,:), lagKIN_cut(1,:));
            
            end
            
        end % bb = 1:total
        % Store results for each movement
        %R2_ALL{aaa} = R2_sub_all;
        %R2_MEAN{aaa} = R2_sub_mean;
        %PREDICT_ALL{aaa} = predicted_sub;
        filename = [subs{aa} '_KF_RESULTS_GONIO_EachChan_' movements{aaa} '_WIN' num2str(num2str(1/update_rate)) '_Z' num2str(zscore_data) '_CAR' num2str(car_data) '_AUG' num2str(useAug) '_UKF' num2str(useUKF) '.mat'];
        save(filename,'R2_sub_all','R2_sub_mean','predicted_sub','BANDS','montages');

    end % aaa = 1:length(movements)
    %filename = [subs{aa} '_KF_RESULTS_WIN' num2str(num2str(1/update_rate)) '_Z' num2str(zscore_data) '_CAR' num2str(car_data) '_AUG' num2str(useAug) '_UKF' num2str(useUKF) '.mat'];
    %save(filename,'R2_ALL','R2_MEAN','PREDICT_ALL');
end % aa = 1:length(subs)
