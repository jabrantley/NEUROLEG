%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                   NEUROLEG REAL TIME - TRAIN UKF MODEL                  %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function implements the UKF training between EEG/EMG and angles.
%
% University of Houston, Non-Invasive Brain Machine Interfaces Laboratory
% Written by: Justin Brantley - justin.a.brantley@gmail.com
% 09/24/2019: Date created

function [params,KF_EMG,KF_EEG,cleaneeg,filteeg,filtemg,envemg,eegMean,eegStDv] = neuroleg_realtime_train(params,EEG,EMG,ANGLES,standardize)

% Get EOG data
if ~isempty(params.setup.EOGchannels)
    EOG = EEG(params.setup.EOGchannels,:);
else
    EOG = [];
end
% Remove EOG from EEG data
%EEG(params.setup.EOGc))hannels,:) = [];
EEG = EEG(params.setup.chans2keep,:);

% Process data
[params,cleaneeg,filteeg,filtemg,envemg] = neuroleg_realtime_processing(params,EEG',EOG',EMG');

% Trim off first part during hinfinity convergence
filteeg  = filteeg(:,params.setup.time2cut*params.setup.eegsrate:end);
cleaneeg = cleaneeg(:,params.setup.time2cut*params.setup.eegsrate:end);
filtemg  = filtemg(:,params.setup.time2cut*params.setup.eegsrate:end);
envemg   = envemg(:,params.setup.time2cut*params.setup.eegsrate:end);
ANGLES   = ANGLES(:,params.setup.time2cut*params.setup.eegsrate:end);

% Compute mean and std of each channel
eegMean = mean(filteeg,2);
eegStDv = std(filteeg,[],2);

% Zscore EEG
if standardize
    zscore_eeg = transpose(zscore(filteeg'));
else
    zscore_eeg = filteeg;
end
    
% Smooth angles using moving average
filtangles = smooth(ANGLES,20)';

% Split data
dAngle_pos = find([0 diff(ANGLES>0)]>0);   % Get positive derivative
dAngle_neg = find([0 diff(ANGLES>0)]<0);   % Get negative derivative

% foldsidx   = [1 dAngle_neg]; % Get breaks between angles
foldsidx   = [dAngle_pos length(ANGLES)]; % Get breaks between angles

% Plot segmentation
bc = blindcolors;
figure('color','w'); plot(ANGLES,'color',0.5.*ones(1,3));
hold on; stem(foldsidx,ones(1,length(foldsidx)),'filled',...
    'color',bc(6,:),'linewidth',1.15,'MarkerSize',10)

% Get train/test folds
N = 0.80; % 80 percent for test
dist2percent = abs(foldsidx - (N*length(foldsidx(1):foldsidx(end))));
idxNpercent = find(min(dist2percent)==dist2percent);
trainIDX = foldsidx(1):(foldsidx(idxNpercent)-1);
testIDX  = foldsidx(idxNpercent):foldsidx(end);

% Get test data
start = foldsidx(1);
stop  = start + (params.setup.updaterate.*params.setup.eegsrate) - 1;
% try reshape instead of while loop
train_emg = []; train_eeg = []; train_ang = [];
test_emg  = []; test_eeg  = []; test_ang  = [];
while stop <= foldsidx(end)
    if stop < foldsidx(idxNpercent)
        train_emg = [train_emg, mean(envemg(:,start:stop),2)];
        train_eeg = [train_eeg, mean(zscore_eeg(:,start:stop),2)];
        train_ang = [train_ang, mean(ANGLES(:,start:stop),2)];
    else
        test_emg =  [test_emg,  mean(envemg(:,start:stop),2)];
        test_eeg =[test_eeg, mean(zscore_eeg(:,start:stop),2)];
        test_ang = [test_ang, mean(ANGLES(:,start:stop),2)];
    end
    start = stop;
    stop  = start + (params.setup.updaterate.*params.setup.eegsrate) - 1;
end

%% Train Kalman Filter - EMG vs ANGLES
KF_EMG = KalmanFilter('state',train_ang,'observation',train_emg,'augmented',0,...
    'method','normal');

% Perform grid search
KF_EMG.grid_search('order',params.kalman.order,'lags',params.kalman.lags,'lambdaB',params.kalman.lambda,'lambdaF',params.kalman.lambda,'testidx',1);

% Test using remaining validation data
test_emg_lag = KalmanFilter.lag_data(test_emg,KF_EMG.lags);
test_ang_lag = KalmanFilter.lag_data(test_ang,KF_EMG.order);
test_emg_cut = test_emg_lag(:,KF_EMG.lags+1:end);
test_ang_cut = test_ang_lag(:,KF_EMG.lags+1:end);

% Evaluate using test data
predictionEMG = KF_EMG.evaluate(test_emg_cut);

% Compute R2 value
R2_EMG = KF_EMG.rsquared(predictionEMG(1,:),test_ang_cut(1,:));

%% Train Kalman Filter - EMG vs ANGLES
KF_EEG = KalmanFilter('state',train_ang,'observation',train_eeg,'augmented',0,...
    'method','normal');

% Perform grid search
KF_EEG.grid_search('order',params.kalman.order,'lags',params.kalman.lags,'lambdaB',params.kalman.lambda,'lambdaF',params.kalman.lambda,'testidx',1);

% EEG test data
test_eeg_lag = KalmanFilter.lag_data(test_eeg,KF_EEG.lags);
test_eeg_cut = test_eeg_lag(:,KF_EEG.lags+1:end);
test_ang_cut = test_ang_lag(:,KF_EEG.lags+1:end);

% Evaluate using test data
predictionEEG = KF_EEG.evaluate(test_eeg_cut);

% Compute R2 value
R2_EEG = KF_EEG.rsquared(predictionEEG(1,:),test_ang_cut(1,:));

end