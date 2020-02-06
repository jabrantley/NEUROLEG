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

function [params,KF_EMG,KF_EEG,cleaneeg,filteeg,prehinfeeg,filtemg,envemg,EEGgain,EMGgain] = neuroleg_realtime_train(params,EEG,EMG,ANGLES)

% Get EOG data
if ~isempty(params.setup.EOGchannels)
    EOG = EEG(params.setup.EOGchannels,:);
else
    EOG = [];
end
% Remove EOG from EEG data
%EEG(params.setup.EOGchannels,:) = [];
EEG = EEG(params.setup.chans2keep,:);

% Process data
[params,cleaneeg,filteeg,prehinfeeg,filtemg,envemg] = neuroleg_realtime_processing(params,EEG',EOG',EMG');

% Trim off first part during hinfinity convergence
if params.setup.filteog
    prehinfeeg  = prehinfeeg(:,params.setup.time2cut*params.setup.eegsrate:end);
else
    prehinfeeg = [];
end
filteeg     = filteeg(:,params.setup.time2cut*params.setup.eegsrate:end);
cleaneeg    = cleaneeg(:,params.setup.time2cut*params.setup.eegsrate:end);
filtemg     = filtemg(:,params.setup.time2cut*params.setup.eegsrate:end);
envemg      = envemg(:,params.setup.time2cut*params.setup.eegsrate:end);
ANGLES      = ANGLES(:,params.setup.time2cut*params.setup.eegsrate:end);

% Compute mean and std of each channel
meaneeg = mean(filteeg,2);
stdeeg  = std(filteeg,[],2);
meanemg = mean(filtemg,2);
stdemg  = std(filtemg,[],2);

% Zscore EEG
if params.setup.standardizeEEG
    zscore_eeg = transpose(zscore(filteeg'));
else
    zscore_eeg = filteeg;
end

% Zscore EMG
if params.setup.standardizeEMG
    zscore_emg = transpose(zscore(envemg'));
else
    zscore_emg = envemg;
end

% Smooth angles using moving average
filtangles = smooth(ANGLES,20)';

% Split data
dAngle_pos = find([0 diff(ANGLES>0)]>0);   % Get positive derivative
dAngle_neg = find([0 diff(ANGLES>0)]<0);   % Get negative derivative

% foldsidx   = [1 dAngle_neg]; % Get breaks between angles
foldsidx   = [dAngle_pos length(ANGLES)]; % Get breaks between angles

% Plot segmentation
% bc = blindcolors;
% figure('color','w'); plot(ANGLES,'color',0.5.*ones(1,3));
% hold on; stem(foldsidx,ones(1,length(foldsidx)),'filled',...
%     'color',bc(6,:),'linewidth',1.15,'MarkerSize',10)

% Get train/test folds
N = 0.80; % 80 percent for test
dist2percent = abs(foldsidx - (N*length(foldsidx(1):foldsidx(end))));
idxNpercent = find(min(dist2percent)==dist2percent);
trainIDX = foldsidx(1):(foldsidx(idxNpercent)-1);
testIDX  = foldsidx(idxNpercent):foldsidx(end);

% Get test data
start = foldsidx(1);
stop  = start + 1;%(params.setup.updaterate.*params.setup.eegsrate) - 1;
% try reshape instead of while loop
train_emg = []; train_eeg = []; train_ang = [];
test_emg  = []; test_eeg  = []; test_ang  = [];
while stop <= foldsidx(end)
    if stop < foldsidx(idxNpercent)
        train_emg = [train_emg, mean(zscore_emg(:,start:stop),2)];
        train_eeg = [train_eeg, mean(zscore_eeg(:,start:stop),2)];
        train_ang = [train_ang, mean(ANGLES(:,start:stop),2)];
    else
        test_emg =  [test_emg,  mean(zscore_emg(:,start:stop),2)];
        test_eeg =[test_eeg, mean(zscore_eeg(:,start:stop),2)];
        test_ang = [test_ang, mean(ANGLES(:,start:stop),2)];
    end
    start = stop;
    stop  = start + (params.setup.updaterate.*params.setup.eegsrate) - 1;
end

%% Train Kalman Filter - EMG vs ANGLES
KF_EMG = KalmanFilter('state',train_ang,'observation',train_emg,'augmented',0,...
    'method','normal','mean',meanemg,'std',stdemg);

% Perform grid search
KF_EMG.grid_search('order',params.kalman.order,'lags',params.kalman.emglags,'lambdaB',params.kalman.lambda,'lambdaF',params.kalman.lambda,'testidx',1);

% Test using remaining validation data
test_emg_lag = KalmanFilter.lag_data(test_emg,KF_EMG.lags);
test_ang_lag = KalmanFilter.lag_data(test_ang,KF_EMG.order);
test_emg_cut = test_emg_lag(:,KF_EMG.lags+1:end);
test_ang_cut = test_ang_lag(:,KF_EMG.lags+1:end);

% Evaluate using test data
predictionEMG = KF_EMG.evaluate(test_emg_cut);

% Compute R2 value
R2_EMG = KF_EMG.rsquared(predictionEMG(1,:),test_ang_cut(1,:));

% Compute gain between estimated and actual EEG
EMGgain = [ones(size(test_ang_cut,2),1),predictionEMG(1,:)']\test_ang_cut(1,:)';

%% Train Kalman Filter - EMG vs ANGLES
KF_EEG = KalmanFilter('state',train_ang,'observation',train_eeg,'augmented',0,...
    'method','unscented','mean',meaneeg,'std',stdeeg);

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

% Compute gain between estimated and actual EEG
EEGgain = [ones(size(test_ang_cut,2),1),predictionEEG(1,:)']\test_ang_cut(1,:)';

%% Plot data  & print r2 values
bc = blindcolors;
figure('color','w','units','inches','position',[2.5 1.75,15.5,7.5]); 
ax = axes; hold on;
minpnts = min([size(predictionEMG,2),size(predictionEEG,2)]);
plot(test_ang_cut(1,1:minpnts),'color',0.7.*ones(1,3),'linewidth',2);
plot(predictionEMG(1,1:minpnts),'color',bc(6,:),'linewidth',2);
plot(predictionEEG(1,1:minpnts),'color',bc(8,:),'linewidth',2);
ax.XTick = []; ax.YTick = [];
ax.XColor = 'w'; ax.YColor = 'w';
legend({'Desired Angle','Predicted Angle EMG','Predicted Angle EEG'})
title(['R^{2}_{EMG} = ' num2str(round(R2_EMG,2)) '   ,   R^{2}_{EEG} = ' num2str(round(R2_EEG,2))]);

% Print r2 values
fprintf(['\n-------------------------------',...
    '\n\n   R2_EMG = %.2d\n   R2_EEG = %.2d \n\n',...
    '-------------------------------\n'],R2_EMG,R2_EEG)
end