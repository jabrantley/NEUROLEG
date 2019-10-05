%% templatecode_gui.m
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
% * *MATLAB Ver :* 9.0.0.341360 (R2016a)
% * *Date Created :* 04-Dec-2016 01:39:26
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
function GUI_pcodeGen(varargin)
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
% Edit filename and Export button.
uistring={'',icontext(handles.iconlist.file.page,'Input'),...
    '',icontext(handles.iconlist.action.export,''),...
    };
[container_export,handles.edit_filenameinput,~,...
    handles.edit_filenameoutput,handles.pushbutton_export,...
    ]=uigridcomp({'edit', 'label',...
    'edit','pushbutton',...
    },...
    'uistring',uistring,...
    'gridsize',[2 2],'gridmargin',5,'hweight',[8 2],'vweight',1);
% Alignment
uialign(container_filelist,container_currdir,'align','southwest','scale',[1 5.5],'gap',[0 -gvar.margin.gap]);
uialign(container_export,container_filelist,'align','southwest','scale',[1 0.3],'gap',[0 -gvar.margin.gap]);
% Initialize
set(handles.combobox_currdir,'selectedindex',0);
uijlist_setfiles(handles.jlistbox_filenameinput,get(handles.combobox_currdir,'selecteditem'));
handles.keyholder = '';
% Set callback
% Keyboar thread
set(handles.figure,'WindowKeyPressFcn',{@KeyboardThread_Callback,handles});
% Pushbutton
set(handles.pushbutton_updir,'Callback',{@pushbutton_updir_Callback,handles});
set(handles.pushbutton_export,'Callback',{@pushbutton_export_Callback,handles});
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

function pushbutton_export_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
currdir=get(handles.combobox_currdir,'selecteditem');
% ==== START
inputFullfile = get(handles.edit_filenameinput,'string');
expFullfile = get(handles.edit_filenameoutput,'string');
[expPath, expName, expExt] = fileparts(expFullfile);
if isempty(expExt) % Folder selected
    % Clone Directory
    if exist(expFullfile)
        fprintf('Removing existing Directory.\n');
        strcmd = sprintf('rmdir %s s',expFullfile);
        eval(strcmd);
    end
    strcmd = sprintf('copyfile %s %s', inputFullfile, expFullfile);
    fprintf('Cloning Input Directory.\n');
    eval(strcmd);
    % Glob to find .m file 
    mfileList = globFiles('dir',expFullfile,'filetype','alltree',...
        'key','.m');
    for i = 1 : length(mfileList)
        thisFile = mfileList{i};
        fprintf('Generate Pcode %d/%d: %s. \n',...
            i, length(mfileList), thisFile);
        try
            pcode(thisFile, '-inplace');
            delete(thisFile)
        catch
            fprintf('Failed to generate pcode for %s.\n',thisFile);
        end
    end
elseif strcmpi(expExt,'.p')    
    pcode(inputFullfile,'-inplace');
else
    return;
end
uijlist_setfiles(handles.jlistbox_filenameinput,currdir,'type',{'.all'});
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
if eventinf.Button==1
    % Convert list item with html char (icon) to filename
    filename = html2item(get(hObject,'SelectedValue'));
    [~,selname,ext]=fileparts(filename);
    currdir = get(handles.combobox_currdir,'selecteditem');
    if eventinf.ClickCount==2 %double left click
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
    elseif eventinf.ClickCount==1 %single left click
        if isempty(ext)     %folder selection
            set(handles.edit_filenameoutput,'string',...
                fullfile(currdir,strcat(selname,'Pcode')));
        elseif strcmpi(ext,'.m')
            set(handles.edit_filenameoutput,'string',...
                fullfile(currdir,strcat(selname,'.p')));
        else
            set(handles.edit_filenameoutput,'string','');
        end
        set(handles.edit_filenameinput,'string',fullfile(currdir,filename));
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
jMenuFile=JMenu('File');
jMenuBar.add(jMenuFile); % Add to jMenuBar
jMenuFile_New = JMenu('New');
jMenuFile.add(jMenuFile_New); % Add to jMenuFile
jMenuFile_New_Type1 = JMenuItem('Type 1...',ImageIcon(icons.file.m));
jMenuFile_New.add(jMenuFile_New_Type1);
jMenuFile_Open = javax.swing.JMenuItem('Open...',ImageIcon(icons.action.open));
jMenuFile.add(jMenuFile_Open);

jMenuHelp = JMenu('Help');
jMenuBar.add(jMenuHelp);
jMenuHelp_Doc = JMenuItem('Document...',ImageIcon(icons.web));
jMenuHelp.add(jMenuHelp_Doc);
jMenuBar.setPreferredSize(Dimension(100,28));
jMenuBar.setBackground(Color.white);
handles.jMenuBar=jMenuBar;
% Callback Define and Functions
hjMenuFile_New_Type1 = handle(jMenuFile_New_Type1,'CallbackProperties');
set(hjMenuFile_New_Type1,'ActionPerformedCallback',{@jMenuFile_New_Type1_Callback,handles});
% Open
hjMenuFile_Open = handle(jMenuFile_Open,'CallbackProperties');
set(hjMenuFile_Open,'ActionPerformedCallback',{@jMenuFile_Open_Callback,handles});
% Help
hjMenuHelp_Doc = handle(jMenuHelp_Doc,'CallbackProperties');
set(hjMenuHelp_Doc,'ActionPerformedCallback',{@jMenuHelp_Doc_Callback,handles});

javacomponent(jMenuBar,'North',handles.figure);
