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
    'units','norm','position',[1.1 0.3 0.25 0.5],...
    'toolbar','figure',...
    'statusbar',1, 'icon',handles.iconlist.uh,'logo','none',...
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
% combobox and List files
uistring={icontext(handles.iconlist.action.updir,''),...
    {cd,filedir,'C:\','P:\MatlabCode\uhlib','P:\Dropbox\LTP_Publication'},...
    icontext(handles.iconlist.action.newfolder,''),...    
    };
w=1-gvar.margin.gap; h=0.1;
[container_currdir,handles.pushbutton_updir,handles.combobox_currdir,handles.pushbutton_newdir,...    
    ]=uigridcomp({'pushbutton','combobox','pushbutton',...    
    },...
    'uistring',uistring,...
    'position',[gvar.margin.l 1-4*gvar.margin.l-h w h],...
    'gridsize',[1 3],'gridmargin',5,'hweight',[1 8 1],'vweight',1);
% Listbox for file list
uistring={'',...    
    };
[container_filelist,handles.jlistbox_filenameinput,...
    ]=uigridcomp({'list',...    
    },...
    'uistring',uistring,...    
    'gridsize',[1 1],'gridmargin',5,'hweight',1,'vweight',1);
% Alignment
uialign(container_filelist,container_currdir,'align','southwest','scale',[1 5.5],'gap',[0 -gvar.margin.gap]);
% Initialize
set(handles.combobox_currdir,'selectedindex',0);
uijlist_setfiles(handles.jlistbox_filenameinput,get(handles.combobox_currdir,'selecteditem'));
handles.keyholder = '';
% Set callback
% Keyboar thread
set(handles.figure,'WindowKeyPressFcn',{@KeyboardThread_Callback,handles});
% Pushbutton
set(handles.pushbutton_updir,'Callback',{@pushbutton_updir_Callback,handles});
set(handles.pushbutton_newdir,'Callback',{@pushbutton_newdir_Callback,handles});
% combobox
set(handles.combobox_currdir,'ActionPerformedCallback',{@combobox_currdir_Callback,handles});
% jlistbox
set(handles.jlistbox_filenameinput,'MousePressedCallback',{@jlistbox_filenameinput_Mouse_Callback,handles});
set(handles.jlistbox_filenameinput,'KeyPressedCallback',{@KeyboardThread_Callback,handles});
% Setappdata
setappdata(handles.figure,'handles',handles);
%=============

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
        jeditload(handles.jedit_editor,fullfile(currdir,filename));        
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