%% Initialisation
clc
clear variables;  % just in case library has outstanding objects.
close all;
 
%% Configure for version of MATLAB
OnLineInterfaceStr = 'OnLineInterface64';     % set to 'OnLineInterface64' for 64-bit MATLAB or 'OnLineInterface' for 32-bit MATLAB
OnLinePathStr = 'D:\GUI_Apps\GUI_Datalogger'; % will need to be changed 

%% Set Variables
durationSecs = 10; % duration in seconds
ch = 0;  % will need to be changed to match the sensor channel
 
%% Add Path and Load Biometrics Dll File
addpath(OnLinePathStr);
if ~libisloaded(OnLineInterfaceStr)  % only load if not already loaded
    [notfound,warnings]=loadlibrary([OnLineInterfaceStr, '.dll'], 'OnLineInterface.h');
end
feature('COM_SafeArraySingleDim', 1);   % only use single dimension SafeArrays
feature('COM_PassSafeArrayByRef', 1);
 
%% Initialisation for Biometrics OnLineInterface
values = libstruct('tagSAFEARRAY'); % this is the array that receives data from OnLineInterface
values.cDims = int16(1);
values.cbElements = 2;   % 2-byte values
values.cLocks = 0;
pDataNum = libpointer('int32Ptr', 0);   % some pointers needed by OnLineInterface
pStatus = libpointer('int32Ptr',0);
% get the sample rate which is returned as an integer
calllib(OnLineInterfaceStr, 'OnLineStatus', ch, OLI.ONLINE_GETRATE, pStatus);
sampleRate = double(pStatus.Value); % force all maths using sampleRate to use floating point
 
%% Open Figure
figure(...
    'Position', get(0, 'ScreenSize'),...
    'NumberTitle', 'off',...
    'Name', 'EMG');
title('EMG');
P = plot(nan, nan);
xlabel('Time (s)')
ylabel('Amplitude')
axis([0 durationSecs -4000 4000]);
 
%% Empty data buffer in DLL before starting
calllib(OnLineInterfaceStr, 'OnLineStatus', ch, OLI.ONLINE_GETSAMPLES, pStatus);
if (pStatus.Value > 0)     % empty buffer only if something is in it and an error has not occurred (-ve)
    mSinBuffer = floor(pStatus.Value * 1000 / sampleRate);  % round down mS; note that a number of mS must be passed to OnLineGetData.
    numberInBuffer = mSinBuffer * sampleRate / 1000;        % recalculate after a possible rounding
    values.rgsabound.cElements = numberInBuffer;            % initialise array to receive the new data
    values.rgsabound.lLbound = numberInBuffer;
    values.pvData = int16(1:numberInBuffer);
    calllib(OnLineInterfaceStr, 'OnLineGetData', ch, mSinBuffer, values, pDataNum);
end

%% Start Data Collection
calllib(OnLineInterfaceStr,'OnLineStatus', ch, OLI.ONLINE_START, pStatus);

%% Plot Figure Data as soon as it arrives
inputIndex = 1;         % start index of new data in P.YData
zeroSamplesCounter = 0; % used to check for errors due to insufficient data in a period
SamplesLeftToPlot = sampleRate * durationSecs;   % total number of samples remaining to plot
while SamplesLeftToPlot > 0
    calllib(OnLineInterfaceStr, 'OnLineStatus', ch, OLI.ONLINE_GETSAMPLES, pStatus);
    numberToGet = pStatus.Value;
    if numberToGet < 0
        % an error has occurred such as buffer overrun (-4) so exit
        str = ['OnLineStatus returned ', num2str(numberToGet)];
        disp(str);
        close all;
        break;
    end
    if numberToGet == 0
        zeroSamplesCounter = zeroSamplesCounter + 1;
        if (zeroSamplesCounter > 10000)     % a maximum that depends upon the speed of the PC
            % something has failed so exit rather than loop forever
            disp('Are you sure that Save to File mode is off and all sensors are switched on?');
            close all;
            break;
        end         
    else
        zeroSamplesCounter = 0;                 % clear error detection
        if numberToGet > SamplesLeftToPlot
            numberToGet = SamplesLeftToPlot;    % no more than the total number of samples required
        end
        mStoGet = floor(numberToGet * 1000 / sampleRate);   % round down mS; note that a number of mS must be passed to OnLineGetData.
        numberToGet = mStoGet * sampleRate / 1000;          % recalculate after a possible rounding
        % initialise array to receive the new data
        values.rgsabound.cElements = numberToGet;
        values.rgsabound.lLbound = numberToGet;
        values.pvData = int16(1:numberToGet);
        % get numberToGet samples from interface
        calllib(OnLineInterfaceStr, 'OnLineGetData', ch, mStoGet, values, pDataNum);
        numberOfSamplesReceived = pDataNum.Value;   % The number of samples actually returned is pDataNum.Value
        % Now add the new data into the Figure array and update it
        inputIndexEnd = inputIndex + numberOfSamplesReceived - 1;
        P.YData(1, inputIndex : inputIndexEnd) = values.pvData(:);
        P.XData = 0 : 1 / sampleRate : (length(P.YData) - 1) / sampleRate;
        drawnow
        % update how far through the graph we currently are
        inputIndex = inputIndex + numberOfSamplesReceived;  
        SamplesLeftToPlot = SamplesLeftToPlot - numberOfSamplesReceived;
    end    
end

%% Stop Data Collection
calllib(OnLineInterfaceStr,'OnLineStatus', ch, OLI.ONLINE_STOP, pStatus);
