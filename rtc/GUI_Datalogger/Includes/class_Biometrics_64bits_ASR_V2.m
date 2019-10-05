classdef class_Biometrics_64bits_ASR_V2 < hgsetget;
    % Date 160601.
    % Biometrics class is written based on Help Menu from Biometrics Datalog_it
    % Software
    % This class initialize and stream data from Biometrics via OnLineInterface64.dll
    properties
    end
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
        isuse; % decide to use Biometrics or not
        isonline; % If the Biometrics is online
        samplerate; % Sampling rate;
        avaisamples; % number of available sample for streaming
        numberOfValues; % Number of data to scan
        usech;
        usechdata; % Streamed data of selected channel
        numch; % Number of channels used
        sensors; % cell string, type of sensors: gonio or emg
        vecgain; % Vector of gonio_gain and emg_gain
        buffer_data;
    end
    methods (Access = public) %Constructor
        %Constructor
        function this = class_Biometrics_64bits_ASR_V2(varargin)
            this.isuse = get_varargin(varargin,'isuse',0);
            this.numberOfValues = get_varargin(varargin,'numberofvalues',10);
            this.usech = get_varargin(varargin,'usech',1);
            this.numch = length(this.usech);
            this.sensors = get_varargin(varargin,'sensor',{'gonio','gonio','gonio','gonio',...
                'gonio','gonio','gonio','gonio'});
            this.vecgain = get_varargin(varargin,'gain',this.GONIO_GAIN);
            this.buffer_data = NaN(this.numch, 1);
            this.getsamplerate;
            
        end
        
        function clearBuffer(this)
            %% Empty data buffer in DLL before starting
            %% Initialisation for Biometrics OnLineInterface
            values = libstruct('tagSAFEARRAY'); % this is the array that receives data from OnLineInterface
            values.cDims = int16(1);
            values.cbElements = 2;   % 2-byte values
            values.cLocks = 0;
            pDataNum = libpointer('int32Ptr', 0);   % some pointers needed by OnLineInterface
            pStatus = libpointer('int32Ptr',0);
            calllib('OnLineInterface64', 'OnLineStatus', 0, this.ONLINE_GETSAMPLES, pStatus);
            if (pStatus.Value > 0)     % empty buffer only if something is in it and an error has not occurred (-ve)
                mSinBuffer = floor(pStatus.Value * 1000 / this.samplerate);  % round down mS; note that a number of mS must be passed to OnLineGetData.
                numberInBuffer = mSinBuffer * this.samplerate / 1000;        % recalculate after a possible rounding
                values.rgsabound.cElements = numberInBuffer;            % initialise array to receive the new data
                values.rgsabound.lLbound = numberInBuffer;
                values.pvData = int16(1:numberInBuffer);
                calllib('OnLineInterface64', 'OnLineGetData', 0, mSinBuffer, values, pDataNum);
            end
        end
        function sampling_rate = getsamplerate(this)
            pstatus = libpointer('int32Ptr', 0);
            sampling_rate = 0;
            calllib('OnLineInterface64', 'OnLineStatus', 0,...
                this.ONLINE_GETRATE, pstatus)
            if pstatus.Value ~= -1
                 sampling_rate = double(pstatus.Value);
                this.isonline = 1;
            else
                this.isonline = 0;
            end
            this.samplerate = double(sampling_rate);
        end
        
        function avai_samples = getavaisamples(this)
            pstatus = libpointer('int32Ptr', 0);
            calllib('OnLineInterface64', 'OnLineStatus', 0,...
                this.ONLINE_GETSAMPLES, pstatus);
            avai_samples = pstatus.Value;
        end
        
        function comm_stat = get_comm_status(this)
            pstatus = libpointer('int32Ptr', 0);
            calllib('OnLineInterface64', 'OnLineStatus', 0,...
                this.ONLINE_COMMSFAIL, pstatus);
            comm_stat = pstatus.Value;
        end
        
        function buffer_stat = get_buffer_status(this)
            pstatus = libpointer('int32Ptr', 0);
            calllib('OnLineInterface64', 'OnLineStatus', 0,...
                this.ONLINE_OVERRUN, pstatus);
            buffer_stat = pstatus.Value;
        end
        
        function getvecgain(this)
            for i = 1: length(this.sensors)
                thissensor = this.sensors{i};
                if strcmpi(thissensor,'gonio')
                    this.vecgain(i) = this.GONIO_GAIN;
                elseif strcmpi(thissensor,'emg')
                    this.vecgain(i) = this.EMG_GAIN;
                end
            end
        end
        
        function [handles,Datalog_it] = getdata(this,handles,Datalog_it) 
            
   
            %% Start Data Collection
            calllib('OnLineInterface64','OnLineStatus', Datalog_it.ch, OLI.ONLINE_START, Datalog_it.pStatus); 
   
            calllib('OnLineInterface64','OnLineStatus', Datalog_it.ch, OLI.ONLINE_GETSAMPLES, Datalog_it.pStatus);
            numberToGet = Datalog_it.pStatus.Value;  
            mStoGet = floor(numberToGet * 1000 / Datalog_it.sampleRate);   % round down mS; note that a number of mS must be passed to OnLineGetData.
            numberToGet = mStoGet * Datalog_it.sampleRate / 1000;          % recalculate after a possible rounding
            % initialise array to receive the new data
            Datalog_it.values.rgsabound.cElements = numberToGet;
            Datalog_it.values.rgsabound.lLbound = numberToGet;
            Datalog_it.values.pvData = int16(1:numberToGet);

            calllib('OnLineInterface64', 'OnLineGetData', Datalog_it.ch, mStoGet, Datalog_it.values, Datalog_it.pdataNum);
            Datalog_it.numberOfSamplesReceived = Datalog_it.pdataNum.Value;   % The number of samples actually returned is pDataNum.Value
            Datalog_it.inputIndexEnd = Datalog_it.inputIndex + Datalog_it.numberOfSamplesReceived - 1;
            Datalog_it.EMG_data=[Datalog_it.EMG_data,double(Datalog_it.values.pvData)*3/4000];
 

        end
        
        function start(this)
            calllib('OnLineInterface64', 'OnLineStatus', 0, this.ONLINE_START, 0);
        end
        function stop(this)
            calllib('OnLineInterface64', 'OnLineStatus', 0, this.ONLINE_STOP, 0);
        end
    end
    methods (Access = private) %Destructor
        function delete(this)
            %Do sth when object is destructed.
        end
    end
    methods (Static)
        % Functions without class input
    end
end