classdef biometrics_datalog < hgsetget
    % Authors: Justin Brantley, Trieu Phat Luu
    % This class is used to initialize and stream data from Biometrics via OnLineInterface64.dll
    % v1: self version only works for single channels - assumes channel 0
    properties (SetAccess = private, GetAccess = public)
        ONLINE_GETERROR = 0; % channel is unused. Return with the current status in pStatus.
        ONLINE_GETENABLE = 1; % pStatus returns with 1 if the specified channel is enabled or 0 if it is not.
        ONLINE_GETRATE = 2; % pStatus returns with the number of samples per second on the specified channel.
        ONLINE_GETSAMPLES = 3; % pStatus returns with the number of unread samples on the specified channel or ONLINE_OVERRUN.
        ONLINE_GETVALUE = 4; %pStatus returns with the (current value + 4000) on the specified channel.
        ONLINE_START = 5; % channel is unused. Start or re-start the data transfer.
        ONLINE_STOP =6; % channel is unused. Stop the data transfer.
        ONLINE_OK = 0; %No communications or buffer errors.
        ONLINE_COMMSFAIL = -3; % Communications with the hardware has failed.
        ONLINE_OVERRUN = -4; %The internal buffer has overflowed and some data has been lost.
        GONIO_GAIN = 180/4000; % +/- 4000 count for +/-180 deg
        EMG_GAIN = 3/4000; % mV DC; for EMG
    end
    properties (SetAccess = public, GetAccess = public)
        
        isonline; % If the Biometrics is online
        samplerate; % Sampling rate;
        samplesavail; % number of available sample for streaming
        usech;
        usechdata; % Streamed data of selected channel
        OnLineInterfaceStr; % Label
        OnLinePathStr;
        values;
        pDataNum;
        pStatus;
        data;
        filtdata;
        envdata;
        
        Xnn=zeros(4,1);
        XnnLowpass = zeros(2,1);
    end
    methods (Access = public) %Constructor
        %Constructor
        function self = biometrics_datalog(varargin)
            self.usech = get_varargin(varargin,'usech',0);
            self.OnLineInterfaceStr = get_varargin(varargin,'OnLineInterfaceStr','OnLineInterface64');
            self.OnLinePathStr = get_varargin(varargin,'OnLinePathStr',cd);
            
            % Add Path and Load Biometrics Dll File
            addpath(self.OnLinePathStr);
            if ~libisloaded(self.OnLineInterfaceStr)  % only load if not already loaded
                [notfound,warnings]=loadlibrary([self.OnLineInterfaceStr, '.dll'], [self.OnLineInterfaceStr '.h']);
            end
            feature('COM_SafeArraySingleDim', 1);   % only use single dimension SafeArrays
            feature('COM_PassSafeArrayByRef', 1);
            
            % Initialisation for Biometrics OnLineInterface
            values = libstruct('tagSAFEARRAY'); % self is the array that receives data from OnLineInterface
            values.cDims = int16(1);
            values.cbElements = 2;   % 2-byte values
            values.cLocks = 0;
            pDataNum = libpointer('int32Ptr', 0);   % some pointers needed by OnLineInterface
            pStatus = libpointer('int32Ptr',0);
            
            % Assign values to object
            self.values = values;
            self.pDataNum = pDataNum;
            self.pStatus = pStatus;
            
            % Execute on init - get sample rate, get gains, clear buffer
            self.getsamplerate;
            self.getchannelgain;
            self.clearbuffer;
        end
        % Get sampling rate
        function srate = getsamplerate(self)
            calllib('OnLineInterface64', 'OnLineStatus', 0, self.ONLINE_GETRATE, self.pStatus);
            if self.pStatus.Value ~= -1
                self.samplerate = double(self.pStatus.Value);
                srate = self.samplerate;
                self.isonline = 1;
            else
                self.isonline = 0;
                disp('Is the DataLog switched on?');
            end
        end
        % Clear buffer on datalog
        function clearbuffer(self)
            for aa = 1:length(self.usech)
                ch = self.usech(aa);
                calllib(self.OnLineInterfaceStr, 'OnLineStatus',ch, self.ONLINE_GETSAMPLES, self.pStatus);
                if (self.pStatus.Value > 0)     % empty buffer only if something is in it and an error has not occurred (-ve)
                    mSinBuffer = floor(self.pStatus.Value * 1000 / self.samplerate);  % round down mS; note that a number of mS must be passed to OnLineGetData.
                    numberInBuffer = mSinBuffer * self.samplerate / 1000;        % recalculate after a possible rounding
                    self.values.rgsabound.cElements = numberInBuffer;            % initialise array to receive the new data
                    self.values.rgsabound.lLbound = numberInBuffer;
                    self.values.pvData = int16(1:numberInBuffer);
                    calllib(self.OnLineInterfaceStr, 'OnLineGetData',ch, mSinBuffer, self.values, self.pDataNum);
                end
            end
        end
        % Get available samples
        function samplesavail = getsamplesavail(self)
            for aa = 1:length(self.usech)
                ch = self.usech(aa);
                calllib('OnLineInterface64', 'OnLineStatus', ch, self.ONLINE_GETSAMPLES, self.pStatus);
                samplesavail = self.pStatus.Value;
                self.samplesavail(aa) = samplesavail;
            end
        end
        % Get channel gains
        function getchannelgain(self)
            % nothing yet
        end
        % Get data from datalog
        function data = getdata(self)
            
            % First initialise the return values from the DLL functions
            for aa = 1:length(self.usech)
                ch = self.usech(aa);
                calllib(self.OnLineInterfaceStr, 'OnLineStatus', ch, self.ONLINE_GETSAMPLES, self.pStatus);
                numberToGet = self.pStatus.Value;
                
                if numberToGet < 0
                    % an error has occurred such as buffer overrun (-4) so exit
                    str = ['OnLineStatus returned ', num2str(numberToGet)];
                    disp(str);
                end
                
                mStoGet = floor(numberToGet * 1000 / self.samplerate);   % round down mS; note that a number of mS must be passed to OnLineGetData.
                numberToGet = mStoGet * self.samplerate / 1000;          % recalculate after a possible rounding
                
                if numberToGet > 0
                    % initialise array to receive the new data
                    self.values.rgsabound.cElements = numberToGet;
                    self.values.rgsabound.lLbound = numberToGet;
                    self.values.pvData = int16(1:numberToGet);
                    
                    % get numberToGet samples from interface
                    calllib(self.OnLineInterfaceStr, 'OnLineGetData', ch, mStoGet, self.values, self.pDataNum);
                    numberOfSamplesReceived = self.pDataNum.Value;   % The number of samples actually returned is pDataNum.Value
                    data(:,aa) = self.values.pvData(:);
                    self.data = data;
                else
                    data = [];
                end
            end
        end
        function start(self)
            calllib('OnLineInterface64', 'OnLineStatus', 0, self.ONLINE_START, 0);
        end
        function stop(self)
            calllib('OnLineInterface64', 'OnLineStatus', 0, self.ONLINE_STOP, 0);
        end
    end
end