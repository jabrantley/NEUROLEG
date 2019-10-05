function varargout = templatecode_gui(varargin) 
% Add Paths and external libs
uhlib = '..\uhlib';
addpath(genpath(uhlib));
% Import Java
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.util.*;
import java.lang.*;
global gvar
gvar=def_gvar;
mfilepath = mfilename('fullpath');
[filedir, filename, ~] = fileparts(mfilepath);
%====STEP 1: FRAME========================================================
handles.iconlist=getmatlabicons;
% Create a new figure
[handles.figure, handles.jstatusbarhdl,handles.jwaitbarhdl]=uh_uiframe('figname',mfilename,...
    'units','norm','position',[1.1 0.3 0.5 0.6],...
    'toolbar','figure',...
    'statusbar',1,...
    'waitbarpos','East','waitbarstr',0,...
    'icon',handles.iconlist.uh,'logo','none',...
    'logopos',[0.89,0.79,0.2,0.2]);
% set(handles.jwaitbarhdl,'PreferredSize',java.awt.Dimension(200,15))
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
% combobox and List files
uistring={icontext(handles.iconlist.action.updir,''),...
    {cd,filedir,'C:\','P:\MatlabCode\uhlib','P:\Dropbox\LTP_Publication'},...
    icontext(handles.iconlist.action.newfolder,''),...    
    };
w=0.36-gvar.margin.gap; h=0.06;
[container_currdir,handles.pushbutton_updir,handles.combobox_currdir,handles.pushbutton_newdir,...    
    ]=uigridcomp({'pushbutton','combobox','pushbutton',...    
    },...
    'uistring',uistring,...
    'position',[gvar.margin.l 1-2*gvar.margin.l-h w h],...
    'gridsize',[1 3],'gridmargin',5,'hweight',[1 8 1],'vweight',1);
% Listbox for file list
uistring={'',...    
    };
[container_filelist,handles.jlistbox_filenameinput,...
    ]=uigridcomp({'list',...    
    },...
    'uistring',uistring,...    
    'gridsize',[1 1],'gridmargin',5,'hweight',1,'vweight',1);

% Serial Control Panel
uistring={{'COM'},icontext(handles.iconlist.action.scan,'SCAN'),...
    {'9600','19200','115200'},icontext(handles.iconlist.serial,'OPEN'),...
    'Status: NaN',icontext(handles.iconlist.serial,'Status'),...
    '', icontext(handles.iconlist.action.export,'Write'),...
    icontext(handles.iconlist.action.import,'Read'),'','',...
    };
[container_serial,handles.combobox_serialList,...
    handles.pushbutton_serialScan,...
    handles.combobox_serialBaudrate,...
    handles.pushbutton_serialOpen,...
    handles.edit_serialStatus,~,...
    handles.edit_serialWrite, handles.pushbutton_serialWrite,...
    handles.pushbutton_serialRead,...
    ]=uigridcomp({'combobox','pushbutton',...
    'combobox','pushbutton',...
    'edit','label',...
    'edit','pushbutton',...
    'pushbutton','label',...
    },...
    'uistring',uistring,...
    'gridsize',[5 2],'gridmargin',5,'hweight',[7 3],'vweight',[1 1 1 1 1]);
% Status and display incoming serial data
uistring={'',...
    };
[container_serialData,handles.list_serialData,...
    ]=uigridcomp({'mlist',...
    },...
    'uistring',uistring,...
    'gridsize',[1 1],'gridmargin',5,'hweight',1,'vweight',1);
% Group all related serial object into panel
uipanel_serial=uipanellist('title','SERIAL',...
    'objects',[container_serial,container_serialData],...
    'itemheight',[0.6 0.35],...
    'itemwidth',[0.95 0.95],...
    'gap',[0 gvar.margin.gap]);
% Parameter Settings
uistring={'','0','Param1',...    
    };
[container_setting,...    
    handles.slider_param1, handles.edit_param1,~,...    
    ]=uigridcomp({'slider','edit','label',...        
    },...
    'uistring',uistring,...
    'gridsize',[1 3],'gridmargin',5,'hweight',[6 2 1],'vweight',[1]);
% Plot Angle axes
uistring={'',...  
    };
[container_axes_serial,...    
    handles.axes_serial,...
    ]=uigridcomp({'axes',...    
    },...
    'uistring',uistring,...
    'gridsize',[1 1],'gridmargin',5,'hweight',[1],'vweight',[1]);
uipanel_setting = uipanellist('title','SETTING',...
    'objects',[container_setting, container_axes_serial],...
    'itemheight',[0.075 0.9],...
    'itemwidth',[0.95 0.95],...
    'gap',[0 gvar.margin.gap]);

% Panel. Play and save option
uistring={'Filename','','Save',...
    icontext(handles.iconlist.action.play,''),...
    };
[container_play,...        
    ~,handles.edit_logFilename,handles.checkbox_saveOption,...
    handles.pushbutton_play,...
    ]=uigridcomp({    
    'label','edit','checkbox',...
    'pushbutton',...
    },...
    'uistring',uistring,...
    'gridsize',[1 4],'gridmargin',5,'hweight',[0.12 0.5 0.15 0.2],'vweight',[1]);
uipanel_save = uipanellist('title','PLAY',...
    'objects',[container_play],...
    'itemheight',[0.95],...
    'itemwidth',[0.95],...
    'gap',[0 gvar.margin.gap]);
% Alignment
uialign(container_filelist,container_currdir,'align','southwest','scale',[1 5.5],'gap',[0 -gvar.margin.gap]);
uialign(uipanel_serial,container_filelist,'align','southwest','scale',[1 1.5],'gap',[0 -2*gvar.margin.gap]);
uialign(uipanel_save,container_currdir,'align','east','scale',[1.75 1.5],'gap',[gvar.margin.gap 0]);
uialign(uipanel_setting,uipanel_save,'align','southwest','scale',[1 9.05],'gap',[0 -gvar.margin.gap]);
% Initialize
set(handles.combobox_currdir,'selectedindex',0);
uijlist_setfiles(handles.jlistbox_filenameinput,get(handles.combobox_currdir,'selecteditem'));
handles.keyholder = '';
% Default Serial Settings
set(handles.combobox_serialList,'selectedIndex',0);
set(handles.combobox_serialBaudrate,'selectedIndex',2);
% Initiate slider and edit Setting;
set(handles.slider_param1,'min',0,'max',1,...
    'sliderstep',[0.01, 0.1],'value',0);
set(handles.edit_param1,'string','0');
% Default edit filename
set(handles.edit_logFilename,'string',...
    strcat(datestr(now(),'yyyy_mm_dd'), '-S01-T01.txt'));
% Default checkbox
set(handles.checkbox_saveOption,'value',1);
% Set timer;
loopRate = 100; % Hz
loopTime = 1/loopRate;
handles.loopTime = loopTime;
handles.mytimer = timer('ExecutionMode','fixedDelay',...
    'Period',loopTime,...
    'BusyMode','drop',...
    'TimerFcn',{@timerFcn_Callback,handles},...
    'StopFcn',{@timerStopFcn_Callback,handles},...
    'ErrorFcn',{@timerErrorFcn_Callback,handles});
% Initialize Global variables
handles.mySerial = []; % Empty serial port handles.
handles.logData = [];
% Set callback
% Keyboar thread
set(handles.figure,'WindowKeyPressFcn',{@KeyboardThread_Callback,handles});
% Pushbutton
set(handles.pushbutton_updir,'Callback',{@pushbutton_updir_Callback,handles});
set(handles.pushbutton_newdir,'Callback',{@pushbutton_newdir_Callback,handles});
set(handles.pushbutton_serialScan,'Callback',{@pushbutton_serialScan_Callback,handles});
set(handles.pushbutton_serialOpen,'Callback',{@pushbutton_serialOpen_Callback,handles});
set(handles.pushbutton_serialRead,'Callback',{@pushbutton_serialRead_Callback,handles});
set(handles.pushbutton_serialWrite,'Callback',{@pushbutton_serialWrite_Callback,handles});
set(handles.pushbutton_play,'Callback',{@pushbutton_play_Callback,handles});
% Slider and Edit parameter settings
set(handles.slider_param1,'Callback',{@slider_edit_param1_Callback,handles});
set(handles.edit_param1,'Callback',{@slider_edit_param1_Callback,handles});
% combobox
set(handles.combobox_currdir,'ActionPerformedCallback',{@combobox_currdir_Callback,handles});
% jlistbox
set(handles.jlistbox_filenameinput,'MousePressedCallback',{@jlistbox_filenameinput_Mouse_Callback,handles});
set(handles.jlistbox_filenameinput,'KeyPressedCallback',{@KeyboardThread_Callback,handles});
% Setappdata
setappdata(handles.figure,'handles',handles);
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
jwait = get(handles.jwaitbarhdl,'value');
if jwait == 100, jwait = 0; end;
set(handles.jwaitbarhdl,'value',jwait + 1);
% elapsedTime =  toc(thisStamp);
% while (elapsedTime < handles.loopTime)    
%     elapsedTime = toc(thisStamp);
% end
% saveOpt = get(handles.checkbox_saveOption,'value');
% if saveOpt == 1
% fprintf(handles.fid,'%.3f \n',toc(handles.startTime));
handles.logData = [handles.logData; toc(handles.startTime)];
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
function pushbutton_play_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
% ==== START
% Get filename and save Option
currdir = get(handles.combobox_currdir,'selecteditem');
filename = get(handles.edit_logFilename,'string');
saveOpt = get(handles.checkbox_saveOption,'value');
% Get parameter settings
param1 = str2double(get(handles.edit_param1,'string'));
% Reset plot
cla(gca,'reset');
set(gca,'ylim',[-90 90]);
xlabel(gca,'Time (s)');
ylabel(gca,'Serial Data');

sampling_rate = 100;
counter = 0;
filename = 'staticTorque.txt';
fid = fopen(fullfile(cd,filename),'w');
startTime = tic;
logData = [];
while(toc(startTime) < 60)
    counter = counter + 1;
    loopStart = tic;
%     fprintf(fid,'%.3f \n',toc(startTime));    
    logData(end+1,:) = toc(startTime);
    if counter == sampling_rate
        counter = 0;        
        fprintf('Loop rate: %.1f Hz.\n', 1/(toc(loopStart)));
    end
    while (toc(loopStart) < 1/sampling_rate)
        %
    end            
end
% fclose(fid);
figure;
plot(1./diff(logData))

% Run or Stop
% if strcmpi(get(hObject,'string'),icontext(handles.iconlist.action.play,''))
%     set(hObject,'string',icontext(handles.iconlist.status.stop,''));
% %     pause(0.01);
%     handles.startTime = tic;
%     % Real-time plot
%     handles.dataLine = animatedline('MaximumNumPoints',1000,...
%         'color','k');
%     if saveOpt == 1
% %         handles.fid = fopen(fullfile(currdir,filename),'w');
% %         fprintf(handles.fid,'Experimental Setup:\n');
% %         fprintf(handles.fid,'Vibration Freq (Hz): %.2f\n',freq);
% %         fprintf(handles.fid,'Delay Time (sec): %.2f\n',delay);
% %         fprintf(handles.fid,'Duration (sec): %.2f\n',duration);
% %         fprintf(handles.fid,'Event Markers\n');
% %         fprintf(handles.fid,'Time(sec) \t Event(1-Mocap; 2-Heel Contact+Vib; 3-Heel Contact)\n');
%     end
%     setappdata(handles.figure,'handles',handles);
%     start(handles.mytimer);
% else
%     set(hObject,'string',icontext(handles.iconlist.action.play,''));
%     if saveOpt == 1
%         % Increase filename trial number by 1
%         currFile = get(handles.edit_logFilename,'string');
%         [~,filename] = fileparts(currFile);
%         trialNum = str2num(filename(end-1:end));
%         newFilename = filename;
%         newFilename(end-1:end) = sprintf('%.2d',trialNum+1);
%         set(handles.edit_logFilename,'string',[newFilename '.txt']);
%         logData = handles.logData;
%         % Close fid
%         assignin('base','logData', logData);
% %         fclose(handles.fid);
%         uijlist_setfiles(handles.jlistbox_filenameinput,currdir,'type',{'.all'},'fontsize',4);
%     end
%     stop(handles.mytimer);
% end
% ==== END
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);
