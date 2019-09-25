% Clear the workspace
clc
clear
close all;

% Write to teensy - turn off for no leg control
write2teensy = 0;
train_or_test = 0; % 0 = train; 1 = test

%% Set up parmeters
params = neuroleg_realtime_setup;

%% Set up biometrics datalog object
b = biometrics_datalog('usech',params.setup.BIOchannels,...
                       'chantype',{'EMG','DIGITAL'});
%% Setup Serial object
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

%% Start Training - follow movement pattern
StartButton = questdlg('Ready to start?','Stream Data','Start','Stop','Stop');
switch StartButton
    case 'Start'
        % Start Data Collection
        b.clearbuffer;
        % Run training
        [EEG,BIO,ANGLES] = neuroleg_realtime_stream(params,b);
        % Close all serial
        fclose(instrfind);
    otherwise
        % Just in case not previously stopped
        b.stop;
        close all;
        return;
end

%% Train UKF







