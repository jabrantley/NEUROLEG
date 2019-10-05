function varargout = NEUROLEG_GUI(varargin)

% Add Paths and external libs
uhlib = '\uhlibPcode';
addpath('\Includes');
addpath(genpath(uhlib));

% Import Java
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.util.*;
import java.lang.*;

global gvar
gvar.username = getenv('username');
% Graphics
gvar.margin.l=0.01;gvar.margin.r=0.01;
gvar.margin.t=0.01;gvar.margin.b=0.05;
gvar.margin.gap=0.01;
gvar.page.bgcolor='w';
gvar.myfont='Arial';
gvar.fontsizexl = 14;
gvar.fontsizel = 12;
gvar.fontsize = 10;
gvar.fontsizes = 8;
gvar.axfont = 8;
gvar.marker={'o','^','square','diamond','v','>','<','+','*','.','x'};
gvar.mycolor = class_color;
gvar.mysymbol = uh_symbol;
% Utilities
gvar.timenow = class_datetime;

%====STEP 1: FRAME========================================================
handles.iconlist=getmatlabicons;
% Create a new figure
[handles.figure, handles.jstatusbarhdl,handles.jwaitbarhdl]=uh_uiframe('figname',mfilename,...
    'units','norm','position',[0.2 0.075 0.55 0.85],...
    'toolbar','figure',...
    'statusbar',1,...
    'waitbarpos','East','waitbarstr',0,...
    'icon',handles.iconlist.uh,'logo','none',...
    'logopos',[0.89,0.79,0.2,0.2]);

%==============================UI CONTROL=================================
% Set Look and Feel
uisetlookandfeel('window');

% Warning off
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
warning('off','MATLAB:uigridcontainer:MigratingFunction');
warning('off','MATLAB:uitree:MigratingFunction');
warning('off','MATLAB:uitreenode:DeprecatedFunction');

% Menu bar;
handles=uimenubar(handles);


% Subject setup
uistring = {'Name:',...
        '',...
        ''};
    [container_subinfo(1),...
        handles.subinfo_name,...
        ] = uigridcomp({'label','edit',...
        'label'},...
        'uistring',uistring,...
        'gridsize',[1 3],'gridmargin',1,'hweight',[3 5 2]);
uistring = {'# of channels:',...
        '',''};
    [container_subinfo(2),...
        handles.subinfo_dir,handles.subinfo_dirbutton(1)...
        ] = uigridcomp({'label','edit','pushbutton'},...
        'uistring',uistring,...
        'gridsize',[1 3],'gridmargin',1,'hweight',[3 5 2]);
uipanel_subinfo=uipanellist('title','SUBJECT INFORMATION',...
    'objects',[container_subinfo],...
    'itemheight',0.9/length(container_subinfo)*ones(1,length(container_subinfo)),...
    'itemwidth',[0.99],...
    'gap',[0 gvar.margin.gap]);
w = .45; h = .1;
set(uipanel_subinfo,'position',[gvar.margin.l 1-2*gvar.margin.l-h w h])

% EEG setup
uistring = {'Sampling Rate:','',' Hz',...
    '# of Channels:', '',''};
[container_eeginfo,...
    ~,handles.edit_eegchans,...
    ~,handles.edit_eegsrate,...
    ] = uigridcomp({'label','edit','label'...
    'label','edit','label'},...
    'uistring',uistring,...
    'gridsize',[2 3],'gridmargin',1,'hweight',[5 4],'vweight',[1 1 1]);
uipanel_subinfo = uipanellist('title','EEG SETTINGS',...
    'objects',[container_eeginfo],...
    'itemheight',0.95,...
    'itemwidth',[0.95],...
    'gap',[0 gvar.margin.gap]);



uistring = {'Sampling Rate:',...
        '',...
        ' Hz'};
    [container_eeginfo(1),...
        handles.edit_calib(1),...
        ] = uigridcomp({'label','edit',...
        'label'},...
        'uistring',uistring,...
        'gridsize',[1 3],'gridmargin',1,'hweight',[4 3 3]);
uistring = {'# of channels:',...
        '',''};
    [container_eeginfo(2),...
        handles.edit_calib(2),handles.eegpushbutton(1)...
        ] = uigridcomp({'label','edit','pushbutton'},...
        'uistring',uistring,...
        'gridsize',[1 3],'gridmargin',1,'hweight',[4 3 3]);
uipanel_eeg=uipanellist('title','EEG SETTINGS',...
    'objects',[container_eeginfo],...
    'itemheight',0.9/length(container_eeginfo)*ones(1,length(container_eeginfo)),...
    'itemwidth',[0.99],...
    'gap',[0 gvar.margin.gap]);
% w=0.25-gvar.margin.gap; eeg_h=0.1;
% set(uipanel_eeg,'position',[gvar.margin.l 1-2*gvar.margin.l-.2 w eeg_h])

% DATALOG SETUP
uistring = {'Sampling Rate:',...
        '',...
        ' Hz'};
    [container_dataloginfo(1),...
        handles.edit_calib(3),...
        ] = uigridcomp({'label','edit',...
        'label'},...
        'uistring',uistring,...
        'gridsize',[1 3],'gridmargin',1,'hweight',[4 3 3]);
nb_chans = 8;
handles.nb_chans = nb_chans;

% EMG channels
for ii = 1 : nb_chans
    uistring = {sprintf('Ch %d',ii),...
        {'EMG','Gonio'},...
        '',...
        'Gain'};
    [container_dataloginfo(ii+1),...
        handles.checkbox_chinfo(ii+1),...
        handles.popupmenu_chinfo(ii+1),...
        ] = uigridcomp({'checkbox',...
        'popupmenu'},...
        'uistring',uistring,...
        'gridsize',[1 2],'gridmargin',1,'hweight',[2 3]);
    set(handles.popupmenu_chinfo(ii+1),'tag', sprintf('popup%d',ii+1));
end
% Enable digitals
uistring = {'Enable digitals'};
[container_dataloginfo(ii+2),...
    handles.checkbox_chinfo(ii+2),...
    ] = uigridcomp({'checkbox'},...
    'uistring',uistring,...
    'gridsize',[1 2],'gridmargin',1,'hweight',[2 3]);
%     set(handles.popupmenu_chinfo(ii),'tag', sprintf('popup%d',ii));
    
% uistring = {'','',icontext(handles.iconlist.action.assign,'Init'),'',...
%     };
% [container_dataloginfo(1),...
%     ~,~,handles.pushbutton_datalog_init,~,...
%     ] = uigridcomp({'label',...
%     'label',...
%     'pushbutton',...
%     'label'},...
%     'uistring',uistring,...
%     'gridsize',[1 4],'gridmargin',1,'hweight',[2 3 3 1]);
uipanel_datalog=uipanellist('title','DATALOG SETTINGS',...
    'objects',[container_dataloginfo],...
    'itemheight',0.9/length(container_dataloginfo)*ones(1,length(container_dataloginfo)),...
    'itemwidth',[0.99],...
    'gap',[0 gvar.margin.gap]);
w=0.25-gvar.margin.gap; h=0.45;
set(uipanel_datalog,'position',[gvar.margin.l 1-2*gvar.margin.l-h-2.*eeg_h-gvar.margin.l w h])
disp('done.')





%=============
% Current Directory and File list box
function pushbutton_updir_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
currdir=get(handles.combobox_currdir,'selecteditem');
% ==== START
if strfind(currdir,'.\')
    slash=strfind(currdir,'\');
    updir=currdir(1:slash(end));
    if strcmpi(currdir,'.\')
        [updir,~,~]=fileparts(cd);
    end
else
    [updir,~,~]=fileparts(currdir);
end
handles.combobox_currdir.insertItemAt(updir,0);
set(handles.combobox_currdir,'selectedindex',0);
% ==== END
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

function pushbutton_newdir_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
currdir=get(handles.combobox_currdir,'selecteditem');
% ==== START
todaydirList = globFiles('dir',currdir,'filetype','dir',...
    'key',datestr(now(),'yyyy_mm_dd'));
if ~isempty(todaydirList)
    latestDir = todaydirList{end}    ;
    [~,dirname] = uh_fileparts('fullpath',latestDir,'level',2)    ;
    trialNum = str2num(dirname(end-1:end));
    newDirname = dirname;
    newDirname(end-1:end) = sprintf('%.2d',trialNum+1);
    defaultAnswer{1} = newDirname;
else
    defaultAnswer = {strcat(datestr(now(),'yyyy_mm_dd'),'-S01-T01')};
end
% Input dialog for use to enter folder name.
% Default Answer based on available folder in current directory
prompt = 'Folder Name';
name = 'New Fodler';
numline = [1 50];
newDir = inputdlg(prompt,...
    name,numline, defaultAnswer);
dirList = globFiles('dir',currdir,'filetype','dir');
% If the answer from user is available. e.g., Do not Cancel
if ~isempty(newDir)
    if any(~cellfun(@isempty, strfind(dirList,newDir{1})))
        msg = sprintf('Folder name: %s already exist', newDir{1});
        msgbox(msg,'Existing Folder');
    else
        mkdir(fullfile(currdir,newDir{1}));
    end
end
uijlist_setfiles(handles.jlistbox_filenameinput,...
    get(handles.combobox_currdir,'selectedItem'));
% ==== END
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

function combobox_currdir_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
newdir=get(hObject,'selecteditem');
% ==== START
if strcmpi(newdir,'.\');
    newdir=cd;
end
if ~strcmpi(newdir,hObject.getItemAt(0))
    hObject.insertItemAt(newdir,0);
end
uijlist_setfiles(handles.jlistbox_filenameinput,newdir,'type',{'.all'});
% ==== END
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

% MOUSE and KEYBOARD
function jlistbox_filenameinput_Mouse_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
eventinf=get(eventdata);
% ==== START
if eventinf.Button==1 && eventinf.ClickCount==2 %double left click
    % Convert list item with html char (icon) to filename
    filename = html2item(get(hObject,'SelectedValue'));
    [~,selname,ext]=fileparts(filename);
    currdir = get(handles.combobox_currdir,'selecteditem');
    if isempty(ext)     %folder selection
        if strcmpi(currdir(end),'\')
            newdir=strcat(currdir,selname);
        else
            newdir=strcat(currdir,'\',selname);
        end
        uijlist_setfiles(hObject,newdir,'type',{'.all'});
        updatejcombo(handles.combobox_currdir,newdir)
    elseif strcmpi(ext,'.txt')
        %         winopen(fullfile(currdir,filename));
        myFile = class_FileIO('fullfilename',fullfile(currdir,filename));
        fid = fopen(myFile.fullfilename,'r');
        timestamp = fscanf(fid,'%f');
        fclose(fid);
        figure;
        plot(1./diff(timestamp))
    elseif strcmpi(ext,'.m')
        edit(fullfile(currdir,filename));
    elseif strcmpi(ext,'.mat')
        myfile = class_FileIO('filename',filename,'filedir',currdir);
        myfile.loadtows;
        assignin('base','FileObj',myfile);
    else
    end
end
% ==== END
setappdata(handles.figure,'handles',handles);

function handles=KeyboardThread_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% ==== GUI input
handles=getappdata(handles.figure,'handles');
% ==== START
if isprop(eventdata,'Key')
    key = lower(eventdata.Key); % Matlab component; Ctrl: 'control'
else
    key = lower(char(eventdata.getKeyText(eventdata.getKeyCode)));    % Java component;
end
if any([strcmpi(key,'g'),strcmpi(key,'ctrl'),strcmpi(key,'control'),...
        strcmpi(key,'shift'),strcmpi(key,'alt')])
    handles.keyholder = key;
    setappdata(handles.figure,'handles',handles);
    return;
end
% fprintf('KeyPressed: %s\n',key);
% Go to component;
if strcmpi(key,'delete')
    filename = html2item(get(hObject,'SelectedValue'));
    [~,selname,ext]=fileparts(filename);
    currdir = get(handles.combobox_currdir,'selecteditem');
    if isempty(ext) % Remove folder
        if ~strcmpi(pwd, currdir)
            cd(currdir);
        end
        strcmd=sprintf('rmdir %s s',selname);
    else
        strcmd=sprintf('delete(''%s'')',filename);
    end
    eval(strcmd);
    uijlist_setfiles(handles.jlistbox_filenameinput,currdir,'type',{'.all'});
    fprintf('File deleted\n');
end
if strcmpi(handles.keyholder,'g')
    if strcmpi(key,'f') % Set focus on function list
        handles.jlistbox_filenameinput.requestFocus;
        fprintf('jlistbox_filenameinput is selected.\n');
    end
elseif strcmpi(handles.keyholder,'shift')
elseif strcmpi(handles.keyholder,'ctrl') || strcmpi(handles.keyholder,'control') && strcmpi(key,'s')
    %     pushbutton_save_Callback(handles.pushbutton_save,[],handles);
else
    if strcmpi(key,'f1')
        winopen('.\hotkey.txt');
    end
end
handles.keyholder = ''; % reset keyholder;
% ==== END
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

function handles=uimenubar(handles)
import javax.swing.*
import java.awt.*
import java.awt.event.*
icons=handles.iconlist;
jMenuBar=JMenuBar;
% Build a menu bar
% + File
%       +New
%           + File Type 1...
%       + Open...
% + Help
jMenuBar=JMenuBar;
[menu_file, menu_fileItems] = uimenu_create(jMenuBar,handles,...
    'mainmenu','File',...
    'listmenu',{'Open...'},...
    'icons',{icons.action.open});
callbackFcn = {'jMenu_fileOpen_Callback'};
setMenuCallback(menu_fileItems, callbackFcn, handles)
[~, menu_fileNewItems] = uimenu_create(menu_file,handles,'mainmenu','New...',...
    'listmenu',{'Module','Function'},...
    'icons',{icons.file.m, icons.function});
callbackFcn = {'jMenuItemModule_Callback','jMenuItemFunc_Callback'};
setMenuCallback(menu_fileNewItems, callbackFcn, handles);

% Help Menu
[menu_help, menu_helpItems] = uimenu_create(jMenuBar,handles,...
    'mainmenu','Help',...
    'listmenu',{'Docs'},...
    'icons',{icons.web});
callbackFcn = {'jMenu_helpDocs_Callback'};
setMenuCallback(menu_helpItems, callbackFcn, handles)

javacomponent(jMenuBar,'North',handles.figure);

function jMenu_fileOpen_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% Start
uigetfile('.\*.m','Select File');
% ==== END
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

function jMenu_helpDocs_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% ==== END
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

function varargout = setMenuCallback(menuItems, callbackFcn, handles)
for i = 1 : length(menuItems)
    hjMenuItem = handle(menuItems{i},'CallbackProperties');
    thisCallback = callbackFcn{i};
    cmdstr = sprintf('set(hjMenuItem,''ActionPerformedCallback'',{@%s,handles});',thisCallback);
    eval(cmdstr);
end

% Serial Related
function pushbutton_serialScan_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
% ==== START
if ~isempty(instrfind)
    delete(instrfind)
end
comList = seriallist;
if ~isempty(comList)
    uisetjcombolist(handles.combobox_serialList, comList);
end
set(handles.combobox_serialList,'selectedindex',0);
% ==== END
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

function pushbutton_serialOpen_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
% ==== START
if ~isempty(instrfind)
    delete(instrfind)
end
selCom = get(handles.combobox_serialList,'selectedItem');
selBaud = get(handles.combobox_serialBaudrate,'selectedItem');
mySerial = serial(selCom, 'Baudrate', str2double(selBaud));
% mySerial.InputBufferSize = 10;
flushinput(mySerial);
currStr = get(hObject,'string');
if ~isempty(strfind(lower(get(hObject,'string')),'open'))
    try fopen(mySerial)
        set(handles.edit_serialStatus,'string','Port Open');
        set(handles.edit_serialStatus,'backgroundcolor','g');
        currStr = strrep(currStr,'OPEN','CLOSE');
        set(hObject,'string',currStr);
    catch
        set(handles.edit_serialStatus,'string','Failed to Open','backgroundcolor','r');
    end
else
    fclose(mySerial);
    currStr = strrep(currStr,'CLOSE','OPEN');
    set(hObject,'string',currStr);
    set(handles.edit_serialStatus,'string','Port Closed','backgroundcolor',[1 1 0]);
end
handles.mySerial = mySerial;
% ==== END
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

function pushbutton_serialRead_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
% ==== START
mySerial = handles.mySerial;
dataList = get(handles.list_serialData,'string');
if isempty(dataList)
    dataList{1} = '';
end
if  strcmpi(get(mySerial,'status'),'open')
    if get(mySerial, 'BytesAvailable') > 0
        set(handles.list_serialData,'string','');
        inData = fscanf(mySerial);
        inData(ismember(char(inData),[10,13])) = [];
        temp = dataList;
        dataList{1} = inData;
        for i = 1 : length(temp)
            dataList{i+1} = temp{i};
        end
        if length(dataList) == 10
            dataList(end) = [];
        end
        set(handles.list_serialData,'string',dataList);
    end
end
% ==== END
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

function pushbutton_serialWrite_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s',thisFuncName);
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
% ==== START
mySerial = handles.mySerial;
fprintf(mySerial, get(handles.edit_serialWrite,'string'));
% ==== END
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

% Slider and Edit Setting Related
function slider_edit_param1_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
% ==== START
edit_hdl = handles.edit_param1;
slider_hdl = handles.slider_param1;
if strcmpi(get(hObject,'style'),'slider')
    sliderVal = get(hObject,'value');
    set(edit_hdl,'string',num2str(sliderVal));
elseif strcmpi(get(hObject,'style'),'edit')
    editVal = str2num(get(hObject,'string'));
    slider_min = get(slider_hdl,'min');
    slider_max = get(slider_hdl,'max');
    if editVal > slider_max
        errmsg{1} = sprintf('Maximum value is: %.2f',slider_max);
        editVal = slider_max;
        msgbox(errmsg,'Invalid Value','error');
    elseif editVal < slider_min
        errmsg{1} = sprintf('Minimum value is: %.2f',slider_min);
        editVal = slider_min;
        msgbox(errmsg,'Invalid Value','error');
    end
    set(hObject,'string',num2str(editVal));
    set(slider_hdl,'value',editVal);
else
end
% set(handles.edit_vibDuration,'string',num2str(delayVal));
% ==== END
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

% TIMER related
function timerFcn_Callback(hObject,eventdata,handles)
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
% ==== START
avai_samples = handles.datalog.getavaisamples();
comm_stat = handles.datalog.get_comm_status();
buffer_stat = handles.datalog.get_buffer_status();
set(handles.edit_datalog_avaisamples,'string', num2str(avai_samples),...
    'backgroundcolor', 'w');
if avai_samples < 0
    set(handles.edit_datalog_avaisamples, 'backgroundcolor','r');
end
if comm_stat < 0    
    set(handles.edit_datalog_hardwarecomm, 'string', 'COMM_ERROR',...
        'backgroundcolor','r');    
else
    set(handles.edit_datalog_hardwarecomm, 'string', num2str(comm_stat),...
        'backgroundcolor','w');    
end
if buffer_stat < 0    
    set(handles.edit_datalog_bufferoverflow, 'string', 'OVERFLOW',...
        'backgroundcolor','r');    
else
    set(handles.edit_datalog_bufferoverflow, 'string', num2str(buffer_stat),...
        'backgroundcolor','w');    
end
if comm_stat < 0 || buffer_stat < 0
    stop(hObject);
else
%     datalogval = handles.datalog.getdata();
%     toc_startTime = toc(handles.startTime);
%     if ~isempty(datalogval)
%         addpoints(handles.dataLine,toc_startTime, datalogval(1));
%         set(gca,'XLim',datenum([toc_startTime - handles.npts_dataLine/handles.loopRate,...
%             toc_startTime]));
%         drawnow limitrate;        
% %         % Send EMG value
% %         emg = datalogval(1)
% %         msg = ['e', char(toByte(datalogval(1),handles.emgRange)),...
% %             char(10)]; % Send 'e' character for EMG.
% %         fwrite(handles.mySerial,msg);
% %         fwrite(fid, [inChar; 13; 10], 'uint8');
%     end
end

% thisStamp = tic;
% Check if serial port is available and opened.
% if ~isempty(handles.mySerial) && strcmpi(get(handles.mySerial,'status'),'open')
% else
%     stop(hObject);
% end
% % Read data from Serial port
% nbyte_read = 3;
% inChar = uint8(0);
% serialVal = [];
% if get(handles.mySerial, 'BytesAvailable') > 0
%     inChar = fread(handles.mySerial,nbyte_read,'uint8');
%     % Remove \r\n
%     inChar(ismember(char(inChar),[10,13])) = [];
%     % Decode Serial message
%     if length(inChar) == nbyte_read
%         uint16Data = inChar(1)*256+inChar(2);
%         % Map byte to value
%         res = bitshift(1,16) - 1;
%         dataRange = [-90, 90];
%         serialVal = double(uint16Data*diff(dataRange)/res + dataRange(1));
%     end
% end
% % flushinput(handles.mySerial);
% % Update plot
% if ~isempty(serialVal)
%     ax = gca;
%     t = toc(handles.startTime);
%     addpoints(handles.dataLine,t,serialVal);
%     ax.XLim = datenum([t-10 t]);
%     drawnow;
% end
% Update Status bar
% jwait = get(handles.jwaitbarhdl,'value');
% if jwait == 100, jwait = 0; end;
% set(handles.jwaitbarhdl,'value',jwait + 1);
% elapsedTime =  toc(thisStamp);
% while (elapsedTime < handles.loopTime)
%     elapsedTime = toc(thisStamp);
% end
% saveOpt = get(handles.checkbox_saveOption,'value');
% if saveOpt == 1
% fprintf(handles.fid,'%.3f \n',toc(handles.startTime));
% handles.logData = [handles.logData; toc(handles.startTime)];
% end
% ==== END
setappdata(handles.figure,'handles',handles);

function timerStopFcn_Callback(hObject,eventdata,handles)
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
% ==== START
fprintf('Stop Timer.\n');
% ==== END
setappdata(handles.figure,'handles',handles);

function timerErrorFcn_Callback(hObject,eventdata,handles)
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
% ==== START
% ==== END
setappdata(handles.figure,'handles',handles);

% PLAY and SAVE
function pushbutton_datalogInit_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
% ==== START
% ==BIOMETRICS
biometricslibname = 'OnLineInterface64.dll';
if ~libisloaded(biometricslibname)
    [notfound, warning] = loadlibrary(biometricslibname);
    fprintf('Lib: %s is loaded.\n', biometricslibname);
else
    fprintf('Lib: %s is already loaded.\n', biometricslibname);
end
% Get number of channels
used_chans = [];
type_chans = {};
ch_gains = [];
k = 1;
for i = 1 : handles.nb_chans
    isuse = get(handles.checkbox_chinfo(i), 'value');    
    if isuse == 1
        used_chans(k) = i;
        ch_gains(k) = str2double(get(handles.edit_calib(i),'string'));
        temp = get(handles.popupmenu_chinfo(i),'value');
        if temp == 1;
            type_chans{k} = 'gonio';
        else
            type_chans{k} = 'emg';
        end
        k = k + 1;
    end
end
datalog = class_Biometrics_64bits_ASR_V2('numberofvalues',1,...
    'usech', used_chans, ...
    'sensor', type_chans,...
    'gain', ch_gains);
set(handles.edit_datalog_samplingrate, 'string', num2str(datalog.getsamplerate));
datalog.clearBuffer;
handles.datalog = datalog;
% ==== END
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);


function pushbutton_play_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
% ==== START
% Reset plot
axes(handles.axes_serial);
cla(gca,'reset');
set(gca,'ylim', handles.emgRange);

xlabel(gca,'Time (s)');
ylabel(gca,'Datalog');
% Animated line
npts_dataLine = 3*handles.loopRate;
set(gca,'xlim', [0,10]);
% dataLine = animatedline('MaximumNumPoints',npts_dataLine,...
%     'color','k');
dataLine = animatedline('color','k'); %**** Changed here *****
handles.npts_dataLine = npts_dataLine;
handles.dataLine = dataLine;
% bin_filename = strrep('emglogfile.bin');
if strfind(lower(get(hObject, 'string')), 'play')
    set(hObject, 'string', icontext(handles.iconlist.status.stop,'STOP'));    
    handles.startTime = tic;
    
    
    Datalog_it.values = libstruct('tagSAFEARRAY'); % this is the array that receives data from OnLineInterface
    Datalog_it.values.cDims = int16(1);
    Datalog_it.values.cbElements = 2;   % 2-byte values
    Datalog_it.values.cLocks = 0;
    Datalog_it.pdataNum = libpointer('int32Ptr', 0);   % some pointers needed by OnLineInterface
    Datalog_it.pStatus = libpointer('int32Ptr',0);
    Datalog_it.EMG_data=[];
 
    %***** Double check this guy!!
    Datalog_it.ch = 0; 
    calllib('OnLineInterface64', 'OnLineStatus', Datalog_it.ch, OLI.ONLINE_GETRATE, Datalog_it.pStatus);

    % get the sample rate which is returned as an integer
    Datalog_it.sampleRate = double(Datalog_it.pStatus.Value); % force all maths using sampleRate to use floating point
%                      
    calllib('OnLineInterface64', 'OnLineStatus', Datalog_it.ch, OLI.ONLINE_GETSAMPLES, Datalog_it.pStatus);
    if (Datalog_it.pStatus.Value > 0)     % empty buffer only if something is in it and an error has not occurred (-ve)
        mSinBuffer = floor(Datalog_it.pStatus.Value * 1000 / Datalog_it.sampleRate);  % round down mS; note that a number of mS must be passed to OnLineGetData.
        numberInBuffer = mSinBuffer * Datalog_it.sampleRate / 1000;        % recalculate after a possible rounding
        Datalog_it.values.rgsabound.cElements = numberInBuffer;            % initialise array to receive the new data
        Datalog_it.values.rgsabound.lLbound = numberInBuffer;
        Datalog_it.values.pvData = int16(1:numberInBuffer);
        calllib('OnLineInterface64', 'OnLineGetData', Datalog_it.ch, mSinBuffer, Datalog_it.values, Datalog_it.pdataNum);
    end

    calllib('OnLineInterface64','OnLineStatus', Datalog_it.ch, OLI.ONLINE_START, Datalog_it.pStatus); 
    Datalog_it.inputIndex=1; Datalog_it.datalogval=[];graph_endpoint=10* Datalog_it.sampleRate;
    while(1)
        [handles,Datalog_it] = handles.datalog.getdata(handles,Datalog_it);


        if Datalog_it.numberOfSamplesReceived~=0
                    addpoints(handles.dataLine,...
                                                double([Datalog_it.inputIndex:Datalog_it.inputIndexEnd])/Datalog_it.sampleRate,...
                                                double(Datalog_it.values.pvData)*3/4000); 
        end
        Datalog_it.inputIndex = Datalog_it.inputIndex + Datalog_it.numberOfSamplesReceived; 
        if Datalog_it.inputIndexEnd>graph_endpoint
                Datalog_it.inputIndex=1;
                clearpoints(handles.dataLine)
        end
    end
            

%     handles.datalog.start;    
%     handles.fid = fopen(fullfile(currdir, bin_filename),'w');
    setappdata(handles.figure,'handles',handles);    
%     start(handles.mytimer);
else
    set(hObject, 'string', icontext(handles.iconlist.action.play,'PLAY'));
    stop(handles.mytimer);
    assignin('base','EMG_data',Datalog_it.EMG_data)
%     fclose(handles.fid);
    handles.datalog.stop;
end
% while(1)


% end
% ==== END
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

% DATALOG SETTING
function popupmenu_chinfo_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
% ==== START
tagstr = get(hObject, 'tag');
chType = get(hObject, 'value');
for i = 1 : 8
    if strcmpi(tagstr, sprintf('popup%d',i));
        if chType == 1
            gain = num2str(180/4000);
        else
            gain = num2str(3/4000);
        end
        set(handles.edit_calib(i), 'string', gain)
    end
end

function yout = toByte(xIn, range)
% This function convert an input xIn within a range into
% two byte valute;
nbits = 16; % 
a = range(1); b = range(2);
res = bitshift(1,nbits)-1;
temp = uint16(res*(xIn - a)/(b-a));
yout = typecast(swapbytes(temp),'uint8');


