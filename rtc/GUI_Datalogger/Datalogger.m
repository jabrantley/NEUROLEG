function Datalogger
% v1.0. 160520.
% Author: Phat Luu. tpluu2207@gmail.com
% Team: Phat Luu, Justin Brantley, Fangshi Zhu
% Brain Machine Interface Lab
% University of Houston, TX
%==========================================================================
% ADD PATHS AND EXTERNAL LIBS
addpath('.\Includes');
% ==BIOMETRICS
biometricslibname = 'OnLineInterface64.dll';
% if ~libisloaded(biometricslibname)
%     try
[notfound, warning] = loadlibrary(biometricslibname)
datalog = class_Biometrics_64bits('numberofvalues',1,'usech',1,'numch',2)
%     catch
%         datalog = [];
%     end
% end
if ~isempty(datalog)
    if datalog.isonline == 1
        fprintf('Datalogger is ONLINE.\n');
        fprintf('Transmition Rate: %.2f.\n', datalog.samplerate);
        fprintf('Number of Channel to Record: %d.\n', datalog.numch);
        fprintf('Number of Sample per frame: %d.\n', datalog.numberOfValues);
    end
end
values = libstruct('tagSAFEARRAY');
numberOfValues = datalog.numberOfValues; % Number of data to scan. 1 sample at a time.
GONIO_GAIN = 180/4000;
EMG_GAIN = 3/4000;
VEC_GAIN = [GONIO_GAIN, EMG_GAIN]; % Modify this based on channel config
loopRate = 100; % Hz
loopTime = 1/loopRate;
datalogval = [];
% Animated line
close all; figure;
npts_dataLine = 5*loopRate;
dataLine = animatedline('MaximumNumPoints',npts_dataLine,...
    'color','k');
set(gca,'ylim',[-300 300])
pause(1);
% Start the datalogger
datalog.stop;
pause(1);
datalog.start;
startTime = tic;
toc_startTime = 0;
logData = [];
while(toc_startTime < 80)
    loopStart = tic; 
    for i = 1: datalog.numch
        % First initialise the return values from the DLL functions
        pstatus = libpointer('int32Ptr', 0);
        calllib('OnLineInterface64', 'OnLineStatus', i-1,...
            datalog.ONLINE_GETSAMPLES, pstatus);
        if pstatus.Value > 0
            pdataNum = libpointer('int32Ptr', 0);
            values.cDims = int16(1);
            values.cbElements = 2;	% 2-byte values
            values.cLocks = 0;
            values.rgsabound.cElements = numberOfValues;
            values.rgsabound.lLbound = numberOfValues;
            Data = int16(1:numberOfValues);
            values.pvData = Data;
            calllib('OnLineInterface64', 'OnLineGetData', i-1 ,...
                numberOfValues * 1000 /datalog.samplerate, values, pdataNum);
            actualval = values.pvData.*VEC_GAIN(1);
            datalogval(i) = actualval;            
        else
            break;
        end        
    end    
    datalogval
    toc_startTime = toc(startTime);
    if ~isempty(datalogval)
        logData = [logData; datalogval];
        addpoints(dataLine,toc_startTime, datalogval(1));
        set(gca,'XLim',datenum([toc_startTime - npts_dataLine/loopRate,...
            toc_startTime]));
        drawnow limitrate;
    end
    while (toc(loopStart) <  loopTime)%
    end
    % Display output for debugging. Comment it
%     fprintf('Sampling Rate: %.2f ms. Elapsed Time: %.2f s\n', toc(loopStart)*1000,toc_startTime);
%     if ~isempty(datalogval)
%         for i = 1 : length(datalogval)-1
%             fprintf('Channel: %d. Data: %.2f', i, datalogval(i))
%         end
%         fprintf('Channel: %d. Data: %.2f.\n', length(datalogval), datalogval(end))
%     end
end
assignin('base','datalogData', logData)
datalog.stop;