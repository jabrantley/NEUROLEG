function uh_gui_makemfile(varargin)
% v 1.0
% 2016/09/24
% Author: Phat Luu. tpluu2207@gmail.com
% Brain Machine Interface Lab
% University of Houston, TX, USA.
% ===================================================================
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
%====STEP 1: FRAME====
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
% combobox and List files
uistring={icontext(handles.iconlist.action.updir,''),...
    {cd,filedir,'C:\','P:\MatlabCode\uhlib',...
    'P:\Dropbox\LTP_Publication',...
    'G:\OneDrive\MatlabCode\PediatricEXO',...
    'G:\OneDrive\UH-PROJECT-EXO\PEDIATRICS\PedExo_Code',...
    },...
    icontext(handles.iconlist.action.newfolder,''),...    
    };
w=1-gvar.margin.gap; h=0.1;
[container_currdir,handles.pushbutton_updir,handles.combobox_currdir,handles.pushbutton_newdir,...    
    ]=uigridcomp({'pushbutton','combobox','pushbutton',...    
    },...
    'uistring',uistring,...
    'position',[gvar.margin.l 1-4*gvar.margin.l-h w h],...
    'gridsize',[1 3],'gridmargin',5,'hweight',[1 8 1],'vweight',1);
% list box
uistring={'',...    
    };
[container_filelist,handles.jlistbox_filenameinput,...
    ]=uigridcomp({'list',...    
    },...
    'uistring',uistring,...    
    'gridsize',[1 1],'gridmargin',5,'hweight',1,'vweight',1);
% Filename
uistring={icontext(handles.iconlist.file.new,'File name'),...
    {'mfile','Class','GUI','GUI_serial','pcode',...
    'ino','cpp','h','pythonDLproject','Articles',},...
    '',...    
    };
[container_filename,~,handles.combobox_filetype,handles.edit_newfilename,...
    ]=uigridcomp({'label','combobox','edit',...    
    },...
    'uistring',uistring,...    
    'gridsize',[1 3],'gridmargin',5,'hweight',[1.5 2 6.5],'vweight',1);
% Save and cancel button
uistring={'',icontext(handles.iconlist.action.save,'Save'),icontext(handles.iconlist.action.delete,'Cancel'),...    
    };
[container_savecancel,~,handles.pushbutton_save,handles.pushbutton_cancel,...
    ]=uigridcomp({'label','pushbutton','pushbutton',...    
    },...
    'uistring',uistring,...    
    'gridsize',[1 3],'gridmargin',5,'hweight',[6 2 2],'vweight',1);
% Alignment
uialign(container_filelist,container_currdir,'align','southwest','scale',[1 5.5],'gap',[0 -gvar.margin.gap]);
uialign(container_filename,container_filelist,'align','southwest','scale',[1 1/6],'gap',[0 -gvar.margin.gap]);
uialign(container_savecancel,container_filename,'align','southwest','scale',[1 1],'gap',[0 -gvar.margin.gap]);
% Initialize
set(handles.combobox_currdir,'selectedindex',0);
set(handles.combobox_filetype,'selectedindex',0);
uijlist_setfiles(handles.jlistbox_filenameinput,get(handles.combobox_currdir,'selectedItem'));
handles.keyholder = '';

% Setappdata
setappdata(handles.figure,'handles',handles);
% Set callback
set(handles.pushbutton_updir,'Callback',{@pushbutton_updir_Callback,handles});
set(handles.pushbutton_newdir,'Callback',{@pushbutton_newdir_Callback,handles});
set(handles.pushbutton_save,'Callback',{@pushbutton_save_Callback,handles});
set(handles.pushbutton_cancel,'Callback',{@pushbutton_cancel_Callback,handles});
% combobox
set(handles.combobox_currdir,'ActionPerformedCallback',{@combobox_currdir_Callback,handles});
% jlistbox
set(handles.jlistbox_filenameinput,'MousePressedCallback',{@jlistbox_filenameinput_Mouse_Callback,handles});
set(handles.jlistbox_filenameinput,'KeyPressedCallback',{@KeyboardThread_Callback,handles});

%=============
function pushbutton_newdir_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
prompt = {'Select Folder Name:'};
dlg_title = 'New Folder';
num_lines = [1 50];
defaultans = {'New Folder'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
if ~isempty(answer)
    mkdir(get(handles.combobox_currdir,'selectedItem'),answer{1});
    uijlist_setfiles(handles.jlistbox_filenameinput,get(handles.combobox_currdir,'selectedItem'));
end
setappdata(handles.figure,'handles',handles);

function pushbutton_save_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
newfilename = get(handles.edit_newfilename,'string');
currdir = get(handles.combobox_currdir,'selectedItem');
filetype = get(handles.combobox_filetype,'selectedItem');
fprintf('Make new %s: %s.\n',filetype,newfilename);
if strcmpi(filetype,'mfile')
    makemfile('filedir',currdir,...
        'filename',newfilename,...
        'template','templatecode_mfile.m');
elseif strcmpi(filetype,'class')
    makemfile('filedir',currdir,...
        'filename',newfilename,...
        'template','templatecode_mclass.m');    
elseif strcmpi(filetype,'article')    
    makenewarticle('filedir',currdir,'filename',newfilename);
elseif any(strcmpi({'ino','cpp','h'},filetype))    
    makemfile('filedir',currdir,...
        'filename',newfilename,...
        'template','templatecode_ino.txt',...
        'ext',filetype);
elseif strcmpi(filetype,'gui')
    makemfile('filedir',currdir,...
        'filename',newfilename,...
        'template','templatecode_gui.m');
elseif strcmpi(filetype,'gui_serial')
    makemfile('filedir',currdir,...
        'filename',newfilename,...
        'template','templatecode_gui_serial.m');    
elseif strcmpi(filetype,'pythondlproject')    
    makePythonDeepLearningProject('filedir',currdir,'filename',newfilename);
elseif strcmpi(filetype,'pcode')     
    makePcode(hObject, eventdata, handles);
end
uijlist_setfiles(handles.jlistbox_filenameinput,get(handles.combobox_currdir,'selectedItem'));
setappdata(handles.figure,'handles',handles);

function pushbutton_cancel_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
close(handles.figure);

function makePcode(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
% ==== GUI INPUT
handles=getappdata(handles.figure,'handles');
currdir=get(handles.combobox_currdir,'selecteditem');
% ==== START
expStr = get(handles.edit_newfilename,'string');
expFullfile = fullfile(currdir,expStr);
[expPath, expName, expExt] = fileparts(expFullfile);
if isempty(expExt) % Folder selected
    % Clone the directory
    rootDir = currdir;
    cloneDir = expName;
    if ~strcmpi(pwd, rootDir)
        cd(currdir);
    end    
    if exist(cloneDir)==7
        strcmd = sprintf('rmdir %s s',cloneDir);
        eval(strcmd);
    end
    mkdir(cloneDir);
    strcmd = sprintf('copyfile %s %s', rootDir, cloneDir);
    eval(strcmd);
    % Go to cloneDir to remove .git folder
    cd(cloneDir);
    if exist('.git')
        try
            rmdir .git s
        catch
        end
    end
    % Glob and generate .p file    
    strcmd = sprintf('mfileList = glob(''%s/**.m'')',fullfile(rootDir,cloneDir));
    eval(strcmd)        
    for i = 1 : length(mfileList)
        thisFile = mfileList{i};
        [pDir, filename] = fileparts(thisFile);
        cd(pDir);
        try
            pcode(filename);
            delete(thisFile)
            fprintf('DONE: %s.\n',thisFile);
        catch
            fprintf('Failed to generate pcode for %s.\n',thisFile);
        end
    end
    cd(rootDir);
elseif strcmpi(expExt,'.p')
    cd(expPath);
    pcode(expName);
else
    return;
end
uijlist_setfiles(handles.jlistbox_filenameinput,currdir,'type',{'.all'});
% ==== END
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

function pushbutton_updir_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
% dirlist=get(handles.popupmenu_currdir,'string');
% currdir=dirlist{get(handles.popupmenu_currdir,'value')};
currdir=get(handles.combobox_currdir,'selecteditem');
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
% uijlist_setfiles(handles.jlistbox_filenameinput,updir,'type',{'.all'});
setappdata(handles.figure,'handles',handles);

function combobox_currdir_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
newdir=get(hObject,'selecteditem');
if strcmpi(newdir,'.\');
    newdir=cd;
end
if ~strcmpi(newdir,hObject.getItemAt(0))
    hObject.insertItemAt(newdir,0);
end
uijlist_setfiles(handles.jlistbox_filenameinput,newdir,'type',{'.all'});
setappdata(handles.figure,'handles',handles);

function jlistbox_filenameinput_Mouse_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
eventinf=get(eventdata);
if eventinf.Button == 1 && eventinf.ClickCount == 2 %double left click
    handles = jlistbox_filenameinput_load(hObject,handles);
elseif eventinf.Button == 1 && eventinf.ClickCount == 1 %double left click
    val=get(hObject,'SelectedValue');
    mark1=strfind(val,'>');mark1=mark1(end-1);
    mark2=strfind(val,'<');mark2=mark2(end);
    filename=val(mark1+1:mark2-1);
    [~,selname,ext]=fileparts(filename);
    filetype = get(handles.combobox_filetype,'selectedItem');
    if strcmpi(filetype,'pcode')
        if isempty(ext)     %folder selection
            set(handles.edit_newfilename,'string',strcat(selname,'Pcode'));
        elseif strcmpi(ext,'.m')
            set(handles.edit_newfilename,'string',strcat(selname,'.p'));
        else
            set(handles.edit_newfilename,'string','');
        end
    else
        set(handles.edit_newfilename,'string',selname);
    end
elseif eventinf.Button==3       %Right Click
%     handles.jmenu.show(hObject,eventinf.X,eventinf.Y);
%     handles.itempos.x=eventinf.X;
%     handles.itempos.y=eventinf.Y;
end
% Setappdata
setappdata(handles.figure,'handles',handles);

function handles = jlistbox_filenameinput_load(hObject,handles);
handles=getappdata(handles.figure,'handles');
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
%=====
val=get(hObject,'SelectedValue');
mark1=strfind(val,'>');mark1=mark1(end-1);
mark2=strfind(val,'<');mark2=mark2(end);
filename=val(mark1+1:mark2-1);
[~,selname,ext]=fileparts(filename);
currdir=get(handles.combobox_currdir,'selecteditem');
if isempty(ext)     %folder selection
    if strcmpi(currdir(end),'\')
        newdir=strcat(currdir,selname);
    else
        newdir=strcat(currdir,'\',selname);
    end
    uijlist_setfiles(handles.jlistbox_filenameinput,newdir,'type',{'.all'});
    handles.combobox_currdir.insertItemAt(newdir,0);
    set(handles.combobox_currdir,'selectedindex',0);
elseif strcmpi(ext,'.m')
    edit(fullfile(currdir,filename));
elseif strcmpi(ext,'.mat')
    fprintf('Load: %s.\n',filename);
    myfile = class_FileIO('filename',filename,'filedir',currdir);
    myfile.loadtows;
    handles.kinfile = myfile;
    kin = evalin('base','kin');            
    uisetjlistbox(handles.jlistbox_matdata,gcinfo2list(kin.gc.index,kin.gc.label));
    for i = 1 : length(kin.gc.transleg)
        if strcmpi(kin.gc.transleg(i),'l'), idx = 1;
        else idx = 2; end
        set(handles.radio_transleg(i).group,'selectedobject',handles.radio_transleg(i).items{idx});
    end
    set(handles.jlistbox_matdata,'SelectedIndex',0);
    updateSignalplot(handles);
    anno_signalax(handles);
    jlistbox_matdata_Callback(handles.jlistbox_matdata,[],handles);    
end
fprintf('DONE...%s.\n',thisFuncName);
% Setappdata
setappdata(handles.figure,'handles',handles);

function handles=KeyboardThread_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
% -----------
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
key
if strcmpi(handles.keyholder,'g')
    if strcmpi(key,'l') % Set focus on function list
        handles.jlistbox_matdata.requestFocus; 
        fprintf('jlistbox_funclist is selected.\n');
    elseif strcmpi(key,'f') % Set focus on mfile list
        handles.jlistbox_filenameinput.requestFocus;
        fprintf('jlistbox_filenameinput is selected.\n');
    elseif strcmpi(key,'c') % Set focus on popupmenu_currdir
        handles.combobox_currdir.requestFocus;
        fprintf('combobox_currdir is selected.\n');    
    end
elseif strcmpi(handles.keyholder,'shift')
    if strcmpi(key,'return') || strcmpi(key,'enter')
        pushbutton_update_Callback(handles.pushbutton_update,[],handles);        
    end
elseif strcmpi(handles.keyholder,'ctrl') || strcmpi(handles.keyholder,'control') && strcmpi(key,'s')
    pushbutton_save_Callback(handles.pushbutton_save,[],handles);
else
    if strcmpi(key,'delete')
        fprintf('Remove selected file.\n');
        val=get(hObject,'SelectedValue');
        mark1=strfind(val,'>');mark1=mark1(end-1);
        mark2=strfind(val,'<');mark2=mark2(end);
        filename=val(mark1+1:mark2-1);
        [~,selname,ext]=fileparts(filename);
        currdir=get(handles.combobox_currdir,'selecteditem');
        if any([strcmpi(ext,'.folder'),isempty(ext)])
            fullname = fullfile(currdir,selname);
            strcmd = sprintf('rmdir(''%s'')',fullname);
            eval(strcmd);
        else
            fullfilename = fullfile(currdir,[selname ext]);
            strcmd = sprintf('delete(''%s'')',fullfilename);
            eval(strcmd);
        end
        uijlist_setfiles(handles.jlistbox_filenameinput,currdir,'type',{'.all'});
    end
end
handles.keyholder = ''; % reset keyholder;
setappdata(handles.figure,'handles',handles);