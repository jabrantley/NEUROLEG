%% GUI_Serial_Test-001.m
%% *Description:*
%% *Usages:*
%
% *Inputs:*
%
% *Outputs:*
%
% *Options:*
%
% *Notes:*
%
%% *Authors:*
% * *MATLAB Ver :* 9.3.0.713579 (R2017b)
% * *Date Created :* 30-Mar-2019 02:25:10
% * *Author:* Phat Luu. ptluu2@central.uh.edu
%
% _Laboratory for Noninvasive Brain Machine Interface Systems._
%
% _University of Houston_
%

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%%
function varargout = GUI_Serial_Test(varargin)
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
    'units','norm','position',[1.1 0.3 0.4 0.5],...
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
    };
[container_serial,handles.combobox_serialList,...
    handles.pushbutton_serialScan,...
    handles.combobox_serialBaudrate,...
    handles.pushbutton_serialOpen,...
    handles.edit_serialStatus,~,...
    handles.edit_serialWrite, handles.pushbutton_serialWrite,...
    ]=uigridcomp({'combobox','pushbutton',...
    'combobox','pushbutton',...
    'edit','label',...
    'edit','pushbutton',...
    },...
    'uistring',uistring,...
    'gridsize',[4 2],'gridmargin',5,'hweight',[7 3],'vweight',[ 1 1 1 1]);

% Group all related serial object into panel
uipanel_serial=uipanellist('title','SERIAL',...
    'objects',[container_serial],...
    'itemheight',[1],...
    'itemwidth',[0.95],...
    'gap',[0 gvar.margin.gap]);

% Read and display serial data
uistring={icontext(handles.iconlist.action.refresh,'Loop'),...
    icontext(handles.iconlist.action.import,'Read'),...
    };
[container_serialread,...
    handles.checkbox_loop,...
    handles.pushbutton_serialRead,...
    ]=uigridcomp({'checkbox','pushbutton',...
    },...
    'uistring',uistring,...
    'gridsize',[1 2],'gridmargin',5,'hweight',[1 1],'vweight',1);

uistring={'',...
    };
[container_serialData,handles.list_serialData,...
    ]=uigridcomp({'mlist',...
    },...
    'uistring',uistring,...
    'gridsize',[1 1],'gridmargin',5,'hweight',1,'vweight',1);

% Group all related serial object into panel
uipanel_serialread=uipanellist('title','SERIAL READ',...
    'objects',[container_serialread, container_serialData],...
    'itemheight',[0.15 0.8],...
    'itemwidth',[0.95 0.95],...
    'gap',[0 gvar.margin.gap]);

% Alignment
uialign(container_filelist,container_currdir,'align','southwest','scale',[1 5],'gap',[0 -gvar.margin.gap]);
uialign(uipanel_serial,container_filelist,'align','southwest','scale',[1 1],'gap',[0 -2*gvar.margin.gap]);
uialign(uipanel_serialread,container_currdir,'align','east','scale',[1.7 11.5],'gap',[2*gvar.margin.gap 0]);
% Initialize
set(handles.combobox_currdir,'selectedindex',0);
uijlist_setfiles(handles.jlistbox_filenameinput,get(handles.combobox_currdir,'selecteditem'));
handles.keyholder = '';
% Default Serial Settings
set(handles.combobox_serialList,'selectedIndex',0);
set(handles.combobox_serialBaudrate,'selectedIndex',2);
% Default checkbox
set(handles.checkbox_loop,'value',0);
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
% Check box
set(handles.checkbox_loop,'Callback',{@checkbox_loop_Callback,handles});
% combobox
set(handles.combobox_currdir,'ActionPerformedCallback',{@combobox_currdir_Callback,handles});
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
        if length(dataList) == 100
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

% Check box
function checkbox_loop_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
% ==== START
currVal = get(hObject, 'value');
if currVal == 1
    start(handles.mytimer);
else
    stop(handles.mytimer);
end
% ==== END
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

% TIMER related
function timerFcn_Callback(hObject,eventdata,handles)
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
% ==== START
pushbutton_serialRead_Callback(hObject,eventdata,handles)
% Update Status bar
jwait = get(handles.jwaitbarhdl,'value');
if jwait == 100, jwait = 0; end;
set(handles.jwaitbarhdl,'value',jwait + 1);
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
