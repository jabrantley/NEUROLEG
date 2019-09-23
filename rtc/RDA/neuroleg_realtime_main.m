% Clear the workspace
clc
clear
close all;

% Write to teensy - turn off for no leg control
write2teensy = 0;
train_or_test = 0; % 0 = train; 1 = test

%% Set up biometrics datalog object
b = biometrics_datalog;

%% Set up parmeters
params = neuroleg_realtime_setup;

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
        % Start biometrics
        b.start;
        % Run training
        [RAWEEG,RAWEMG,ANGLEVEC] = neuroleg_realtime_train(params,b);
    otherwise
        % Just in case not previously stopped
        b.stop;
        close all;
        return;
end



