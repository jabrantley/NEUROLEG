function varargout = NEUROLEG_GUIDE(varargin)
% NEUROLEG_GUI MATLAB code for NEUROLEG_GUI.fig
%      NEUROLEG_GUI, by itself, creates a new NEUROLEG_GUI or raises the existing
%      singleton*.
%
%      H = NEUROLEG_GUI returns the handle to a new NEUROLEG_GUI or the handle to
%      the existing singleton*.
%
%      NEUROLEG_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEUROLEG_GUI.M with the given input arguments.
%
%      NEUROLEG_GUI('Property','Value',...) creates a new NEUROLEG_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NEUROLEG_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NEUROLEG_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Edit the above text to modify the response to help NEUROLEG_GUI

% Last Modified by GUIDE v2.5 07-Oct-2019 07:53:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @NEUROLEG_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @NEUROLEG_GUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%                    OPENING FUNCTION - SET DEFAULTS                   %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes just before NEUROLEG_GUI is made visible.
function NEUROLEG_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for NEUROLEG_GUI
handles.output = hObject;
% Get default params
params = neuroleg_realtime_setup;
% Set params in handles
handles = neuroleg_realtime_params2handles(params,handles);
% Initialize teensys
handles.teensyLeg = [];
handles.teensySynch = [];
% Turn off EEG and BIOMETRICS by default
handles.checkbox_enable_eeg.Value = 1;
checkbox_enable_eeg_Callback(handles.checkbox_enable_eeg,eventdata,handles)
handles.checkbox_enable_biometrics.Value = 1;
checkbox_enable_biometrics_Callback(handles.checkbox_enable_biometrics,eventdata,handles)
% Set predict to phantom by default
handles.radio_predict_phantom.Value = 0;
handles.radio_predict_intact.Value = 0;
handles.radio_predict_both.Value = 1;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes NEUROLEG_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = NEUROLEG_GUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function close_figs
figHandles = findall(groot, 'Type', 'figure');
thisFig = find(strcmpi('NEUROLEG_GUI',{figHandles.Name}));
closefigs = setdiff(1:length(figHandles),thisFig);
close(figHandles(closefigs));
% Close all serial
fclose(instrfind);

% --- Executes on button press in str2double(get(hObject,'String'))_train.
function button_train_Callback(hObject, eventdata, handles)
% Parse params struct into handles
handles = neuroleg_realtime_parsehandles(handles);
% Loop through each training iteration
for aa = 1:handles.params.setup.trainiterations
    StartButton = questdlg(['Iteration ' num2str(aa) ': Ready to start?'],'Stream Data','Start','Stop','Stop');
    switch StartButton
        case 'Start'
            
            % Make sure biometrics is initialized
            if ~isfield(handles,'biometrics') || isempty(handles.biometrics)
                button_biometrics_init_Callback(handles.button_biometrics_init,eventdata,handles);
            end
            
            if isempty(handles.biometrics)
                disp('Biometrics not initialized. Check connection.');
                return;
            end
            
            % Start Data Collection
            handles.biometrics.clearbuffer;
            % Open serial if closed and ON = true
            if handles.synchbox_checkbox.Value && strcmpi(handles.teensySynch.Status,'closed')
                fopen(handles.teensySynch)
            end
            if handles.neuroleg_checkbox.Value && strcmpi(handles.teensyLeg.Status,'closed')
                fopen(handles.teensyLeg)
            end
            % Run training - leg 1
            if handles.radio_predict_intact.Value || handles.radio_predict_both.Value
                handles.params.fig = build_movement_fig(handles.params.sinewave);
                [EEG_ALL{1,aa},BIO_ALL{1,aa},ANGLES_ALL{1,aa}] = neuroleg_realtime_stream(handles.params,handles.biometrics,handles.teensyLeg,handles.teensySynch,0);
            end
            
            try
                close(handles.params.fig.f);
            catch
                %do nothing
            end
            
            % Pause between iterations to continue
            if handles.radio_predict_both.Value
                StartButton2 = questdlg(['Next leg. Ready to start?'],'Stream Data','Start','Stop','Stop');
                switch StartButton2
                    case 'Start'
                        % continue to next trial
                    otherwise
                        % Just in case not previously stopped
                        handles.biometrics.stop;
                        figHandles = findall(groot, 'Type', 'figure');
                        thisFig = find(strcmpi('NEUROLEG_GUI',{figHandles.Name}));
                        closefigs = setdiff(1:length(figHandles),thisFig);
                        close(figHandles(closefigs));
                        % Close all serial
                        fclose(instrfind);
                        return;
                end
            end
            
            % Run training - leg 2
            if handles.radio_predict_phantom.Value || handles.radio_predict_both.Value
                handles.params.fig = build_movement_fig(handles.params.sinewave);
                [EEG_ALL{2,aa},BIO_ALL{2,aa},ANGLES_ALL{2,aa}] = neuroleg_realtime_stream(handles.params,handles.biometrics,handles.teensyLeg,handles.teensySynch,1);
            end
            try
                close(handles.params.fig.f);
            catch
                %do nothing
            end
            % Close all serial
            fclose(instrfind);
            
        otherwise
            % Just in case not previously stopped
            handles.biometrics.stop;
            figHandles = findall(groot, 'Type', 'figure');
            thisFig = find(strcmpi('NEUROLEG_GUI',{figHandles.Name}));
            closefigs = setdiff(1:length(figHandles),thisFig);
            close(figHandles(closefigs));
            % Close all serial
            fclose(instrfind);
            return;
    end
end

% Get time
date1 = datestr(now,'yymmdd');
date2 = datestr(now,'HHMMSS');

% Save raw data
subname = handles.edit_subject_name.String;
flname0 = [strjoin({subname,'train','rawdata',date1,date2},'_') '.mat'];
flnameP = [strjoin({subname,'train','params',date1,date2},'_') '.mat'];
params = rmfield(handles.params,'fig');
save(flnameP,'params');
save(flname0,'EEG_ALL','BIO_ALL','ANGLES_ALL');

% Initialize empty variables
prehinfeeg = cell(2,1);
cleaneeg   = cell(2,1);
filteeg    = cell(2,1);
filtemg    = cell(2,1);
envemg     = cell(2,1);

starttime = tic;
poo = gcp('nocreate');
if isempty(poo)
    try
        parpool(2);
    catch
        numCores = feature('numcores');
        parpool(numCores);
    end
end

legs = [handles.radio_predict_intact.Value,handles.radio_predict_phantom.Value];
val2 = handles.radio_predict_both.Value;
params = handles.params;
parfor nn = 1:2
    % Train model - intact
    val1 = legs(nn);
    if val1 || val2
        EEG_TEMP    = EEG_ALL(nn,:);
        EEG_DATA    = cat(2,EEG_TEMP{:});
        BIO_TEMP    = BIO_ALL(nn,:);
        BIO_DATA    = cat(2,BIO_TEMP{:});
        EMG_DATA    = BIO_DATA(nn,:); % Get data for intact channel
        ANGLES_TEMP = ANGLES_ALL(nn,:);
        ANGLES_DATA = cat(2,ANGLES_TEMP{:});
        [~,modelsEMG{nn},modelsEEG{nn},cleaneeg{nn},filteeg{nn},prehinfeeg{nn},filtemg{nn},envemg{nn},EEGgain{nn}] = neuroleg_realtime_train(params,EEG_DATA,EMG_DATA,ANGLES_DATA);
    else
        modelsEMG{nn} = [];
        modelsEEG{nn} = [];
        EEGgain{nn} = [];
    end
end
% params.kalman.lambda = 1;
% params.kalman.lags = 10;

% IF PARFOR WORKS SAVE MODELS TO INTACT
intact.KF_EMG = modelsEMG{1};
intact.KF_EEG = modelsEEG{1};
phantom.KF_EMG = modelsEMG{2};
phantom.KF_EEG = modelsEEG{2};

toc(starttime)

% Find gain and bias
params.setup.autogain.intact  = EEGgain{1};
params.setup.autogain.phantom = EEGgain{2};

% Store in handles
handles.intact = intact;
handles.phantom = phantom;

% % Train model - intact
% if handles.radio_predict_intact.Value || handles.radio_predict_both.Value
%     EEG_TEMP    = EEG_ALL(1,:);
%     EEG_DATA    = cat(2,EEG_TEMP{:});
%     BIO_TEMP    = BIO_ALL(1,:);
%     BIO_DATA    = cat(2,BIO_TEMP{:});
%     EMG_DATA    = BIO_DATA(1,:); % Get data for intact channel
%     ANGLES_TEMP = ANGLES_ALL(1,:);
%     ANGLES_DATA = cat(2,ANGLES_TEMP{:});
%     [handles.params,intact.KF_EMG,intact.KF_EEG,cleaneeg{1},filteeg{1},filtemg{1},envemg{1},EEGgainIntact] = neuroleg_realtime_train(handles.params,EEG_DATA,EMG_DATA,ANGLES_DATA);
% else
%     intact = [];
%     EEGgainIntact = [];
% end
% 
% % Train model - phantom
% if handles.radio_predict_phantom.Value || handles.radio_predict_both.Value
%     EEG_TEMP    = EEG_ALL(2,:);
%     EEG_DATA    = cat(2,EEG_TEMP{:});
%     BIO_TEMP    = BIO_ALL(2,:);
%     BIO_DATA    = cat(2,BIO_TEMP{:});
%     EMG_DATA    = BIO_DATA(2,:); % Get data for phantom channel
%     ANGLES_TEMP = ANGLES_ALL(2,:);
%     ANGLES_DATA = cat(2,ANGLES_TEMP{:});
%     [handles.params,phantom.KF_EMG,phantom.KF_EEG,cleaneeg{2},filteeg{2},prehinfeeg{2},filtemg{2},envemg{2},EEGgainPhantom] = neuroleg_realtime_train(handles.params,EEG_DATA,EMG_DATA,ANGLES_DATA);
% else
%     phantom = [];
%     EEGgainPhantom = [];
% end
% 
% % If auto gain checked then find gain and bias
% if handles.eeg_gain_auto.Value
%     handles.params.setup.autogain.intact  = EEGgainIntact;
%     handles.params.setup.autogain.phantom = EEGgainPhantom;
% end

% Save Kalman Filter model
params = rmfield(handles.params,'fig');
flname1 = [strjoin({subname,'train','model',date1,date2},'_') '.mat'];
save(flname1,'params','intact','phantom');
% Save training data after cleaning
flname2 = [strjoin({subname,'train','processdata',date1,date2},'_') '.mat'];
save(flname2,'cleaneeg','filteeg','prehinfeeg','filtemg','envemg');

% Just in case not previously stopped
handles.biometrics.stop;
figHandles = findall(groot, 'Type', 'figure');
thisFig = find(strcmpi('NEUROLEG_GUI',{figHandles.Name}));
closefigs = setdiff(1:length(figHandles),thisFig);
close(figHandles(closefigs));
% Close all serial
fclose(instrfind);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in button_test.
function button_test_Callback(hObject, eventdata, handles)
% Parse params struct into handles
handles = neuroleg_realtime_parsehandles(handles);
% Start button
StartButton = questdlg('Ready to start?','Stream Data','Start','Stop','Stop');
if isfield(handles,'phantom') && isfield(handles,'intact')
    switch StartButton
        case 'Start'
            % Start Data Collection
            if ~isfield(handles,'biometrics')
                button_biometrics_init_Callback(handles.button_biometrics_init,eventdata,handles);
            end
            % Check biometrics
            if isempty(handles.biometrics)
                disp('Biometrics not initialized. Check connection.');
                return;
            end
            % clear buffer
            handles.biometrics.clearbuffer;
            % Run testing
            if (handles.radio_predict_intact.Value || handles.radio_predict_both.Value) && ~isempty(handles.intact)
                % If auto gain checked then find gain and bias
                if handles.eeg_gain_auto.Value
                    gain = handles.params.setup.autogain.intact;
                else
                    gain = str2num(handles.edit_eeg_predict_gain.String); %handles.params.setup.EEGgain;
                end
                % Make figure
                handles.params.fig = build_movement_fig(handles.params.sinewave);
                % Real time control
                test_intact = neuroleg_realtime_control(handles.params,handles.biometrics,handles.teensyLeg,handles.teensySynch,handles.intact.KF_EEG,handles.intact.KF_EMG,gain,0);
            else
                test_intact = [];
            end
            % Pause between iterations to continue
            if handles.radio_predict_both.Value
                StartButton2 = questdlg(['Next leg. Ready to start?'],'Stream Data','Start','Stop','Stop');
                switch StartButton2
                    case 'Start'
                        % continue to next trial
                    otherwise
                        % Just in case not previously stopped
                        handles.biometrics.stop;
                        figHandles = findall(groot, 'Type', 'figure');
                        thisFig = find(strcmpi('NEUROLEG_GUI',{figHandles.Name}));
                        closefigs = setdiff(1:length(figHandles),thisFig);
                        close(figHandles(closefigs));
                        % Close all serial
                        fclose(instrfind);
                        return;
                end
            end
            % Phantom leg
            if (handles.radio_predict_phantom.Value || handles.radio_predict_both.Value) && ~isempty(handles.phantom)
                % If auto gain checked then find gain and bias
                if handles.eeg_gain_auto.Value
                    gain = handles.params.setup.autogain.phantom;
                else
                    gain = str2num(handles.edit_eeg_predict_gain.String);%handles.params.setup.EEGgain;
                end
                % Make figure
                handles.params.fig = build_movement_fig(handles.params.sinewave);
                % Real time control
                test_phantom = neuroleg_realtime_control(handles.params,handles.biometrics,handles.teensyLeg,handles.teensySynch,handles.phantom.KF_EEG,handles.phantom.KF_EMG,gain,1);
            else
                test_phantom = [];
            end
            % close serial
            fclose(instrfind);
        otherwise
            % Just in case not previously stopped
            if isfield(handles,'biometrics')
                handles.biometrics.stop;
            end
            close_figs;
            % Update handles structure
            guidata(hObject, handles);
            return;
    end
    % Save data
    subname = handles.edit_subject_name.String;
    flname = [strjoin({subname,'test','data',[handles.params.setup.control 'control'],datestr(now,'yymmdd'),datestr(now,'HHMMSS')},'_') '.mat'];
    save(flname,'test_intact','test_phantom');
    
else
    disp('No model avaialble. Please train or load model.');
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in button_freemove.
function button_freemove_Callback(hObject, eventdata, handles)
% Parse params struct into handles
handles = neuroleg_realtime_parsehandles(handles);
% Start button
StartButton = questdlg('Ready to start?','Stream Data','Start','Stop','Stop');
if isfield(handles,'phantom') && isfield(handles,'intact')
    switch StartButton
        case 'Start'
            % Start Data Collection
            if ~isfield(handles,'biometrics')
                button_biometrics_init_Callback(handles.button_biometrics_init,eventdata,handles);
            end
            % Check biometrics
            if isempty(handles.biometrics)
                disp('Biometrics not initialized. Check connection.');
                return;
            end
            % clear buffer
            handles.biometrics.clearbuffer;
            
            % Phantom leg
            if (handles.radio_predict_phantom.Value || handles.radio_predict_both.Value) && ~isempty(handles.phantom)
                % If auto gain checked then find gain and bias
                if handles.eeg_gain_auto.Value
                    gain = handles.params.setup.autogain.phantom;
                else
                    gain = handles.params.setup.EEGgain;
                end
                % Make figure
                handles.params.fig = build_movement_fig(handles.params.sinewave);
                % Real time control
                test_phantom = neuroleg_realtime_freemove(handles.params,handles.biometrics,handles.teensyLeg,handles.teensySynch,handles.phantom.KF_EEG,handles.phantom.KF_EMG);
            else
                test_phantom = [];
            end
            
            % close serial
            fclose(instrfind);
        otherwise
            % Just in case not previously stopped
            if isfield(handles,'biometrics')
                handles.biometrics.stop;
            end
            figHandles = findall(groot, 'Type', 'figure');
            thisFig = find(strcmpi('NEUROLEG_GUI',{figHandles.Name}));
            closefigs = setdiff(1:length(figHandles),thisFig);
            close(figHandles(closefigs));
            % Close all serial
            fclose(instrfind);
            % Update handles structure
            guidata(hObject, handles);
            return;
    end
    % Save data
    subname = handles.edit_subject_name.String;
    flname = [strjoin({subname,'freemove','data',[handles.params.setup.control 'control'],datestr(now,'yymmdd'),datestr(now,'HHMMSS')},'_') '.mat'];
    save(flname,'test_phantom');
    
else
    disp('No model avaialble. Please train or load model.');
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in button_loadtrain.
function button_loadtrain_Callback(hObject, eventdata, handles)
% Parse params struct into handles
handles = neuroleg_realtime_parsehandles(handles);
%handles = rmfield(handles,{'phantom','intact','params'});
model = uigetfile('*model*.mat');
if model == 0
    return
else
    in = load(model);
    handles.intact  = in.intact;
    handles.phantom = in.phantom;
    handles.params  = in.params;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in button_trainmerge.
function button_trainmerge_Callback(hObject, eventdata, handles)
% Get files to merge
[datafiles,datapath] = uigetfile('*train_rawdata*.mat','Select data to merge.','MultiSelect','on');
[paramfile,parampath] = uigetfile('*train_params*.mat','Select parameter file.');
if ~iscell(datafiles)
    if datafiles == 0
        return;
    elseif isstr(datafiles)
        datafiles = {fullfile(datapath,datafiles)};
    end
end
EEGALL = []; BIOALL = []; ANGALL = [];
numtrials = 5; % this needs to be changed if files have fewer than five cycles. Should be dynamic
randtrial_ord = zeros(length(datafiles),numtrials);
% Load data and concatenate
for ii = 1:length(datafiles)
    load(fullfile(datapath,datafiles{ii}),'EEG_ALL','BIO_ALL','ANGLES_ALL');
    % Get five of the trials randomly
    randtrial = randperm(size(EEG_ALL,2),numtrials);
    % Get data
    EEGALL = cat(2,EEGALL,EEG_ALL(:,randtrial));
    BIOALL = cat(2,BIOALL,BIO_ALL(:,randtrial));
    ANGALL = cat(2,ANGALL,ANGLES_ALL(:,randtrial));
    % Store values for later
    randtrial_ord(ii,:) = randtrial;
end

% Randomly permute order to mix data from days
randord = randperm(size(EEGALL,2));

% Get data in shuffled order (for kfold)
clear EEG_ALL BIO_ALL ANGLES_ALL
EEG_ALL    = EEGALL(:,randord);
BIO_ALL    = BIOALL(:,randord);
ANGLES_ALL = ANGALL(:,randord);
clear EEGALL BIOALL ANGALL

if paramfile == 0
    disp('No parameter file selected. Goodbye');
    return;
else
    load(fullfile(parampath,paramfile),'params');
end
 
% Parse params struct into handles
%handles = neuroleg_realtime_parsehandles(handles);

% Initialize empty variables
cleaneeg = cell(2,1);
filteeg  = cell(2,1);
filtemg  = cell(2,1);
envemg   = cell(2,1);
prehinfeeg = cell(2,1);
EEGgain  = cell(2,1);
modelsEMG= cell(2,1);
modelsEEG= cell(2,1);

% % Train model - intact
% if handles.radio_predict_intact.Value || handles.radio_predict_both.Value
%     EEG_TEMP    = EEG_ALL(1,:);
%     EEG_DATA    = cat(2,EEG_TEMP{:});
%     BIO_TEMP    = BIO_ALL(1,:);
%     BIO_DATA    = cat(2,BIO_TEMP{:});
%     EMG_DATA    = BIO_DATA(1,:); % Get data for intact channel
%     ANGLES_TEMP = ANGLES_ALL(1,:);
%     ANGLES_DATA = cat(2,ANGLES_TEMP{:});
%     [params,intact.KF_EMG,intact.KF_EEG,cleaneeg{1},filteeg{1},filtemg{1},envemg{1},EEGgainIntact] = neuroleg_realtime_train(params,EEG_DATA,EMG_DATA,ANGLES_DATA);
% else
%     intact = [];
%     EEGgainIntact = [];
% end
% 
% % params.kalman.lambda = 1;
% % params.kalman.lags = 10;
% 
% % Train model - phantom
% if handles.radio_predict_phantom.Value || handles.radio_predict_both.Value
%     EEG_TEMP    = EEG_ALL(2,:);
%     EEG_DATA    = cat(2,EEG_TEMP{:});
%     BIO_TEMP    = BIO_ALL(2,:);
%     BIO_DATA    = cat(2,BIO_TEMP{:});
%     EMG_DATA    = BIO_DATA(2,:); % Get data for phantom channel
%     ANGLES_TEMP = ANGLES_ALL(2,:);
%     ANGLES_DATA = cat(2,ANGLES_TEMP{:});
%     [params,phantom.KF_EMG,phantom.KF_EEG,cleaneeg{2},filteeg{2},prehinfeeg{2},filtemg{2},envemg{2},EEGgainPhantom] = neuroleg_realtime_train(params,EEG_DATA,EMG_DATA,ANGLES_DATA);
% else
%     phantom = [];
%     EEGgainPhantom = [];
% end

starttime = tic;
poo = gcp('nocreate');
if isempty(poo)
    try
        parpool(2);
    catch
        numCores = feature('numcores');
        parpool(numCores);
    end
end

legs = [handles.radio_predict_intact.Value,handles.radio_predict_phantom.Value];
val2 = handles.radio_predict_both.Value;

for nn = 1:2
    % Train model - intact
    val1 = legs(nn);
    if val1 || val2
        EEG_TEMP    = EEG_ALL(nn,:);
        EEG_DATA    = cat(2,EEG_TEMP{:});
        BIO_TEMP    = BIO_ALL(nn,:);
        BIO_DATA    = cat(2,BIO_TEMP{:});
        EMG_DATA    = BIO_DATA(nn,:); % Get data for intact channel
        ANGLES_TEMP = ANGLES_ALL(nn,:);
        ANGLES_DATA = cat(2,ANGLES_TEMP{:});
        [~,modelsEMG{nn},modelsEEG{nn},cleaneeg{nn},filteeg{nn},prehinfeeg{nn},filtemg{nn},envemg{nn},EEGgain{nn}] = neuroleg_realtime_train(params,EEG_DATA,EMG_DATA,ANGLES_DATA);
    else
        modelsEMG{nn} = [];
        modelsEEG{nn} = [];
        EEGgain{nn} = [];
    end
end
% params.kalman.lambda = 1;
% params.kalman.lags = 10;

% IF PARFOR WORKS SAVE MODELS TO INTACT
intact.modelsEMG = modelsEMG{1};
intact.modelsEEG = modelsEEG{1};
phantom.modelsEMG = modelsEMG{2};
phantom.modelsEEG = modelsEEG{2};

toc(starttime)

% If auto gain checked then find gain and bias
params.setup.autogain.intact  = EEGgain{1};
params.setup.autogain.phantom = EEGgain{2};

% Store in handles
%handles.intact = intact;
%handles.phantom = phantom;

% Get time
date1 = datestr(now,'yymmdd');
date2 = datestr(now,'HHMMSS');

% Save raw data
subname = params.setup.subname;
flname0 = [strjoin({subname,'merge','rawdata',date1,date2},'_') '.mat'];
flnameP = [strjoin({subname,'merge','params',date1,date2},'_') '.mat'];
save(fullfile(parampath,flnameP),'params','paramfile');
save(fullfile(datapath,flname0),'EEG_ALL','BIO_ALL','ANGLES_ALL','datafiles','randord','randtrial_ord');

% Save Kalman Filter model
params = rmfield(handles.params,'fig');
flname1 = [strjoin({subname,'merge','model',date1,date2},'_') '.mat'];
save(fullfile(datapath,flname1),'params','intact','phantom','datafiles');
% Save training data after cleaning
flname2 = [strjoin({subname,'merge','processdata',date1,date2},'_') '.mat'];
save(fullfile(datapath,flname2),'cleaneeg','filteeg','prehinfeeg','filtemg','envemg');

% Update handles structure
%guidata(hObject, handles);

% --- Executes on button press in button_stop.
function button_stop_Callback(hObject, eventdata, handles)
fprintf('\n\n...In the name of love!!\n\n')
% Just in case not previously stopped
if isfield(handles,'biometrics')
    handles.biometrics.stop;
end
% Close all figures
figHandles = findall(groot, 'Type', 'figure');
thisFig = find(strcmpi('NEUROLEG_GUI',{figHandles.Name}));
closefigs = setdiff(1:length(figHandles),thisFig);
close(figHandles(closefigs));
% Close all serial
fclose(instrfind);

% --- Executes on button press in checkbox_enable_eeg.
function checkbox_enable_eeg_Callback(hObject, eventdata, handles)
if hObject.Value == 0
    handles.eeg_nbchans.Enable           = 'off';
    handles.edit_eeg_srate.Enable        = 'off';
    handles.edit_eeg_filtfreq.Enable     = 'off';
    handles.edit_hinf_gamma.Enable       = 'off';
    handles.edit_hinf_q.Enable           = 'off';
    handles.edit_eeg_predict_gain.Enable = 'off';
    handles.zscore_eegdata.Enable        = 'off';
    handles.radio_eeg_control.Enable     = 'off';
    handles.eeg_gain_auto.Enable         = 'off';
else
    handles.eeg_nbchans.Enable           = 'on';
    handles.edit_eeg_srate.Enable        = 'on';
    handles.edit_eeg_filtfreq.Enable     = 'on';
    handles.edit_hinf_gamma.Enable       = 'on';
    handles.edit_hinf_q.Enable           = 'on';
    handles.edit_eeg_predict_gain.Enable = 'on';
    handles.zscore_eegdata.Enable        = 'on';
    handles.radio_eeg_control.Enable     = 'on';
    handles.eeg_gain_auto.Enable         = 'on';
end

% --- Executes on button press in checkbox_enable_biometrics.
function checkbox_enable_biometrics_Callback(hObject, eventdata, handles)
if hObject.Value == 0
    handles.checkbox_channel1.Enable      = 'off';
    handles.checkbox_channel2.Enable      = 'off';
    handles.checkbox_channel3.Enable      = 'off';
    handles.checkbox_channel4.Enable      = 'off';
    handles.checkbox_channel5.Enable      = 'off';
    handles.checkbox_channel6.Enable      = 'off';
    handles.checkbox_channel7.Enable      = 'off';
    handles.checkbox_channel8.Enable      = 'off';
    handles.checkbox_digitals.Enable      = 'off';
    handles.chanselect1.Enable            = 'off';
    handles.chanselect2.Enable            = 'off';
    handles.chanselect3.Enable            = 'off';
    handles.chanselect4.Enable            = 'off';
    handles.chanselect5.Enable            = 'off';
    handles.chanselect6.Enable            = 'off';
    handles.chanselect7.Enable            = 'off';
    handles.chanselect8.Enable            = 'off';
    handles.button_biometrics_init.Enable = 'off';
    handles.edit_biometrics_srate.Enable  = 'off';
    handles.edit_emg_filtfreq.Enable      = 'off';
    handles.zscore_emgdata.Enable         = 'off';
    handles.radio_emg_control.Enable      = 'off';
else
    handles.checkbox_channel1.Enable      = 'on';
    handles.checkbox_channel2.Enable      = 'on';
    handles.checkbox_channel3.Enable      = 'on';
    handles.checkbox_channel4.Enable      = 'on';
    handles.checkbox_channel5.Enable      = 'on';
    handles.checkbox_channel6.Enable      = 'on';
    handles.checkbox_channel7.Enable      = 'on';
    handles.checkbox_channel8.Enable      = 'on';
    handles.checkbox_digitals.Enable      = 'on';
    handles.chanselect1.Enable            = 'on';
    handles.chanselect2.Enable            = 'on';
    handles.chanselect3.Enable            = 'on';
    handles.chanselect4.Enable            = 'on';
    handles.chanselect5.Enable            = 'on';
    handles.chanselect6.Enable            = 'on';
    handles.chanselect7.Enable            = 'on';
    handles.chanselect8.Enable            = 'on';
    handles.button_biometrics_init.Enable = 'on';
    handles.edit_biometrics_srate.Enable  = 'on';
    handles.edit_emg_filtfreq.Enable      = 'on';
    handles.zscore_emgdata.Enable         = 'on';
    handles.radio_emg_control.Enable      = 'on';
end
% Update handles structure
guidata(hObject, handles);

function eeg_nbchans_Callback(hObject, eventdata, handles)
hObject.Value = str2double(hObject.String);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eeg_nbchans_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_biometrics_srate_Callback(hObject, eventdata, handles)
hObject.Value = str2double(hObject.String);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_biometrics_srate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_subject_name_Callback(hObject, eventdata, handles)
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_subject_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in zscore_eegdata.
function zscore_eegdata_Callback(hObject, eventdata, handles)


function edit_eeg_filtfreq_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_eeg_filtfreq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in neuroleg_checkbox.
function neuroleg_checkbox_Callback(hObject, eventdata, handles)
% If checked, turn on teensy
fclose(instrfind);
try
    teensyLeg = serial('COM32','BaudRate',115200);
    fopen(teensyLeg);
    % Add to handles
    handles.teensyLeg = teensyLeg;
    fprintf(['\n-------------------------------',...
        '\n\n   Neuroleg connected. \n\n',...
        '-------------------------------\n'])
catch err
    disp(err.message);
    fprintf(['\n-------------------------------',...
        '\n\n   Is the teensy plugged in? \n\n',...
        '-------------------------------\n'])
    handles.teensyLeg = [];
    hObject.Value = 0;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in synchbox_checkbox.
function synchbox_checkbox_Callback(hObject, eventdata, handles)
% If checked, turn on teensy
if ~isempty(instrfind)
    fclose(instrfind);
end

if hObject.Value
    try
        teensySynch = serial('COM3','BaudRate',115200);
        fopen(teensySynch);
        % Add to handles
        handles.teensySynch = teensySynch;
        fprintf(['\n-------------------------------',...
            '\n\n   Synchbox connected. \n\n',...
            '-------------------------------\n'])
    catch err
        disp(err.message);
        fprintf(['\n-------------------------------',...
            '\n\n   Is the teensy plugged in? \n\n',...
            '-------------------------------\n'])
        handles.teensySynch = [];
        hObject.Value = 0;
    end
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in button_biometrics_init.
function button_biometrics_init_Callback(hObject, eventdata, handles)
use_channels = [];
chantype     = [];
% Check for each channel type 0-7
cnt = 1;
for ii = 1:8
    eval(['val = handles.checkbox_channel' num2str(ii) '.Value;'])
    if val
        use_channels = [use_channels, ii - 1];
        eval(['idx = handles.chanselect' num2str(ii) '.Value;'])
        eval(['chantype{cnt} = handles.chanselect' num2str(ii) '.String{idx};'])
        cnt = cnt + 1;
    end
end
% Check digital channels
val = handles.checkbox_digitals.Value;
if val
    use_channels = [use_channels, ii];
    chantype{cnt}    = 'DIGITAL';
end
% Setup biometrics
if ~isempty(use_channels)
    try
        b = biometrics_datalog('usech',use_channels,'chantype',chantype)
        % Add to handles
        handles.biometrics = b;
        fprintf(['\n-------------------------------',...
            '\n\n   Biometrics Initialized. \n\n',...
            '-------------------------------\n'])
    catch err
        disp(err.message)
    end
else
    handles.biometrics = [];
    disp('No channels selected.');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in checkbox_channel1.
function checkbox_channel1_Callback(hObject, eventdata, handles)

% --- Executes on selection change in chanselect1.
function chanselect1_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function chanselect1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox_channel2.
function checkbox_channel2_Callback(hObject, eventdata, handles)

% --- Executes on selection change in chanselect2.
function chanselect2_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function chanselect2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox_channel3.
function checkbox_channel3_Callback(hObject, eventdata, handles)

% --- Executes on selection change in chanselect3.
function chanselect3_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function chanselect3_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox_channel4.
function checkbox_channel4_Callback(hObject, eventdata, handles)

% --- Executes on selection change in chanselect4.
function chanselect4_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function chanselect4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox_channel5.
function checkbox_channel5_Callback(hObject, eventdata, handles)

% --- Executes on selection change in chanselect5.
function chanselect5_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function chanselect5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox_channel6.
function checkbox_channel6_Callback(hObject, eventdata, handles)

% --- Executes on selection change in chanselect6.
function chanselect6_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function chanselect6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox_channel7.
function checkbox_channel7_Callback(hObject, eventdata, handles)

% --- Executes on selection change in chanselect7.
function chanselect7_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function chanselect7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox_channel8.
function checkbox_channel8_Callback(hObject, eventdata, handles)

% --- Executes on selection change in chanselect8.
function chanselect8_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function chanselect8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox_digitals.
function checkbox_digitals_Callback(hObject, eventdata, handles)

function edit_eeg_srate_Callback(hObject, eventdata, handles)
% Get EEG srate
hObject.Value = str2double(hObject.String);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_eeg_srate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Get dir name
function dir_name_Callback(hObject, eventdata, handles)
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function dir_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.dir_name.string = pwd;
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in button_savedir.
function button_savedir_Callback(hObject, eventdata, handles)
savedir = uigetdir(pwd);
handles.dir_name.String = savedir;
handles.button_savedir.UserData =  savedir;
% Update handles structure
guidata(hObject, handles);

function edit_emg_filtfreq_Callback(hObject, eventdata, handles)
% EMG filter freq
hObject.Value = str2num(hObject.String);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_emg_filtfreq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_hinf_gamma_Callback(hObject, eventdata, handles)
% Hinfinity gamma
hObject.Value = str2double(hObject.String);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_hinf_gamma_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_hinf_q_Callback(hObject, eventdata, handles)
% Hinfinity q
hObject.Value = str2double(hObject.String);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_hinf_q_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Edit box for Kalman filter order
function edit_kalman_ord_Callback(hObject, eventdata, handles)
% Kalman order
hObject.Value = str2num(hObject.String);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_kalman_ord_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_eeg_predict_gain_Callback(hObject, eventdata, handles)
% Prediction gain
hObject.Value;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_eeg_predict_gain_CreateFcn(hObject, eventdata, handles)
% Set default
hObject.Value = 1;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in eeg_gain_auto.
function eeg_gain_auto_Callback(hObject, eventdata, handles)
% Turn off manual gain entry if auto is chosen
if hObject.Value
    handles.edit_eeg_predict_gain.Enable = 'off';
else
    handles.edit_eeg_predict_gain.Enable = 'on';
end
% Update handles structure
guidata(hObject, handles);

function edit_move_freq_Callback(hObject, eventdata, handles)
% Update value
hObject.Value = str2double(hObject.String);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_move_freq_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_cycles_per_trial_Callback(hObject, eventdata, handles)
% Update value
hObject.Value = str2double(hObject.String);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_cycles_per_trial_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_num_trainiter_Callback(hObject, eventdata, handles)
% Update value
hObject.Value = str2double(hObject.String);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_num_trainiter_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Edit box for Kalman filter lambda values
function edit_kalman_lambda_Callback(hObject, eventdata, handles)
% Update value
hObject.Value = str2num(hObject.String);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_kalman_lambda_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in zscore_emgdata.
function zscore_emgdata_Callback(hObject, eventdata, handles)
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in radio_eeg_control.
function radio_eeg_control_Callback(hObject, eventdata, handles)
if handles.checkbox_enable_biometrics.Value
    handles.radio_emg_control.Value = ~hObject.Value;
end
guidata(hObject, handles);

% --- Executes on button press in radio_emg_control.
function radio_emg_control_Callback(hObject, eventdata, handles)
if handles.checkbox_enable_eeg.Value
    handles.radio_eeg_control.Value = ~hObject.Value;
end
guidata(hObject, handles);

% --- Executes on button press in radio_predict_phantom.
function radio_predict_phantom_Callback(hObject, eventdata, handles)
handles.radio_predict_intact.Value = ~hObject.Value;
handles.radio_predict_both.Value = ~hObject.Value;
guidata(hObject, handles);

% --- Executes on button press in radio_predict_intact.
function radio_predict_intact_Callback(hObject, eventdata, handles)
handles.radio_predict_phantom.Value = ~hObject.Value;
handles.radio_predict_both.Value = ~hObject.Value;
guidata(hObject, handles);

% --- Executes on button press in radio_predict_both.
function radio_predict_both_Callback(hObject, eventdata, handles)
handles.radio_predict_intact.Value = ~hObject.Value;
handles.radio_predict_phantom.Value = ~hObject.Value;
guidata(hObject, handles);

% --- Executes on button press in radio_phantom_left.
function radio_phantom_left_Callback(hObject, eventdata, handles)
handles.radio_phantom_right.Value = ~hObject.Value;
guidata(hObject, handles);

% --- Executes on button press in radio_phantom_right.
function radio_phantom_right_Callback(hObject, eventdata, handles)
handles.radio_phantom_left.Value = ~hObject.Value;
guidata(hObject, handles);
