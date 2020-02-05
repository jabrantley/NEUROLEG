function Neuroleg_RTControl_Demo

% Clear the workspace
clc
close all;
clear all;

%% Set Variables
write2teensy = 1;
b = biometrics_datalog;
GAIN_VAL = b.EMG_GAIN;
JOINT_ANGLES = [1, 60];
UPDATE_RATE = 1/50;
FILTER_FREQZ = [35 245 4];
FILTER_ORDER = 2;
USE_VEL = 1;
PREDICT_TYPE = 1; % Changes way state vector is updated. 1: use all last predicted vals. 2: use new at time t and old at t-1...t-Order

% Kalman filter parameters
KF_ORDER  = 1;
KF_LAGS   = 1;
KF_LAMBDA = logspace(-2,2,5);

% Generate sine wave for following pattern
numCycles = 4;   % number of cycles
trainCycles = numCycles-2; % number of cycles to keep for training
move_freq = .25; % speed of moving dot in hz
Tau = numCycles*(1/move_freq); % time constant
timevec = 0:UPDATE_RATE:Tau; % time vector

% Zero crossings - possible feature
zcd = dsp.ZeroCrossingDetector;

% Check if datalogger is turned on
if ~b.isonline
    return;
end


%% Setup serial object

% Delete any existing serial objects
if ~isempty(instrfind)
    fclose(instrfind);
end

% Open teensy connection
if write2teensy
    try
        teensy = serial('COM32','BaudRate',115200);
        fopen(teensy);
    catch err
        disp(err.message);
        fprintf(['\n-------------------------------',...
            '\n\n   Is the teensy plugged in? \n\n',...
            '-------------------------------\n'])
        return;
    end
end

%% Design filters
bp_filt = make_ss_filter(FILTER_ORDER,FILTER_FREQZ(1:2),b.samplerate,'bandpass');
lp_filt = make_ss_filter(FILTER_ORDER,FILTER_FREQZ(3),1/UPDATE_RATE,'low');
xnn_bp = zeros(FILTER_ORDER*2,1);
xnn_lp = zeros(FILTER_ORDER,1);

% Constant velocity - position only
%stooth = sawtooth(2*pi*.25*timevec,1/2);
%sinwave = 60.*(stooth - min(stooth))/(max(stooth)-min(stooth));

% Variable velocity - smoother and more natural
sinwave = (JOINT_ANGLES(2)/2) + (JOINT_ANGLES(2)/2)*cos(move_freq*2*pi*timevec+pi);
dsinwave = diff([0 sinwave]);

% Generate figure for following moving dot
f = figure('color','w'); f.Position = [962, 42, 958, 954];
% f = figure('color','w','units','inches','position',[-16.5 1.5 15.5 7.5]);
ax = gca; ax.Position = [.1 .55 .85 .4]; ax.Box = 'on';
p = plot(sinwave,sinwave); hold on;
s = scatter(0,0,75,'filled');

% Generate figure for following moving dot
%f1 = figure('color','w');
ax1 = axes; ax1.Position = [.1 .05 .85 .4]; ax1.Box = 'on';
p1 = plot(timevec,sinwave/max(sinwave)); hold on;
s1 = scatter(timevec(1),sinwave(1)/max(sinwave),125,'filled');

%% Start Training - follow movement pattern
StartButton = questdlg('Ready to start?','Stream Biometrics','Start','Stop','Stop');
switch StartButton
    case 'Start'
        % Start Data Collection
        b.clearbuffer;
    otherwise
        % Just in case not previously stopped
        b.stop;
        close all;
        return;
end

% Initialize empty variables
train_data_contract = [];
train_data_contract_filt = [];
train_data_contract_env = nan(length(sinwave),1);
% If pos and velocity used in KF
if USE_VEL
    angvals = nan(length(sinwave),2);
else
    angvals = nan(length(sinwave),1);
end
% Counter
cntr = 1;
% Start biometrics
b.start;
% Get start time
startTrain = tic;
lasttime=toc(startTrain);
% Start loop
while true
    % Update rate
    if ge(toc(startTrain) - lasttime,UPDATE_RATE)
        % Get data from datalog
        train_data_contract_raw = double(b.getdata).*GAIN_VAL;
        if ~isempty(train_data_contract_raw)
            % Update dot position
            s.XData = sinwave(cntr);
            s.YData = sinwave(cntr);
            % Update dot position
            s1.XData = timevec(cntr);
            s1.YData = sinwave(cntr)/max(sinwave);
            %p_env.YData = meanvals(:)';
            pause(0.0001); % pause to refresh
            % Store raw data
            train_data_contract = [train_data_contract(:); train_data_contract_raw(:)];
            % Bandpass filter
            [train_data_contract_bp,xnn_bp] = use_ss_filter(bp_filt,train_data_contract_raw,xnn_bp);
            train_data_contract_filt = [train_data_contract_filt; train_data_contract_bp];
            % Compute absolute value
            mav = mean(abs(train_data_contract_bp));
            % Low pass filter
            [train_data_contract_lp,xnn_lp] = use_ss_filter(lp_filt,mav,xnn_lp); % envelope is calculated at new sampling rate of 1/UPDATE_RATE
            % Store lp filter data - envelope
            train_data_contract_env(cntr) = train_data_contract_lp;
            % Store angle
            if USE_VEL
                angvals(cntr,:) = [sinwave(cntr) dsinwave(cntr)];
            else
                angvals(cntr,:) = sinwave(cntr);
            end
            % Update counter
            cntr = cntr+1;
            % Break while loop
            if ge(cntr,length(sinwave))
                break
            end
        end
        % Get new time
        lasttime = toc(startTrain);
    end % end UPDATE_RATE condition
end % end while loop
% Stop datalog
b.stop;
pause(1);
% Remove NaNs
meanvals = removeNaNs(train_data_contract_env);
% Rescale
meanvals = meanvals./max(meanvals);
% Plot smoothed MAV
close;
figure; plot(timevec,rescale(sinwave)); hold on;
plot(timevec,rescale(meanvals));
title('Mean Env'); xlabel('EMG Envelope Amplitude'); ylabel('Angle');
pause(1);

%% Split train/test but keeping full cycle together
where_zero = find(sinwave==0)';
cycles = [where_zero(1:end-1) , where_zero(2:end)-1];
rand_cycle = randperm(numCycles);
train_cycles = cycles(rand_cycle(1:trainCycles),:);
test_cycles = cycles(rand_cycle(trainCycles+1:end),:);

% Get kfold idx
diff_where_zero = diff(where_zero);
%foldIdx = diff_where_zero(rand_cycle(1:trainCycles));%
foldIdx = cumsum([1; diff_where_zero(rand_cycle(1:trainCycles))]);

% Train data
train_emg = []; train_ang = [];
for ii = 1:length(train_cycles)
    cycle_time = train_cycles(ii,1):train_cycles(ii,2);
    train_emg = [train_emg; meanvals(cycle_time)];
    train_ang = [train_ang; angvals(cycle_time,:)];
end

% Test data
test_emg = []; test_ang = [];
for ii = 1:length(test_cycles)
    cycle_time = test_cycles(ii,1):test_cycles(ii,2);
    test_emg = [test_emg; meanvals(cycle_time)];
    test_ang = [test_ang; angvals(cycle_time,:)];
end

%% Perform linear regression for visualization
Y = train_ang(:,1);
X = train_emg;
MAX_VAL = quantile(X,.97);
beta = (X./MAX_VAL)\Y;

%% Train Kalman Filter
KF = KalmanFilter('state',train_ang','observation',train_emg','augmented',0,...
    'method','normal');
% Perform grid search
KF.grid_search('order',KF_ORDER,'lags',KF_LAGS,'lambdaB',KF_LAMBDA,'lambdaF',KF_LAMBDA,'kfold',foldIdx,'testidx',1);
% Test using remaining validation data
test_emg_lag = KalmanFilter.lag_data(test_emg',KF.lags);
test_ang_lag = KalmanFilter.lag_data(test_ang',KF.order);
test_emg_cut = test_emg_lag(:,KF.lags+1:end);
test_ang_cut = test_ang_lag(:,KF.lags+1:end);%test_ang(KF.lags:end,:)';
% Evaluate using training data
prediction = KF.evaluate(test_emg_cut);
% Compute R2 value
R2_test = KF.rsquared(prediction,test_ang_cut);%(1,KF.order+1:end)
% Plot predicted and actual
figure('color','w'); plot(prediction(1,:)); hold on; plot(test_ang_cut(1,:))
xlabel('Time'); ylabel('Angle'); title(['Kalman Filter Prediction: R2 = ' num2str(R2_test(1))]);
legend({'Predicted','Actual'});

% Plot linear mapping for visualization
f = figure('color','w');
f.Position = [962, 42, 958, 954];
p = plot((0:JOINT_ANGLES(2))./beta,(0:JOINT_ANGLES(2)));
xlabel('Muscle Activity (EMG)')
ylabel('Joint Angle (degrees)')
hold on;
% Initialize moving dot
s = scatter(0,0,35,'filled');

% Start control
StartButton = questdlg('Ready to start closed-loop control?','Stream Biometrics','Start','Stop','Stop');
switch StartButton
    case 'Start'
        % Start Data Collection
        b.clearbuffer;
        % Write to teensy
        if write2teensy
            fprintf(teensy,'%.2f',JOINT_ANGLES(1))
            fprintf(teensy,'%s','\n')
        end
    otherwise
        % Just in case not previously stopped
        b.stop;
        close all;
        return;
end

% Initialize
fs      = stoploop('Stop biometrics...');
% If use velocity
if USE_VEL
    KIN = zeros(KF.order*2,1);
else
    KIN = zeros(KF.order,1);
end
EMG     = zeros(KF.lags,1);
xnn_bp  = zeros(FILTER_ORDER*2,1);
xnn_lp  = zeros(FILTER_ORDER,1);
counter = 1;

startTrain = tic;
b.start;
lasttime= toc(startTrain);
alldata = [];
lpdata  = [];
envdata = [];
angdata = [];
% Now loop until button is pressed
while ~fs.Stop()
    if ge(toc(startTrain) - lasttime,UPDATE_RATE)
        tempdata_raw = double(b.getdata).*GAIN_VAL;
        alldata = [alldata(:); tempdata_raw(:)];
        if ~isempty(tempdata_raw)
            % Bandpass filter
            [tempdata_bp,xnn_bp] = use_ss_filter(bp_filt,tempdata_raw,xnn_bp);
            % Compute absolute value
            mav = mean(abs(tempdata_bp));
            % Low pass filter to compute
            [tempdata_lp,xnn_lp] = use_ss_filter(lp_filt,mav,xnn_lp);
            lpdata = [lpdata; nan(length(tempdata_bp)-1,1); tempdata_lp];
            % Add data to EMG
            if KF.lags > 1
                EMG = [tempdata_lp; EMG(1:KF.lags-1)];
            else
                EMG = tempdata_lp;
            end
            % Add data to envelope vector
            envdata = [envdata; tempdata_lp];
            % Predict angle using kalman filter
            predicted_value = KF.predict(EMG);
            % Get position
            final_predicted_value = predicted_value(1);
            angdata = [angdata; final_predicted_value];
            % Constrain to joint limits
            if final_predicted_value < JOINT_ANGLES(1)
                final_predicted_value = JOINT_ANGLES(1);
            elseif final_predicted_value > JOINT_ANGLES(2)
                final_predicted_value = JOINT_ANGLES(2);
            end
            % Add back to KIN vector for later use
            % predicted_value(1) = final_predicted_value;
            % Add data to KIN
            if PREDICT_TYPE == 1
                KIN = predicted_value;
            elseif PREDICT_TYPE == 2
                if KF.order > 1
                    if USE_VEL
                        KIN = [predicted_value(1:2); KIN(1:2*(KF.order-1))];
                    else
                        KIN = [predicted_value(1); KIN(1:KF.order-1)];
                    end
                else
                    KIN = final_predicted_value;
                end
            end
            % Do not write to teensy if counter is < than max(order,lags)
            if counter < 1/UPDATE_RATE%max([KF.order,KF.lags])
                % do nothing
            else
                % Write to teensy
                if write2teensy
                    %ang = 30;fprintf(teensy,'%.2f',ang); fprintf(teensy,'%s','\n')
                    fprintf(teensy,'%.2f',final_predicted_value/MAX_VAL)
                    fprintf(teensy,'%s','\n')
                end
                % Update plot
                s.XData = final_predicted_value/beta(1);
                s.YData = final_predicted_value;
            end
            % Increment counter
            counter = counter + 1;
            % Store time
            lasttime=toc(startTrain);
        end % end if ~isempty
    end % end time check
end % end while ~fs.Stop()

% Stop recording & clean up
b.stop;
if write2teensy
    fclose(teensy);
end
close all;
% plot(alldata); hold on; plot(envdata,'linewidth',1.5);
fs.Clear();

end
% Remove nan values
function out = removeNaNs(in)
% Get nan values
nanvals = find(isnan(in));
% Remove if any
if ~isempty(nanvals)
    for ii = 1:length(nanvals)
        if nanvals(ii) == 1
            in(ii) = 0;
        else
            in(nanvals(ii)) = in(nanvals(ii)-1);
        end
    end
end % end if
out = in;
end % end removeNaNs
