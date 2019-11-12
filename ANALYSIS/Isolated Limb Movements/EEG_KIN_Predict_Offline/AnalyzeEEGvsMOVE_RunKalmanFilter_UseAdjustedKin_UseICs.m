%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%          ANALYZE EEG VS ISOLATED LIMB MOVEMENTS USING COMPONENTS        %
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
runParallel = 0;

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
    % movedir  = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_PROCESS_SYNCHRONIZED_EEG_FMRI_DATA','MOVEMENT_WINDOW');
    % basepath = fullfile(drive,'Dropbox','Research','Analysis','MATLAB FUNCTIONS');
end

% Add paths
% addpath(fullfile(basepath,'eeglab'));
% eeglab;
% close all;
% clc;

% addpath(genpath(fullfile(parentdir)));
% addpath(genpath(fullfile(basepath,'Brainstorm','brainstorm3','toolbox')));
% addpath(genpath(fullfile(basepath,'Custom MATLAB Functions')));
% addpath(genpath(fullfile(basepath,'shoeeg')));

% % Clean up
clearvars -except drive datadir rawdir savedir basepath EEG movedir parentdir ...
    onCluster runParallel

% Get files for each subject
subs = {'TF01','TF02','TF03'};

% Get variable names
vars = who;

% Kalman filter parameters
useAug       = 1;
useUKF       = 1;
filter_order = 2; % bandpass filter
use_velocity = 1;
predict_type = 1; % Changes way state vector is updated. 1: use all last predicted vals. 2: use new at time t and old at t-1...t-Order
KF_ORDER     = [3,10];
KF_LAGS      = [3,10];
KF_LAMBDA    = logspace(-2,2,5);

% Define movement pattern parameters
srate          = 1000;
numCycles      = 6;   % number of cycles
move_freq      = .5; % speed of moving dot in hz
window_buffer  = 1*srate; % 1 second shift TO ACCOUNT FOR ONSET ERROR
trial_duration = 12; % instead of using exp dur from STIM, fix length for consistency

% Params for computing feature
update_rate = 1/50; % sampling time
window_overlap = 0; % % overlap 0 to 0.99

% Create movement pattern vector
timevec  = 0:1/srate:trial_duration; % time vector
sinwave  = cos(move_freq*2*pi*timevec + pi); % create sinwave
fullwave = [-1.*ones(1,window_buffer) sinwave -1.*ones(1,window_buffer)];
fullwave = rescale(fullwave);
dfullwave = rescale([0 diff(fullwave)]);
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
%BANDS   = {lodelta,delta,theta,alpha,beta,gamma,higamma,full,full}; % full is used twice so one is env(full) and other is not
BANDS   = {delta}; % full is used twice so one is env(full) and other is not

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
            parpool(9);
        catch
            numCores = feature('numcores');
            parpool(numCores);
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
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-angles.mat']));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-gonio.mat' ]));
    
    % Get trial information
    trialbreaks = EEG.trialbreaks;
    movetimes = cell(size(STIM,1),2);
    stimpattern = cell(size(STIM,1),1);
    movements = {'RK','RA'};
    
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
    load(fullfile(datadir, [subs{aa}, '-ALLTRIALS-DIPFIT-eeg.mat'   ]));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-emg.mat'   ]));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-stim.mat'  ]));
    % Load movement data
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-angles.mat']));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-gonio.mat' ]));
    
    % Get trial information
    trialbreaks = EEG.trialbreaks;
    stimpattern = cell(size(STIM,1),1);
    %movements = {'RK','RA','LK','LA'};
    movements = {'RK','LK'};
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
            rk_time     = [rk_onset; rk_onset + rk_duration]'; % seconds [onset, offset]
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
    load(fullfile(datadir, [subs{aa}, '-ALLTRIALS-DIPFIT-eeg.mat'   ]));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-emg.mat'   ]));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-stim.mat'  ]));
    % Load movement data
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-angles.mat']));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-gonio.mat' ]));
    
    % Set feature window parameters
    window_size = update_rate * EEG.srate;
    window_shift = window_size - window_overlap*EEG.srate;
    
    % Get trial information
    trialbreaks = EEG.trialbreaks;
    stimpattern = cell(size(STIM,1),1);
    %movements = {'RK','RA','LK','LA'};
    movements = {'RK','LK'};
    movetimes = all_movetimes{aa};
    
    % Get filt bands and channel locations
    total = 1;
    combos = cell(length(BANDS)*size(EEG.icaweights,1),3);
    for bb = 1:length(BANDS)
        for cc = 1:size(EEG.icaweights,1)
            combos{total,1} = BANDS{bb};
            combos{total,2} = cc;
            if any(bb == [1, 2, length(BANDS)])
                combos{total,3} = 0;
            else
                combos{total,3} = 1;
            end
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
    
    % Compute ICA activations
    icaact = EEG.icaweights*EEG.icasphere*EEG.data;
    
    % Slice data to reduce overhead in parallel loop
%     for zz = 1:size(EEG.icaweights,1)
%         eval(['IC' num2str(zz) ' = EEG.icaact(' num2str(zz) ',:);'])
%     end
            
    % Initialize for storing R2
    R2_MEAN     = cell(length(movements),1);
    R2_ALL      = cell(length(movements),1);
    PREDICT_ALL = cell(length(movements),1);
    
    srate = EEG.srate;
    
    % Loop through each movement
    for aaa = 1:length(movements)% 1:length(movements)
        
        
        % Initialize for storing R2
        R2_sub_mean   = cell(total,1);
        R2_sub_all    = cell(total,1);
        predicted_sub = cell(total,1);
        thismove = movements{aaa};
        for bb = 1:total
%         for bb = 1:total
            bb
            disp([thismove ' Joint; Iteration: ' num2str(bb) '/' num2str(total)]);
            pause(1);
            
            % Design filters
            bp_filt = make_ss_filter(filter_order,combos{bb,1},srate,'bandpass');
            %lp_filt = make_ss_filter(filter_order,combos{bb,1},EEG.srate,'lowpass');
            
            % Get channels of interest
            eegdata = icaact(combos{bb,2},:);
            
            % Filter data
            filtdata = zeros(size(eegdata));
            for cc = 1:size(eegdata,1)
                % filter data - state space approach
                xnn_bp = zeros(filter_order*2,1);
                filtdata(cc,:) = use_ss_filter(bp_filt,eegdata(cc,:),xnn_bp);
            end
            
            % Compute envelope for filtdata above delta
            if combos{total,3} == 1
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
                for dd = 1:size(movetimes{aaa}{cc,2},1)
                    % Get movement window
                    move_win  = movetimes{aaa}{cc,2}(dd,:);
                    % Get start time and stop time
                    t1 = move_win(1)-window_buffer;
                    t2 = round(move_win(1)+(trial_duration*srate)- 1/srate + window_buffer);
                    % Shift time according to computed phase lag
                    temp_time = (t1:t2) + round(abs(mean(lag2{aa})));
                    % Get data
                    tempeeg = trialdata(:,temp_time);
                    % Compute features (e.g., get values in window)
                    tstart = 1;
                    tend   = tstart + window_size; %window_shift;
                    alleeg_win = []; allkin_win = [];
                    while tend <= size(tempeeg,2)
                        % Get window of mean power/potential and corresponding kin val
                        alleeg_win = [alleeg_win, mean(tempeeg(:,tstart:tend),2)];
                        %wavedat    = [mean(fullwave(:,tstart:tend),2); mean(dfullwave(:,tstart:tend),2)];
                        %allkin_win = [allkin_win, wavedat];
                        allkin_win = [allkin_win, mean(fullwave(:,tstart:tend),2)];
                        % Update start and end
                        tstart = tstart + window_shift;
                        tend   = tstart + window_size;
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
            traineeg = ALLFOLDS(1,1:end-2);
            trainkin = ALLFOLDS(2,1:end-2);
            % Get test data
            testeeg  = ALLFOLDS(1,end-1:end);
            testkin  = ALLFOLDS(2,end-1:end);
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
            R2_sub_mean{bb} = KF.R2_Train;
            R2_sub_all{bb} = KF.R2_GridSearch;
            predicted_sub{bb,1} = [predicted(1,:); lagKIN_cut(1,:)];
            %predicted_sub{bb,2} = KalmanFilter.rsquared(predicted(1,:), lagKIN_cut(1,:));
            
        end % bb = 1:total
        % Store results for each movement
        %R2_ALL{aaa} = R2_sub_all;
        %R2_MEAN{aaa} = R2_sub_mean;
        %PREDICT_ALL{aaa} = predicted_sub;
%         filename = [subs{aa} '_KF_RESULTS_' movements{aaa} '_WIN' num2str(num2str(1/update_rate)) '_ICA_VEL_AUG' num2str(useAug) '_UKF' num2str(useUKF) '.mat'];
        filename = [subs{aa} '_KF_RESULTS_' movements{aaa} '_WIN' num2str(num2str(1/update_rate)) '_ICA_DELTA_AUG' num2str(useAug) '_UKF' num2str(useUKF) '.mat'];
        save(filename,'R2_sub_all','R2_sub_mean','predicted_sub');
        
    end % aaa = 1:length(movements)
    %filename = [subs{aa} '_KF_RESULTS_WIN' num2str(num2str(1/update_rate)) '_Z' num2str(zscore_data) '_CAR' num2str(car_data) '_AUG' num2str(useAug) '_UKF' num2str(useUKF) '.mat'];
    %save(filename,'R2_ALL','R2_MEAN','PREDICT_ALL');
end % aa = 1:length(subs)