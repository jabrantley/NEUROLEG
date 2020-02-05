% Clear the workspace
clc
clear
close all;

% Define directory
thisdir = pwd;
idcs = strfind(pwd,filesep);
parentdir = thisdir(1:idcs(end-2));
addpath(genpath(fullfile(parentdir,'NEUROLEG')));
datadir = fullfile(parentdir,'rtc','EXP_DATA');

% Subject
sub = 'TEST';

% Write to teensy - turn off for no leg control
write2neuroleg = 1;
write2synchbox = 1;
train_or_test  = 0; % 0 = train; 1 = test

% Set up parmeters
params = neuroleg_realtime_setup;

% Set up biometrics datalog object
b = biometrics_datalog('usech',params.setup.BIOchannels,...
    'chantype',{'EMG','DIGITAL'});

% Setup Serial object
% Delete any existing serial objects
if ~isempty(instrfind)
    fclose(instrfind);
end

% Open teensy connection
if write2neuroleg
    try
        teensyLeg = serial('COM32','BaudRate',115200);
        fopen(teensyLeg);
    catch err
        disp(err.message);
        fprintf(['\n-------------------------------',...
            '\n\n   Is the teensy plugged in? \n\n',...
            '-------------------------------\n'])
        return;
    end
else
    teensyLeg = [];
end

% Open teensy connection
if write2synchbox
    try
        teensySynch = serial('COM22','BaudRate',115200);
        fopen(teensySynch);
    catch err
        disp(err.message);
        fprintf(['\n-------------------------------',...
            '\n\n   Is the teensy plugged in? \n\n',...
            '-------------------------------\n'])
        return;
    end
else 
    teensySynch = [];
end

%%
params = neuroleg_realtime_setup;
%% Start Training - follow movement pattern
train_iterations = 4;

% Preallocate for each training iteration
EEG_ALL    = cell(1,train_iterations);
BIO_ALL    = cell(1,train_iterations);
ANGLES_ALL = cell(1,train_iterations);

% Loop through each training iteration
for aa = 1:train_iterations
    StartButton = questdlg(['Iteration ' num2str(aa) ': Ready to start?'],'Stream Data','Start','Stop','Stop');
    switch StartButton
        case 'Start'
            % Start Data Collection
            b.clearbuffer;
            % Open serial if closed and ON = true
            if write2synchbox && strcmpi(teensySynch.Status,'closed')
                fopen(teensySynch)
            end
            if write2neuroleg && strcmpi(teensyLeg.Status,'closed')
                fopen(teensyLeg)
            end
            % Run training
            [EEG_ALL{aa},BIO_ALL{aa},ANGLES_ALL{aa}] = neuroleg_realtime_stream(params,b,teensyLeg,teensySynch);
            % Close all serial
            fclose(instrfind);
        otherwise
            % Just in case not previously stopped
            b.stop;
            close all;
            return;
    end
end

close all;
flname0 = [strjoin({sub,'train','rawdata',datestr(now,'yymmdd'),datestr(now,'HHMMSS')},'_') '.mat'];
save(flname1,'params','EEG_ALL','BIO_ALL','ANGLES_ALL');

%% Train UKF
close all; 
standardize =1;
[params,KF_EMG,KF_EEG,cleaneeg,filteeg,filtemg,envemg,eegMean,eegStDv] = neuroleg_realtime_train(params,cat(2,EEG_ALL{:}),cat(2,BIO_ALL{:}),cat(2,ANGLES_ALL{:}),standardize);
flname1 = [strjoin({sub,'train','model',datestr(now,'yymmdd'),datestr(now,'HHMMSS')},'_') '.mat'];
flname2 = [strjoin({sub,'train','data',datestr(now,'yymmdd'),datestr(now,'HHMMSS')},'_') '.mat'];
save(flname1,'params','KF_EMG','KF_EEG','eegMean','eegStDv');
save(flname2,'cleaneeg','filteeg','filtemg','envemg');

%% TEST UKF
close all;
params = neuroleg_realtime_setup;
%strjoin({datestr(now,'yymmdd'),datestr(now,'HHMMSS')},'_')
control = 'EEG';
gain = 1;
standardize = 1 ;
StartButton = questdlg('Ready to start?','Stream Data','Start','Stop','Stop');
switch StartButton
    case 'Start'
        % Start Data Collection
        b.clearbuffer;
        % Run testing
%         [SYNCHEEG,SYNCHCLEANEEG,SYNCHFILTEEG,SYNCHBIO,SYNCHFILTEMG,SYNCHENVEMG,SYNCHANGLE,WINBIO,WINEEG,predicted_value] = neuroleg_realtime_control(params,b,teensyLeg,teensySynch,KF_EEG,KF_EMG,eegMean,eegStDv,control);
 [SYNCHEEG,SYNCHCLEANEEG,SYNCHFILTEEG,SYNCHBIO,SYNCHANGLE,WINBIO,WINEEG,predicted_value,predictedFromEEG,predictedFromEMG] = neuroleg_realtime_control(params,b,teensyLeg,teensySynch,KF_EEG,KF_EMG,eegMean,eegStDv,control,gain,standardize);
        fclose(instrfind);
    otherwise
        % Just in case not previously stopped
        b.stop;
        close all;
        return;
end

flname3 = [strjoin({sub,'test','model',control,datestr(now,'yymmdd'),datestr(now,'HHMMSS')},'_') '.mat'];
flname4 = [strjoin({sub,'test','data',control,datestr(now,'yymmdd'),datestr(now,'HHMMSS')},'_') '.mat'];
save(flname4,'SYNCHEEG','SYNCHCLEANEEG','SYNCHFILTEEG','SYNCHBIO','SYNCHANGLE','WINBIO','WINEEG','predicted_value','predictedFromEEG','predictedFromEMG');


