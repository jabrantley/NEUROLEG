%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%          ANALYZE EEG VS ISOLATED LIMB MOVEMENTS IN CHANEL SPACE         %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear;
clc;

% Run parallel for
onCluster   = 0;
runParallel = 0;

% Define directory
thisdir = pwd;
idcs = strfind(pwd,filesep);
parentdir = thisdir(1:idcs(end-1));
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
    %datadir  = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_PROCESS_SYNCHRONIZED_EEG_FMRI_DATA');
    datadir  = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','REALTIMECONTROL','TF01');
    rawdir   = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_RAW_SYNCHRONIZED_EEG_FMRI_DATA');
end

% Get files for each subject
model = 'TEST_train_model_190927_123846.mat';

% Get all test trials
%'TEST_test_data_EMG_190927_123150.mat','TEST_test_data_EMG_190927_123259.mat',...
%'TEST_test_data_EMG_190927_123343.mat','TEST_test_data_EMG_190927_123444.mat',...
%'TEST_test_data_EEG_190927_123620.mat',
DATA = {'TEST_test_data_EEG_190927_123950.mat','TEST_test_data_EEG_190927_124059.mat',...
    'TEST_test_data_EEG_190927_124225.mat','TEST_test_data_EEG_190927_124308.mat',...
    'TEST_test_data_EEG_190927_124645.mat','TEST_test_data_EEG_190927_124741.mat',...
    'TEST_test_data_EEG_190927_124904.mat','TEST_test_data_EEG_190927_124947.mat',...
    'TEST_test_data_EEG_190927_125040.mat','TEST_test_data_EEG_190927_125124.mat',...
    'TEST_test_data_EEG_190927_125734.mat','TEST_test_data_EEG_190927_125822.mat',...
    'TEST_test_data_EEG_190927_130004.mat','TEST_test_data_EMG_190927_130353.mat',...
    'TEST_test_data_EEG_190927_130448.mat','TEST_test_data_EEG_190927_130537.mat',...
    'TEST_test_data_EEG_190927_130622.mat','TEST_test_data_EEG_190927_131118.mat',...
    'TEST_test_data_EEG_190927_131214.mat','TEST_test_data_EEG_190927_131255.mat',...
    'TEST_test_data_EEG_190927_131340.mat'};

% Kalman filter parameters
zscore_data  = 1;
useAug       = 0;
useUKF       = 0;
predict_type = 1; % Changes way state vector is updated. 1: use all last predicted vals. 2: use new at time t and old at t-1...t-Order
KF_ORDER     = 1;%[1,3,6,10];
KF_LAGS      = [1,2:2:10];%,3,6,10];
KF_LAMBDA    = logspace(-2,2,5);
N_trainTrial = 2:length(DATA)-2;
cut_time     = 150; % number of samples to cut before and after to remove flat lines
% Define movement pattern parameters
srate        = 500;

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
%           LOAD TEST DATA           %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%mdl = load(fullfile(datadir,model));
%sinewave = mdl.params.sinewave.wave;
%wavetime = mdl.params.sinewave.time;
load(fullfile(datadir,'target_sinewave.mat'));
close
clear mdl
ALLEEG = cell(1,length(DATA));
ALLKIN = cell(1,length(DATA));
[b,a] = butter(2,[.3 4]/(srate/2),'bandpass');
r1 = zeros(length(DATA),2);
r2 = zeros(length(DATA),2);
for aa = 1:length(DATA)
    temp = load(fullfile(datadir,DATA{aa}));
    ALLEEG{aa} = transpose(zscore(temp.WINEEG(:,1+cut_time:end-cut_time)'));
    %ALLEEG{aa} = rescale_data(temp.WINEEG(:,1+cut_time:end-cut_time),'all');
    ALLKIN{aa} = sinewave(:,1+cut_time:end-cut_time);
    
    
    r1(aa,1) = KalmanFilter.PearsonCorr(zscore(temp.predictedFromEMG(1,:)),zscore(sinewave));
    r1(aa,2) = KalmanFilter.PearsonCorr(zscore(temp.predictedFromEEG(1,:)),zscore(sinewave));
    r2(aa,1) = KalmanFilter.rsquared(zscore(temp.predictedFromEMG(1,:)),zscore(sinewave));
    r2(aa,2) = KalmanFilter.rsquared(zscore(temp.predictedFromEEG(1,:)),zscore(sinewave));
    
    % Faster than SS approach but yields same results
    
%     filtdata = zeros(size(eegdata));
%     for cc = 1:size(eegdata,1)
%         % filter data - not using state space approach but same
%         % results
% %         if realtimefilt
%             filtdata(cc,:) = filter(b,a,eegdata(cc,:));
% %         else
% %             filtdata(cc,:) = filtfilt(b,a,eegdata(cc,:));
% %         end
%     end
    
    
end
% bc = blindcolors;
% figure('color','w','units','inches','position',[5,5,5,3]);
% ax = tight_subplot(1,2,[.2 .1],[.1 .1],[.1 .05]);
% axes(ax(1))
% p1 = scatter(ones(1,size(r1,1)) + 0.05.*randn(1,size(r1,1)),r1(:,1),'filled');
% p1.MarkerFaceColor = bc(6,:);
% p1.SizeData = 10;
% hold on;
% p2 = scatter(2.*ones(1,size(r1,1)) + 0.05.*randn(1,size(r1,1)),r1(:,2),'filled');
% p2.MarkerFaceColor = bc(8,:);
% p2.SizeData = 10;
% boxplot(r1,'color',0.5.*ones(1,3),'Labels',{'EMG','EEG'});
% ylabel('r-value')
% title('Pearson''s Correlation')
% 
% axes(ax(2))
% p3 = scatter(ones(1,size(r2,1)) + 0.05.*randn(1,size(r2,1)),r2(:,1),'filled');
% p3.MarkerFaceColor = bc(6,:);
% p3.SizeData = 10;
% hold on;
% p4 = scatter(2.*ones(1,size(r2,1)) + 0.05.*randn(1,size(r2,1)),r2(:,2),'filled');
% p4.MarkerFaceColor = bc(8,:);
% p4.SizeData = 10;
% boxplot(r2,'color',0.5.*ones(1,3),'Labels',{'EMG','EEG'});
% ylabel('R^2')
% title('Coefficient of Determination')
% export_fig RealTimeDecodingResults_21Trials.png -png -r300


% Initialize for storing R2
R1_MEAN     = cell(length(N_trainTrial),1);
R1_ALL      = cell(length(N_trainTrial),1);
R2_MEAN     = cell(length(N_trainTrial),1);
R2_ALL      = cell(length(N_trainTrial),1);
PREDICT_ALL = cell(length(N_trainTrial),1);
KF_ALL      = cell(length(N_trainTrial),1);

% Loop through each number of training trials
%parfor bb = 1:total
for bb = 1:length(N_trainTrial)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                                    %
    %        TRAIN KALMAN FILTER         %
    %                                    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    traineeg = cat(2,ALLEEG{1,1:N_trainTrial(bb)});
    trainkin = cat(2,ALLKIN{1,1:N_trainTrial(bb)});
    
    % Get test data
    testeeg  = cat(2,ALLEEG{1,end-1:end});
    testkin  = cat(2,ALLKIN{1,end-1:end});
 
    % Get size of each fold
    foldIDX = cumsum([1 cellfun(@(x) size(x,2),ALLEEG(1,1:N_trainTrial(bb)))]);
    
    % Determine kalman filter type
    if useUKF
        kf_method = 'unscented';
    else
        kf_method = 'normal';
    end
    
    % Get mean and std of data
    meantrainkin = mean(trainkin,2);
    stdtrainkin  = std(trainkin,[],2);
    meantestkin = mean(testkin,2);
    stdtestkin  = std(testkin,[],2);
    meantraineeg = mean(traineeg,2);
    stdtraineeg  = std(traineeg,[],2);
    meantesteeg = mean(testeeg,2);
    stdtesteeg  = std(testeeg,[],2);
    allmeanstdkin = {[meantrainkin stdtrainkin]; [meantestkin stdtestkin]};
    allmeanstdeeg = {[meantraineeg stdtraineeg]; [meantesteeg stdtesteeg]};
    
    if zscore_data
        trainkin = transpose(zscore(trainkin'));
        testkin = transpose(zscore(testkin'));
        
        traineeg = transpose(zscore(traineeg'));
        testeeg  = transpose(zscore(testeeg'));
        
        %traineeg = rescale_data(traineeg,'all');
        %testeeg = rescale_data(testeeg,'all');
    end
    
    % Kalman Filter object
    KF = KalmanFilter('state',trainkin,'observation',traineeg,...
        'augmented',useAug,'method',kf_method);
    % Perform grid search
    KF.grid_search('order',KF_ORDER,'lags',KF_LAGS,'lambdaB',KF_LAMBDA,...
        'lambdaF',KF_LAMBDA,'testidx',1,'kfold',foldIDX);
    
    % Lag data
    lagKIN = KalmanFilter.lag_data(testkin,KF.order);
    lagEEG = KalmanFilter.lag_data(testeeg,KF.lags);
    
    % Trim off edges
    maxlag     = max([KF.lags,KF.order]);
    lagKIN_cut = lagKIN(:,maxlag+1:end);
    lagEEG_cut = lagEEG(:,maxlag+1:end);
    
    % Predict data
    predicted = KF.evaluate(lagEEG_cut);
    
    % Store R2 values
    R1_MEAN{bb} = KF.R1_Train;
    R1_ALL{bb} = KF.R1_GridSearch;
    R2_MEAN{bb} = KF.R2_Train;
    R2_ALL{bb} = KF.R2_GridSearch;
    PREDICT_ALL{bb,1} = [predicted(1,:); lagKIN_cut(1,:)];
    KF_ALL{bb,1} = [KF.order,KF.lags,KF.lambdaF,KF.lambdaB];
    
end % end N_trainTrials

filename = ['RealTimeResults_CrossVal_UseWINEEG.mat'];
save(filename,'R2_ALL','R2_MEAN','R1_ALL','R1_MEAN','PREDICT_ALL','KF_ALL');

