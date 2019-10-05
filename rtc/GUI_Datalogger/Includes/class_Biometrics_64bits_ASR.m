classdef class_Biometrics_64bits_ASR < hgsetget;
    % Date 160601.
    % Biometrics class is written based on Help Menu from Biometrics Datalog
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
        Xnn=zeros(4,1);
        XnnLowpass = zeros(2,1);
    end
    methods (Access = public) %Constructor
        %Constructor
        function this = class_Biometrics_64bits_ASR(varargin)
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
        
        function [datalogval,handles] = getdata(this,handles)            
            values = libstruct('tagSAFEARRAY'); % this is the array that receives data from OnLineInterface
            values.cDims = int16(1);
            values.cbElements = 2;   % 2-byte values
            values.cLocks = 0;
            pdataNum = libpointer('int32Ptr', 0);   % some pointers needed by OnLineInterface
            pStatus = libpointer('int32Ptr',0);
            
            %***** Double check this guy!!
            ch = this.usech - 1;
            calllib('OnLineInterface64', 'OnLineStatus', ch, OLI.ONLINE_GETRATE, pStatus);
            
            % get the sample rate which is returned as an integer
            sampleRate = double(pStatus.Value); % force all maths using sampleRate to use floating point
            %
            calllib('OnLineInterface64', 'OnLineStatus', ch, OLI.ONLINE_GETSAMPLES, pStatus);
            if (pStatus.Value > 0)     % empty buffer only if something is in it and an error has not occurred (-ve)
                mSinBuffer = floor(pStatus.Value * 1000 / sampleRate);  % round down mS; note that a number of mS must be passed to OnLineGetData.
                numberInBuffer = mSinBuffer * sampleRate / 1000;        % recalculate after a possible rounding
                values.rgsabound.cElements = numberInBuffer;            % initialise array to receive the new data
                values.rgsabound.lLbound = numberInBuffer;
                values.pvData = int16(1:numberInBuffer);
                calllib('OnLineInterface64', 'OnLineGetData', ch, mSinBuffer, values, pdataNum);
            end
            
            
            %% Start Data Collection
            calllib('OnLineInterface64','OnLineStatus', ch, OLI.ONLINE_START, pStatus);
            % First initialise the return values from the DLL functions            %
            %             datalogval = NaN(this.numch, 1);
            datalogval=[];
            zeroSamplesCounter = 0; inputIndex = 1;   graph_endpoint=10*sampleRate;
            runStatus=1; save_data_flag = 0 ; % Need to add to GUI in the future
            while (runStatus)
                runStatus = ~isempty(strfind(lower(get(handles.pushbutton_play, 'string')), 'stop'));
                pause(0.001);
                calllib('OnLineInterface64','OnLineStatus', ch, OLI.ONLINE_GETSAMPLES, pStatus);
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
                    
                    mStoGet = floor(numberToGet * 1000 / sampleRate);   % round down mS; note that a number of mS must be passed to OnLineGetData.
                    numberToGet = mStoGet * sampleRate / 1000;          % recalculate after a possible rounding
                    % initialise array to receive the new data
                    values.rgsabound.cElements = numberToGet;
                    values.rgsabound.lLbound = numberToGet;
                    values.pvData = int16(1:numberToGet);
                    %                     datalogval=(values.pvData);
                    % get numberToGet samples from interface
                    calllib('OnLineInterface64', 'OnLineGetData', ch, mStoGet, values, pdataNum);
                    numberOfSamplesReceived = pdataNum.Value;   % The number of samples actually returned is pDataNum.Value
                    inputIndexEnd = inputIndex + numberOfSamplesReceived - 1;
                    thisVal = double(values.pvData)*3/4000;
                    if save_data_flag
                        datalogval=[datalogval,double(values.pvData)*3/4000];
                    end
                    %                     toc_startTime = toc(handles.startTime);
                    rawEMG = double(values.pvData)*3/4000; 
                    envEMG = this.emg_envelope(rawEMG);
                    
                    if numberOfSamplesReceived~=0
                        addpoints(handles.dataLine,...
                            double([inputIndex:inputIndexEnd])/sampleRate,...
                            envEMG);
                    end
                    inputIndex = inputIndex + numberOfSamplesReceived;
                    if inputIndexEnd>graph_endpoint
                        inputIndex=1;
                        clearpoints(handles.dataLine)
                    end
                    checkboxVal = get(handles.checkbox_useserial,'value');
                    if get(handles.checkbox_useserial,'value')
                        msg = ['e', char(this.toByte(envEMG,handles.emgRange)),...
                            char(10)]; % Send 'e' character for EMG.
                        fwrite(handles.mySerial,msg);
                    end
                end
            end
        end
        
        function start(this)
            calllib('OnLineInterface64', 'OnLineStatus', 0, this.ONLINE_START, 0);
        end
        function stop(this)
            calllib('OnLineInterface64', 'OnLineStatus', 0, this.ONLINE_STOP, 0);
        end
        function yout = emg_envelope(this,emgIn)
            % bandpass butter 30 450
            A = [-0.9422   -0.2250    0.0446   -0.1739;,...
                0.2250   -0.6240    0.1739    0.2905;,...
                -0.0446    0.1739    0.9655    0.1343;,...
                -0.1739   -0.2905   -0.1343    0.7756];
            B = [0.5082;,...
                1.9793;,...
                -0.3926;,...
                -1.5291];
            C = [0.0796    0.1329    0.0615    0.1027];
            D = 0.6998;                                   
            myXnn = this.Xnn;
            for i = 1 : length(emgIn)
                u = emgIn(i);
                Xn1 = A*myXnn+B*u;
                ytemp = C*myXnn+D*u;
                filt_mat(i) = ytemp;
                this.Xnn = Xn1;
            end
            % Absolute value for the envelope
            emgBandpass = abs(filt_mat);
            % Lowpass filter 6 Hz
            A = [0.9474   -0.0367;,...
                0.0367    0.9993];
            B = [0.0519; 0.0010];
            C = [0.0130    0.7069];
            D = 3.4604e-04;
            myXnn = this.XnnLowpass;
            inputSignal = emgBandpass;
            for i = 1 : length(inputSignal)
                u = inputSignal(i);
                Xn1 = A*myXnn+B*u;
                ytemp = C*myXnn+D*u;
                filt_mat(i) = ytemp;
                this.XnnLowpass = Xn1;
            end
            yout = filt_mat;
        end
    end
    methods (Access = private) %Destructor
        function delete(this)
            %Do sth when object is destructed.
        end
    end
    methods (Static)
        % Functions without class input
        function yout = toByte(xIn, range)
            % This function convert an input xIn within a range into
            % two byte valute;
            nbits = 16; %
            a = range(1); b = range(2);
            res = bitshift(1,nbits)-1;
            temp = uint16(res*(xIn - a)/(b-a));
            yout = typecast(swapbytes(temp),'uint8');
        end
        
    end
end

