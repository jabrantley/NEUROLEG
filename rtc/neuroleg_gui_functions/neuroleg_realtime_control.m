%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                NEUROLEG REAL TIME STREAMING FOR CONTROL                 %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function implements the real time of EEG and EMG. Uses RDA from
% Brain Products for streaming EEG - see info below
% data.
%
% University of Houston, Non-Invasive Brain Machine Interfaces Laboratory
% Written by: Justin Brantley - justin.a.brantley@gmail.com
% 09/20/2019: Date created

% ***********************************************************************
% Simple MATLAB RDA Client
%
% Demonstration file for implementing a simple MATLAB client for the
% RDA tcpip interface of the BrainVision Recorder.
% It reads all information of the recorded EEG,
% prints EEG and marker information to the
% MATLAB console and calculates and prints the average power every second.
%
%
% Brain Products GmbH
% Gilching/Freiburg, Germany
% www.brainproducts.com
%
%
% This RDA Client uses version 2.x of the tcp/udp/ip Toolbox by
% Peter Rydesäter which can be downloaded from the Mathworks website
%
% ***********************************************************************

% Main RDA Client function
function out = neuroleg_realtime_control(params,b,teensyLeg,teensySynch,KF_EEG,KF_EMG)
%SYNCHCLEANEEG,SYNCHFILTEEG,SYNCHFILTEMG,SYNCHENVEMG,

repeat = 1;

while repeat
    % Preallocate for data
    RAWEEG           = zeros(params.setup.allEEGchans + params.setup.numEOGchans,...
        params.setup.numEEGpnts * length(params.sinewave.time));
    HINFEEG          = zeros(length(params.setup.chans2keep),...
        params.setup.numEEGpnts * length(params.sinewave.time));
    FILTEREEG        = zeros(length(params.setup.chans2keep),...
        params.setup.numEEGpnts * length(params.sinewave.time));
    WINEEG           = zeros(params.setup.numEEGchans,length(params.sinewave.time));
    LAGEEG           = zeros(params.setup.numEEGchans,KF_EEG.lags);
    LAGEMG           = zeros(size(KF_EMG.observation,1),KF_EMG.lags);
    MRKREEG          = zeros(1,size(RAWEEG,2));
    numAnalog        = length(find(params.setup.BIOchannels<8));
    numDigital       = params.setup.numBIOchans - numAnalog;
    RAWBIO           = zeros(numAnalog, size(RAWEEG,2));
    WINBIO           = zeros(numAnalog,length(params.sinewave.time));
    MRKRBIO          = zeros(numDigital, size(RAWEEG,2));
    ANGLEVEC         = zeros(1,size(RAWEEG,2));
    startEEG         = 1;
    startBIO         = 1;
    trigger_interval = floor(params.sinewave.time(end)/6);
    cycle_time       = zeros(1,length(params.sinewave.time));
    predicted_value  = zeros(1,length(params.sinewave.time));
    
    % Get channel gain 
    gain = params.setup.EEGgain;
    
    % Plot for EMG - activate sine axes
    axes(params.fig.f.Children(1));
    hold on;
    s_predict1 = scatter(0,0,'filled');
    % Plot for EMG - activate linear axes
    axes(params.fig.f.Children(2));
    hold on;
    s_predict2 = scatter(0,0,'filled');
    
    % Open serial if closed and ON = true
    if isempty(teensySynch)
        fprintf(['\n-------------------------------',...
        '\n\n No synchbox. Synchronization cannot occur. \n\n',...
        '-------------------------------\n'])
        out = [];
        return;
    elseif ~isempty(teensySynch) && strcmpi(teensySynch.Status,'closed')
        fopen(teensySynch)
    end
    
    if isempty(teensyLeg)
        fprintf(['\n\n-------------------------------',...
        '\n\n Neuroleg not connected. No leg control. \n\n',...
        '-------------------------------\n'])
    elseif ~isempty(teensyLeg) && strcmpi(teensyLeg.Status,'closed')
        fopen(teensyLeg) 
    end
    
     % Initialize
    fs = stoploop('Stop trial...');
    
    % Change for individual recorder host
    recorderip = '127.0.0.1';
    
    % Establish connection to BrainVision Recorder Software 32Bit RDA-Port
    % (use 51234 to connect with 16Bit Port)
    con = pnet('tcpconnect', recorderip, 51244);
    
    % Check established connection and display a message
    stat = pnet(con,'status');
    if stat > 0
        disp('connection established');
    end
    
    startTime = tic;
    lasttime=toc(startTime);
    % Create counter
    counter = 1;
    % totaltime=toc(startTime);
    
    % --- Main reading loop ---
    header_size = 24;
    finish = false;
    
    while ~finish
        
        % check if stop button pressed
        if fs.Stop()
            b.stop;
            return;
        end
        
        try
            % Update rate
            if ge(toc(startTime) - lasttime,trigger_interval)
                fprintf(teensySynch,'S')
                % Get new time
                lasttime = toc(startTime);
            end
            
            % check for existing data in socket buffer
            tryheader = pnet(con, 'read', header_size, 'byte', 'network', 'view', 'noblock');
            while ~isempty(tryheader)
                
                % Read header of RDA message
                hdr = ReadHeader(con);
                
                % Perform some action depending of the type of the data package
                switch hdr.type
                    case 1       % Start, Setup information like EEG properties
                        disp('Start');
                        % Clear biometrics buffer
                        b.clearbuffer;
                        % Start biometrics
                        b.start;
                        % Read and display EEG properties
                        props = ReadStartMessage(con, hdr);
                        disp(props);
                        
                        % Reset block counter to check overflows
                        lastBlock = -1;
                        
                        % set data buffer to empty
                        data1s = [];
                       
                    case 4       % 32Bit Data block
                        
                        if counter == 1
                            % Get start time
                            start_time = tic;
                        end
                        
                        if counter > length(params.sinewave.wave)
                            finish = true;
                            break;
                        end
                        
                        % Update line figure
                        params.fig.s.XData = params.sinewave.wave(counter);
                        params.fig.s.YData = params.sinewave.wave(counter);
                        
                        % Update wave figure
                        params.fig.s1.XData = params.sinewave.time(counter);
                        params.fig.s1.YData = params.sinewave.wave(counter)/max(params.sinewave.wave);
                        
                        % Read data and markers from message
                        [datahdr, data, markers] = ReadDataMessage(con, hdr, props);
                        
                        % check tcpip buffer overflow
                        if lastBlock ~= -1 && datahdr.block > lastBlock + 1
                            disp(['******* Overflow with ' int2str(datahdr.block - lastBlock) ' blocks ******']);
                        end
                        lastBlock = datahdr.block;
                        
                        % print marker info to MATLAB console
                        % if datahdr.markerCount > 0
                        %    for m = 1:datahdr.markerCount
                        %        disp(markers(m));
                        %    end
                        % end
                        
                        % Get EEG data
                        eegdata = double(reshape(data, props.channelCount, length(data) / props.channelCount));
                        endEEG  = startEEG+size(eegdata,2) - 1;
                        RAWEEG(:,startEEG:endEEG) = eegdata;
                        MRKREEG(1,startEEG+markers.position) = 1;
                        ANGLEVEC(:,startEEG:endEEG) = params.sinewave.wave(counter)/max(params.sinewave.wave) .* ones(1,length(startEEG:endEEG));
                        
                        
                        % Get Biometrics data
                        biodata = [];
                        biodigi = [];
                        temp = double(b.getdata);
                        isEMG = [];
                        if ~isempty(temp)
                            for ii = 1:length(b.usech)
                                chandata = temp(ii,:);
                                if strcmpi(b.chantype(ii),'digital')
                                    biodigi = [biodigi; chandata(:)'.*b.changain(ii)];
                                else
                                    biodata = [biodata; chandata(:)'.*b.changain(ii)];
                                end
                                if strcmpi(b.chantype(ii),'EMG')
                                    isEMG = [isEMG, ii];
                                end
                            end
                            endBIO = startBIO + size(biodata,2) - 1;
                            RAWBIO(:,startBIO:endBIO) = biodata;
                            if any(b.usech >= 8)
                                MRKRBIO(:,startBIO:endBIO) = biodigi;
                            end
                            MRKRBIO(:,startBIO:endBIO) = biodigi;
                            startBIO = endBIO + 1;
                        end
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %                                              %
                        %                PROCESS DATA                  %
                        %                                              %
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Get EOG data
                        if ~isempty(params.setup.EOGchannels)
                            EOG = eegdata(params.setup.EOGchannels,:);
                        else
                            EOG = [];
                        end
                        
                        % Keep desired EEG channels
                        EEG = eegdata(params.setup.chans2keep,:);
                       
                        % Get EMG
                        if ~isempty(temp)
                            EMG = temp(isEMG,:).*b.EMG_GAIN;
                        else
                            EMG = [];
                        end
                        % Filter and clean data
                        [params,cleaneeg,filteeg,filtemg,envemg] = neuroleg_realtime_processing(params,EEG',EOG',EMG');
                        
                        % Save clean and filter EEG
                        HINFEEG(:,startEEG:endEEG) = cleaneeg;
                        FILTEREEG(:,startEEG:endEEG) = filteeg;
                        startEEG = endEEG + 1;
                        
                        % Zscore data based on train data
                        if params.setup.standardizeEEG
                            filteeg = bsxfun(@rdivide,bsxfun(@minus,filteeg,KF_EEG.mu),KF_EEG.sigma);
                        end
                        
                        if params.setup.standardizeEMG
                            envemg = bsxfun(@rdivide,bsxfun(@minus,envemg,KF_EMG.mu),KF_EMG.sigma);
                        end
                        
                        % Compute mean value for EEG
                        meanEEG = mean(filteeg,2);
                        WINEEG(:,counter) = meanEEG;
                        
                        % Compute mean value for EMG
                        if ~isempty(temp)
                            meanEMG = mean(envemg,2);
                        else % temp is empty
                            if counter ==1 % set to zeros
                                meanEMG = zeros(size(WINBIO,1),1);
                            else % hold last value
                                meanEMG = WINBIO(:,counter-1);
                            end
                        end
                        WINBIO(:,counter) = meanEMG;
                        
                        % Get past observation data - LAGExG: channels x time (lags)
                        % Tranpsose so its time x channels, so then
                        % expanded vertically, its [Ch0_t ... Ch0_t-n,
                        % Ch1_t ... Ch1_t-n, Ch2_t ... Ch2_t-n, ...]
                        LAGEMG = transpose([meanEMG LAGEMG(:,1:KF_EMG.lags-1)]);
                        LAGEEG = transpose([meanEEG LAGEEG(:,1:KF_EEG.lags-1)]);
                        
                        % Predict value
                        if toc(start_time) >= params.setup.time2cut
                            predictedFromEEG(:,counter) =  gain.*KF_EEG.predict(LAGEEG(:));
                            predictedFromEMG(:,counter) =  gain.*KF_EMG.predict(LAGEMG(:));
                        else
                            predictedFromEEG(:,counter) =  gain.*KF_EEG.Xt;
                            predictedFromEMG(:,counter) =  gain.*KF_EMG.Xt;
                        end
                        
                        % Transpose back to channels x lags
                        LAGEMG = transpose(LAGEMG);
                        LAGEEG = transpose(LAGEEG);
                        
                        % Assign value and save
                        if strcmpi(params.setup.control,'EEG')
                            final_predicted_value = predictedFromEEG(1,counter);
                        elseif strcmpi(params.setup.control,'EMG')
                            final_predicted_value = predictedFromEMG(1,counter);
                        end
                        
                        % Constrain to joint limits [1 60]/60 - later
                        % multiply by max to get actual angle in degrees
                        if final_predicted_value < params.setup.joint_angles(1)/params.setup.joint_angles(2)
                            final_predicted_value = params.setup.joint_angles(1)/params.setup.joint_angles(2);
                        elseif final_predicted_value > 1
                            final_predicted_value = 1;
                        end
                        
                        % Update sinewave figure
                        s_predict1.XData(counter) = params.sinewave.time(counter);
                        s_predict1.YData(counter) = final_predicted_value;
                        % Update linear figure
                        s_predict2.XData = final_predicted_value.*params.setup.joint_angles(2);
                        s_predict2.YData = final_predicted_value.*params.setup.joint_angles(2);
                        
                        predicted_value(counter) = final_predicted_value.*params.setup.joint_angles(2);
                        
                        % Write to neuroleg
                        if ~isempty(teensyLeg)
                            fprintf(teensyLeg,'%.2f\n',round(final_predicted_value.*params.setup.joint_angles(2)));
                            %fprintf(teensyLeg,'%s','\n');
                        end
                        
                        cycle_time(counter) = toc(start_time);
                        
                        % Update counter
                        counter = counter + 1;
                        
                    
                    case 3       % Stop message
                        disp('Stop');
                        data = pnet(con, 'read', hdr.size - header_size);
                        finish = true;
                        %                     temp = double(b.getdata).*b.EMG_GAIN;
                        % Stop biometrics
                        %temp = double(b.getdata).*b.EMG_GAIN;
                        
                    otherwise    % ignore all unknown types, but read the package from buffer
                        data = pnet(con, 'read', hdr.size - header_size);
                end
                tryheader = pnet(con, 'read', header_size, 'byte', 'network', 'view', 'noblock');
                
            end
        catch er
            disp(er.message);
        end
    end % Main loop
    
    % Close all open socket connections
    pnet('closeall');
    
    % Close biometrics
    b.stop;
    
    
    % Plot data for display purposes
    bc = blindcolors;
    r2_val = KalmanFilter.rsquared(params.sinewave.wave,predicted_value);
    if strcmpi(params.setup.control,'EMG')
        figure('color','w','units','inches','position',[-16.5 1.5 15.5 7.5]); ax = axes;
        fill(params.sinewave.time,WINBIO,0.7.*ones(1,3),'edgecolor','none'); hold on;
        plot(params.sinewave.time,params.sinewave.wave./params.setup.joint_angles(2),'color',bc(6,:),'linewidth',2);
        plot(params.sinewave.time,predicted_value./params.setup.joint_angles(2),'color',bc(8,:),'linewidth',2);
        ax.XTick = []; ax.YTick = [];
        ax.XColor = 'w'; ax.YColor = 'w';
        legend({'EMG Envelope','Desired Angle','Predicted Angle'})
        title(['R^{2} = ' num2str(round(r2_val,2))]);
    elseif strcmpi(params.setup.control,'EEG')
        figure('color','w','units','inches','position',[-16.5 1.5 15.5 7.5]); ax = axes;
        plot(params.sinewave.time,transpose(WINEEG)./max(WINEEG(:)),'color',0.7.*ones(1,3),'linewidth',2); hold on;
        plot(params.sinewave.time,params.sinewave.wave./params.setup.joint_angles(2),'color',bc(6,:),'linewidth',2);
        plot(params.sinewave.time,predicted_value./params.setup.joint_angles(2),'color',bc(8,:),'linewidth',2);
        ax.XTick = []; ax.YTick = [];
        ax.XColor = 'w'; ax.YColor = 'w';
        legend({'EEG Potential','Desired Angle','Predicted Angle'})
        title(['R^{2} = ' num2str(round(r2_val,2))]);
    end
    % Trim data - rescale markers between [0 1]
    RAWEEG   = RAWEEG(:,1:endEEG);
    MRKREEG  = rescale_data(MRKREEG(:,1:endEEG),'rows',[0 1]);
    RAWBIO   = RAWBIO(:,1:endBIO);
    MRKRBIO  = rescale_data(MRKRBIO(:,1:endBIO),'rows',[0 1]);
    ANGLEVEC = ANGLEVEC(:,1:endEEG);
    
    % Get spikes from biometrics pulses
    diffMRKRBIO = [0 diff(MRKRBIO)]>0;
    
    % Get length of shorter vector
    minPoints =  min([endBIO,endEEG]);
    
    % Compute cross correlation
    [xcvalue,xclag] = xcorr(diffMRKRBIO(:,1:minPoints),MRKREEG(:,1:minPoints));
    [~,maxIDX]      = max(xcvalue);
    IDXshift        = xclag(maxIDX);
    
    % Check if IDX shift is too high resulting in alignment error
    if abs(IDXshift) > 500
        synch_warning = warndlg('Alignment error. Re-training is required. Press OK to start.','Warning');
        uiwait(synch_warning)
        b.clearbuffer;
        % Close figure;
        close all
        params = neuroleg_realtime_setup;
        % Close all serial
        fclose(instrfind);
    else
        % Delete old data
        delete(s_predict1);
        delete(s_predict2);
        repeat = 0;
        
    end
end % end while repeat

% Shift data
SYNCHBIO = RAWBIO(:,1:end-(abs(IDXshift)-1));
% SYNCHFILTEMG = filtemg(:,1:end-(abs(IDXshift)-1));
% SYNCHENVEMG = envemg(:,1:end-(abs(IDXshift)-1));
SYNCHEEG = RAWEEG(:,abs(IDXshift):minPoints);
SYNCHCLEANEEG = HINFEEG(:,abs(IDXshift):minPoints);
SYNCHFILTEEG = FILTEREEG(:,abs(IDXshift):minPoints);
SYNCHANGLE = ANGLEVEC(:,abs(IDXshift):minPoints);

out = struct('EEGRAW',SYNCHEEG,'EEGCLEAN',SYNCHCLEANEEG,'EEGFILT',SYNCHFILTEEG,...
             'BIO',SYNCHBIO,'ANGLE',SYNCHANGLE,'WINBIO',WINBIO,'WINEEG',WINEEG,...
             'predictedValue',predicted_value,'predictedFromEEG',predictedFromEEG,...
             'predictedFromEMG',predictedFromEMG);
         out = out;
         
% Display a message

disp('Done streaming EEG and Biometrics.');


%% ***********************************************************************
% Read the message header
function hdr = ReadHeader(con)
% con    tcpip connection object

% define a struct for the header
hdr = struct('uid',[],'size',[],'type',[]);

% read id, size and type of the message
% swapbytes is important for correct byte order of MATLAB variables
% pnet behaves somehow strange with byte order option
hdr.uid = pnet(con,'read', 16);
hdr.size = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
hdr.type = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));


%% ***********************************************************************
% Read the start message
function props = ReadStartMessage(con, hdr)
% con    tcpip connection object
% hdr    message header
% props  returned eeg properties

% define a struct for the EEG properties
props = struct('channelCount',[],'samplingInterval',[],'resolutions',[],'channelNames',[]);

% read EEG properties
props.channelCount = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
props.samplingInterval = swapbytes(pnet(con,'read', 1, 'double', 'network'));
props.resolutions = swapbytes(pnet(con,'read', props.channelCount, 'double', 'network'));
allChannelNames = pnet(con,'read', hdr.size - 36 - props.channelCount * 8);
props.channelNames = SplitChannelNames(allChannelNames);


%% ***********************************************************************
% Read a data message
function [datahdr, data, markers] = ReadDataMessage(con, hdr, props)
% con       tcpip connection object
% hdr       message header
% props     eeg properties
% datahdr   data header with information on datalength and number of markers
% data      data as one dimensional arry
% markers   markers as array of marker structs

% Define data header struct and read data header
datahdr = struct('block',[],'points',[],'markerCount',[]);

datahdr.block = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
datahdr.points = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
datahdr.markerCount = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));

% Read data in float format
data = swapbytes(pnet(con,'read', props.channelCount * datahdr.points, 'single', 'network'));

% Define markers struct and read markers
markers = struct('size',[],'position',[],'points',[],'channel',[],'type',[],'description',[]);
for m = 1:datahdr.markerCount
    marker = struct('size',[],'position',[],'points',[],'channel',[],'type',[],'description',[]);
    
    % Read integer information of markers
    marker.size = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
    marker.position = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
    marker.points = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
    marker.channel = swapbytes(pnet(con,'read', 1, 'int32', 'network'));
    
    % type and description of markers are zero-terminated char arrays
    % of unknown length
    c = pnet(con,'read', 1);
    while c ~= 0
        marker.type = [marker.type c];
        c = pnet(con,'read', 1);
    end
    
    c = pnet(con,'read', 1);
    while c ~= 0
        marker.description = [marker.description c];
        c = pnet(con,'read', 1);
    end
    
    % Add marker to array
    markers(m) = marker;
end


%% ***********************************************************************
% Helper function for channel name splitting, used by function
% ReadStartMessage for extraction of channel names
function channelNames = SplitChannelNames(allChannelNames)
% allChannelNames   all channel names together in an array of char
% channelNames      channel names splitted in a cell array of strings

% cell array to return
channelNames = {};

% helper for actual name in loop
name = [];

% loop over all chars in array
for i = 1:length(allChannelNames)
    if allChannelNames(i) ~= 0
        % if not a terminating zero, add char to actual name
        name = [name allChannelNames(i)];
    else
        % add name to cell array and clear helper for reading next name
        channelNames = [channelNames {name}];
        name = [];
    end
end

