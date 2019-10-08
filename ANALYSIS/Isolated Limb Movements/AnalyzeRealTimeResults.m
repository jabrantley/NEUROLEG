%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%          ANALYZE EEG VS ISOLATED LIMB MOVEMENTS IN CHANEL SPACE         %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This code is for looking at EEG vs. joint movements in channel space.

close all;
clear;
clc;

% Run parallel for
runParallel = 1;

% Set drive location
if strcmpi(getenv('username'),'justi')% WHICHPC == 1
    drive = 'D:';
elseif strcmpi(getenv('username'),'jabrantl') %WHICHPC == 2
    drive = 'E:';
elseif strcmpi(computer,'MACI64') % macbook
    drive = '/Volumes/STORAGE/';
end

% Define directories
datadir  = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','REALTIMECONTROL','TF01');

% Add paths
%addpath(genpath(fullfile(basepath,'Brainstorm','brainstorm3','toolbox')));
%addpath(genpath(fullfile(parentdir,'NEUROLEG')));

% Get files for each subject
model = 'TEST_train_model_190927_123846.mat';

% Get data
data = {'TEST_test_data_EEG_190927_123950.mat','TEST_test_data_EEG_190927_124059.mat',...
    'TEST_test_data_EEG_190927_124225.mat','TEST_test_data_EEG_190927_124308.mat',...
    'TEST_test_data_EEG_190927_124645.mat','TEST_test_data_EEG_190927_124741.mat',...
    'TEST_test_data_EEG_190927_124904.mat','TEST_test_data_EEG_190927_124947.mat',...
    'TEST_test_data_EEG_190927_125040.mat','TEST_test_data_EEG_190927_125124.mat'};

% Define frequency bands
lodelta = [.3 1.5];
delta = [.3 4];
alpha = [8 13];
himu  = [10 12];
theta = [4 8];
beta  = [15 30];
gamma = [30 55];
higamma = [65 90];
full  = [.3 50];
BANDS = {lodelta,delta};%,theta,alpha,beta,gamma,higamma,full};
% bcs =  blindcolors;
% bcs = bcs([2,3,4,8,6,7],:);

% Channels to keep for analysis NOTE: FT10 is in FCz location
chans2keep = {'F4','F2','Fz','F1','F3','FC3','FC1','FT10','FC2','FC4','C4','C2','Cz',...
    'C1','C3',};%'CP3','CP1','CPz','CP2','CP4'};
randorder1 = randperm(length(chans2keep));
%chans2keepExpanded = {'FC3','FC1','FT10','FC2','FC4','C4','C2','Cz',...
%   'C1','C3','CP3','CP1','CPz','CP2','CP4'};
leftMotor  = {'F4','F2','Fz','F1','F3','FC3','FC1','FT10','Cz',...
    'C1','C3'};%,'CP3','CP1','CPz'};
randorder2 = randperm(length(leftMotor));
randord = {randorder1,randorder2};
% Filter parameters
filter_order = 2;
use_velocity = 1;
predict_type = 1; % Changes way state vector is updated. 1: use all last predicted vals. 2: use new at time t and old at t-1...t-Order

% Kalman filter parameters
KF_ORDER  = [3,5,10];
KF_LAGS   = [3,5,10];
KF_LAMBDA = logspace(-2,2,5);

% Setup parallel pool
if runParallel
    poo = gcp('nocreate');
    if isempty(poo)
        try
            parpool(16);
        catch
            numCores = feature('numcores');
            parpool(numCores);
        end
    end
end

    % Get channel locations
    chans2keepIDX = params.setup.chans2keep;
    
    % Get filt bands and channel locations
    total = 1;
    for bb = 1:length(BANDS)
        for cc = 1:
            combos{total,1} = BANDS{bb};
            combos{total,2} = montages{cc};
            combos{total,4} = randord{cc};
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
    
    % Initialize for storing R2
    R2_sub = cell(total,1);
    predicted_sub = cell(total,1);
    
    % Get EEG data for channels to keep
    eegdata  = EEG.data(chans2keepIDX,:);
    
    % Loop through each frequency band
    parfor bb = 1:total
        %for bb = 1:total
        
        % Design filters
        bp_filt = make_ss_filter(filter_order,combos{bb,1},srate,'bandpass');
        
        % Filter data
        filtdata = zeros(size(eegdata));
        for cc = 1:size(eegdata,1)
            % filter data - state space approach
            xnn_bp = zeros(filter_order*2,1);
            filtdata(cc,:) = use_ss_filter(bp_filt,eegdata(cc,:),xnn_bp);
        end
        
        %         allfilt{bb} = filtdata;
        
        % Initialize for storing data for each movement
        movedata = [];
        alleeg   = [];
        allgonio = [];
        count = 1;
        for cc = 1:size(movetimes,1)
            % Get data for each trial
            %trialdata = filtdata(:,movetimes{cc,1});
            goniodata = GONIO(cc).data;
            % Get data for movements
            window_buffer = 1*EEG.srate; % 1 second shift TO ACCOUNT FOR ONSET ERROR
            for dd = 1:size(movetimes{cc,2},1)
                temp_times = movetimes{cc,2}(dd,1)+window_buffer: movetimes{cc,2}(dd,2)+window_buffer;
                alleeg   = cat(2,alleeg,filtdata(:,temp_times));
                allgonio = cat(2,allgonio,goniodata(:,temp_times));
                movedata{count,1} = filtdata(:,temp_times);
                movedata{count,2} = goniodata(:,temp_times);
                count = count + 1;
            end
        end
        
        % Train / test split
        test_trials = 4;
        train_trials  = size(movedata,1) - test_trials;
        
        % window for hilbert
        envwindow = srate;
        
        % Initialize
        testeeg  = [];
        testkin  = [];
        testidx  = [];
        trainidx = [];
        traineeg = [];
        trainkin = [];
        
        for dd = 1:size(movedata,1) % for each movement window
            % Get data for specific channels
            tempeeg = movedata{dd}(combos{total,2},:);
            
            % If delta then use raw potential, otherwise use envelope
            if combos{total,3} == 0
                datavec = tempeeg;
            else
                [datavec, ~]= envelope(tempeeg',envwindow,'analytic'); % applies hilbert with specified window size: 1 second
                datavec = datavec';
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
        
        
        % TIMING LOOP HERE
        tstart = 1;
        tend   = tstart + 1/20 * srate;
        traineeg_win = []; trainkin_win = [];
        while tend <= size(trainkin,2)
            % Get window of mean power/potential and corresponding kin val
            traineeg_win = [traineeg_win, mean(traineeg(:,tstart:tend),2)];
            trainkin_win = [trainkin_win, trainkin(:,tend)];
            % Update start and end
            tstart = tend + 1;
            tend   = tstart + 1/20 * srate;
        end
        tstart = 1;
        tend   = tstart + 1/20 * srate;
        testeeg_win = [];  testkin_win = [];
        while tend <= size(testkin,2)
            % Get window of mean power/potential and corresponding kin val
            testeeg_win = [testeeg_win, mean(testeeg(:,tstart:tend),2)];
            testkin_win = [testkin_win, testkin(:,tend)];
            % Update start and end
            tstart = tend + 1;
            tend   = tstart + 1/20 * srate;
        end
        
        trainkin = trainkin_win;
        traineeg = traineeg_win(combos{total,4},:);
        testkin  = testkin_win;
        testeeg  = testeeg_win(combos{total,4},:);
        
        
        % Zscore data
        trainkin = transpose(zscore(trainkin'));
        traineeg = transpose(zscore(traineeg'));
        testeeg  = transpose(zscore(testeeg'));
        testkin  = transpose(zscore(testkin'));
        
        %         ord = 3;
        %         lagKINtrain = KalmanFilter.lag_data(trainkin,1);
        %         lagEEGtrain = KalmanFilter.lag_data(traineeg,1);
        %         lagKINtest = KalmanFilter.lag_data(testkin,1);
        %         lagEEGtest = KalmanFilter.lag_data(testeeg,1);
        %         svr = fitrsvm(traineeg',trainkin','KernelFunction','rbf',...
        %              'Standardize',true,'KernelScale','auto');
        %          svr = fitrsvm(lagEEGtrain',lagKINtrain','KernelFunction','rbf',...
        %              'Standardize',true,'KernelScale','auto','KFold',5);
        %          cvsvr = crossval(svr);
        
        %          predicted = predict(svr,testeeg');
        %
        %          % Store R2 values
        %          R2_sub{bb} = KalmanFilter.rsquared(predicted,testkin);
        %          predicted_sub{bb} = [predicted(:)'; testkin(:)'];
        
        % Kalman Filter object
        KF = KalmanFilter('state',trainkin,'observation',traineeg,...
            'augmented',1,'method','unscented');
        % Perform grid search
        foldIdx = cumsum([1 sum(trainidx(1:6)) sum(trainidx(7:end))-1]);
        KF.grid_search('order',KF_ORDER,'lags',KF_LAGS,'lambdaB',KF_LAMBDA,...
            'lambdaF',KF_LAMBDA,'testidx',1);%,'kfold',foldIdx);
        
        % Lag data
        lagKIN = KalmanFilter.lag_data(testkin,KF.order);
        lagEEG = KalmanFilter.lag_data(testeeg,KF.lags);
        
        % Trim off edges
        lagKIN_cut = lagKIN(:,KF.lags+1:end);
        lagEEG_cut = lagEEG(:,KF.lags+1:end);
        
        % Predict data
        predicted = KF.evaluate(lagEEG_cut);
        
        % Store R2 values
        R2_sub{bb} = KF.R2_Train;
        predicted_sub{bb} = [predicted(1,:); lagKIN_cut(1,:)];
        
        
        % clean up
        % clear testeeg testkin testidx traineeg trainkin trainidx
        
        
    end % end BANDS{bb}
    
    % Store R2 values
    R2_ALL{aa} = R2_sub;
    PREDICT_ALL{aa} = predicted_sub;
end

save('allR2_50msWindow_FrontalChans_shuffle.mat','R2_ALL')
save('allPredict_50msWindow_FrontalChans_shuffle.mat','PREDICT_ALL')

delete(gcp('nocreate'));



