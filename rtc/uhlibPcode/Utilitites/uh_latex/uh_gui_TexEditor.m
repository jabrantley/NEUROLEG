function uh_gui_TexEditor(varargin)
% v 1.0
% 2016/09/24
% Author: Phat Luu. tpluu2207@gmail.com
% Brain Machine Interface Lab
% University of Houston, TX, USA.
% ===================================================================
% Add Paths and external libs
% Debug
close all;
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
    'units','norm','position',[1 0.25 1 0.9],...
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
    {cd,filedir,'C:\','P:\MatlabCode\uhlib','P:\Dropbox\LTP_Publication'},...
    icontext(handles.iconlist.action.newfolder,''),...    
    };
w=0.2-gvar.margin.gap; h=0.05;
[container_currdir,handles.pushbutton_updir,handles.combobox_currdir,handles.pushbutton_newdir,...    
    ]=uigridcomp({'pushbutton','combobox','pushbutton',...    
    },...
    'uistring',uistring,...
    'position',[gvar.margin.l 1-2*gvar.margin.l-h w h],...
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
uistring={...
    {'Draft','IEEE Conf'},...
    '',...    
    icontext(handles.iconlist.file.new,'New')
    };
[container_filename,handles.combobox_filetype,handles.edit_newfilename,handles.pushbutton_save,...
    ]=uigridcomp({'combobox','edit','pushbutton',...    
    },...
    'uistring',uistring,...    
    'gridsize',[1 3],'gridmargin',5,'hweight',[3 5 2],'vweight',1);
% MATLAB EDITOR
% Edit text and save button
uistring={'',...
    icontext(handles.iconlist.action.import,'Load'),...
    icontext(handles.iconlist.action.play,'Run'),...
    icontext(handles.iconlist.action.save,'Save'),...    
    };
[container_editorctrl,handles.edit_editorctrl,...
    handles.pushbutton_editorload,handles.pushbutton_editorrun,handles.pushbutton_editorsave,...    
    ]=uigridcomp({'edit','pushbutton','pushbutton','pushbutton',...    
    },...
    'uistring',uistring,...   
    'gridsize',[1 4],'gridmargin',5,'hweight',[7 1 1 1],'vweight',1);
uistring={...    
    repmat({icontext(handles.iconlist.uh100,'TOC','iconh',50,'iconw',100)},1,4),...
    '',...    
    repmat({icontext(handles.iconlist.uh100,'Fig Thumb','iconh',70,'iconw',100)},1,4),...
    };
[container_editor,handles.jedit_toc,handles.jedit_editor,handles.jedit_figlist,...
    ]=uigridcomp({'list','syntaxtext','list',...    
    },...
    'uistring',uistring,...    
    'gridsize',[3 1],'gridmargin',5,'hweight',1,'vweight',[1 7.5 1.5]);
set(handles.jedit_toc,'FixedCellHeight',70,'FixedCellWidth',100,...
    'LayoutOrientation',2,'VisibleRowCount',1) ; 
set(handles.jedit_figlist,'FixedCellHeight',100,'FixedCellWidth',100,...
    'LayoutOrientation',2,'VisibleRowCount',1) ; 
% BIBtext List
uistring={'',...
    icontext(handles.iconlist.action.import,'Load'),...
    icontext(handles.iconlist.action.save,'Save'),...    
    };
[container_bibctrl,handles.edit_bibctrl,handles.pushbutton_bibload,handles.pushbutton_bibsave,...    
    ]=uigridcomp({'edit','pushbutton','pushbutton',...    
    },...
    'uistring',uistring,...   
    'gridsize',[1 3],'gridmargin',5,'hweight',[6 2 2],'vweight',1);
uistring={...
    {'Item1','Item2'},...    
    };
[container_bib,handles.jlistbox_bib,...
    ]=uigridcomp({'list',...    
    },...
    'uistring',uistring,...    
    'gridsize',[1 1],'gridmargin',5,'hweight',1,'vweight',1);
% Alignment
uialign(container_filelist,container_currdir,'align','southwest','scale',[1 16],'gap',[0 -gvar.margin.gap]);
uialign(container_filename,container_filelist,'align','southwest','scale',[1 1/16],'gap',[0 -gvar.margin.gap]);
uialign(container_editorctrl,container_currdir,'align','east','scale',[3 1],'gap',[gvar.margin.gap 0]);
uialign(container_editor,container_editorctrl,'align','southeast','scale',[1 17.5],'gap',[0 -gvar.margin.gap]);
uialign(container_bibctrl,container_editorctrl,'align','east','scale',[1/3 1],'gap',[gvar.margin.gap 0]);
uialign(container_bib,container_bibctrl,'align','southeast','scale',[1 17.5],'gap',[0 -gvar.margin.gap]);
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
set(handles.pushbutton_editorsave,'Callback',{@pushbutton_editorsave_Callback,handles});
set(handles.pushbutton_editorrun,'Callback',{@pushbutton_editorrun_Callback,handles});
% combobox
set(handles.combobox_currdir,'ActionPerformedCallback',{@combobox_currdir_Callback,handles});
% jlistbox
set(handles.jlistbox_filenameinput,'MousePressedCallback',{@jlistbox_filenameinput_Mouse_Callback,handles});
set(handles.jlistbox_filenameinput,'KeyPressedCallback',{@KeyboardThread_Callback,handles});
set(handles.jlistbox_bib,'KeyPressedCallback',{@KeyboardThread_Callback,handles});
set(handles.jlistbox_bib,'MousePressedCallback',{@jlistbox_bib_Mouse_Callback,handles});

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
paperdir = get(handles.edit_newfilename,'string');
currdir = get(handles.combobox_currdir,'selectedItem');
papertype = get(handles.combobox_filetype,'selectedItem');
thismfilename = mfilename('fullpath');
[mfiledir, ~, ~] = fileparts(thismfilename);
fprintf('Make new Article Directory: %s.\nArticle type: %s.\n',paperdir,papertype);
% Make article folder name- Draft folder\figures - Reviewer folder-  
ex = exist(fullfile(currdir,paperdir),'dir'); % does M-file already exist ? Loop statement
newpaperdir = paperdir;
k = 1;
while ex == 7         % rechecking existence
    fprintf('Folder Exist: %s .\n',newpaperdir);
    newpaperdir = sprintf('%s-%03d',paperdir,k);
    k = k + 1;
    ex = exist(fullfile(currdir,newpaperdir),'dir'); % does M-file already exist ? Loop statement 
end
fprintf('Folder Created:%s.\n',newpaperdir);
% Make New Article Directory and copy bib file
mkdir(currdir,newpaperdir)
mkdir(fullfile(currdir,newpaperdir),'Draft');
fprintf('Folder Created:%s.\n',[newpaperdir '\Draft']);
mkdir(fullfile(currdir,newpaperdir),'Revision');
fprintf('Folder Created:%s.\n',[newpaperdir '\Revision']);
mkdir(fullfile(currdir,newpaperdir,'Draft'),'Figures');
copyfile(fullfile(mfiledir,'mybib.bib'),fullfile(currdir,newpaperdir,'Draft'));
copyfile(fullfile(mfiledir,'mybib.bib'),fullfile(currdir,newpaperdir,'Revision'));
% Copy template .mfile
draftmfilename = ['draft_' lower(strrep(newpaperdir,'-','_'))];
make_template('filedir',fullfile(currdir,newpaperdir,'Draft'),'filename',draftmfilename,...
    'template',papertype,'open',0);
% Load to editor
mfile = class_FileIO('filedir',fullfile(currdir,newpaperdir,'Draft'),'filename',draftmfilename,'ext','.m');
mfilecontents = mfile.uh_textscan;
cr=[char(13) char(10)]; %carry return
thiscode=[];
for i=1:length(mfilecontents)
    thiscode=[thiscode mfilecontents{i} cr];
end
handles.jedit_editor.setText(thiscode);
set(handles.edit_editorctrl,'string',mfile.fullfilename);
% Update currdir jcombo
updatejcombo(handles.combobox_currdir,fullfile(currdir,newpaperdir,'Draft'));
uijlist_setfiles(handles.jlistbox_filenameinput,get(handles.combobox_currdir,'selectedItem'));
setappdata(handles.figure,'handles',handles);

function pushbutton_editorsave_Callback(hObject,eventdata,handles)
editorfile = get(handles.edit_editorctrl,'string');
fid = fopen(editorfile,'w'); %allow write to text file
txtcode = char(handles.jedit_editor.getText);
txtcode = strrep(txtcode,'%','%%');
txtcode = strrep(txtcode,'\','\\');
fprintf(fid,txtcode);
fprintf('Save Manuscript: %s.\n',editorfile)
fclose(fid);

function pushbutton_bibload_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
fullfilename = get(handles.edit_bibctrl,'string');
if ~isempty(fullfilename)
    bibcell = tex_loadbibfile('filename',fullfile(currdir,filename));
    setjlistbox_bib(handles.jlistbox_bib,bibcell);
else
    fprintf('Bib file is not available.\n');
end
setappdata(handles.figure,'handles',handles);

function pushbutton_editorrun_Callback(hObject,eventdata,handles)
editorfile = get(handles.edit_editorctrl,'string');
[mfiledir,mtexfilename] = fileparts(editorfile);
addpath(mfiledir);
% Open in TexStudio
windowname = strcat(strrep(editorfile,'.m','.tex'),' - TexStudio'); % If use TexStudio to view tex file    
try % close tex file on TeXstudio    
    keyInject(windowname,'ALT__FC');
    pause(1);
catch
end
eval(mtexfilename);
pause(1);
try % Build and Run tex file on TexStudio;    
    keyInject(windowname,'ALT__T\r',mfilename);    
catch
end
handles.jedit_editor.requestFocus;

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
elseif eventinf.Button == 1 && eventinf.ClickCount == 1 %single left click
    val=get(hObject,'SelectedValue');
    mark1=strfind(val,'>');mark1=mark1(end-1);
    mark2=strfind(val,'<');mark2=mark2(end);
    filename=val(mark1+1:mark2-1);
    [~,selname,ext]=fileparts(filename);
    set(handles.edit_newfilename,'string',selname);
elseif eventinf.Button==3       %Right Click
%     handles.jmenu.show(hObject,eventinf.X,eventinf.Y);
%     handles.itempos.x=eventinf.X;
%     handles.itempos.y=eventinf.Y;
end
% Setappdata
setappdata(handles.figure,'handles',handles);

function jlistbox_bib_Mouse_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
eventinf=get(eventdata);
if eventinf.Button == 1 && eventinf.ClickCount == 2 %double left click
    biblist = uigetjlistbox(hObject,'select','selected');
    for i = 1 : length(biblist)
        thisbib = biblist{i};
        delim = strfind(thisbib,'|');
        temp = thisbib(1:delim-1);
        bibkey{i} = temp(~isspace(temp));        
    end
    caret = handles.jedit_editor.getCaretPosition;
    insertval = sprintf('\\cite{%s}',bibkey{1});
    content = char(handles.jedit_editor.getText);
%   cr=[char(13) char(10)]; %carry \n return \r
%     content(content==10)=[];
    content(content==13)=[];
    content
    if caret >= length(content)        
        newcontent = [content(1:caret),insertval];
    else
        newcontent = [content(1:caret),insertval,content(caret+1:end)];
    end
    handles.jedit_editor.setText(newcontent);
elseif eventinf.Button == 1 && eventinf.ClickCount == 1 %single left click    
elseif eventinf.Button==3       %Right Click
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
    filename = strrep(filename,'.m','');
    mfile = class_FileIO('filedir',currdir,'filename',filename,'ext','.m');
    mfilecontents = mfile.uh_textscan;
%     cr=[char(13) char(10)]; %carry return 10: newline
    cr = char(13);
    thiscode=[];
    for i=1:length(mfilecontents)
        thiscode=[thiscode mfilecontents{i} cr];
    end
    handles.jedit_editor.setText(thiscode);
    set(handles.edit_editorctrl,'string',mfile.fullfilename);
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
elseif strcmpi(ext,'.bib')    
    bibcell = tex_loadbibfile('filename',fullfile(currdir,filename));
    setjlistbox_bib(handles.jlistbox_bib,bibcell);
    set(handles.edit_bibctrl,'string',fullfile(currdir,filename));
end

fprintf('DONE...%s.\n',thisFuncName);
% Setappdata
setappdata(handles.figure,'handles',handles);

function setjlistbox_bib(jlistbox_bib,bibcell)
maxspace = 40;
spacing_arg = ['%-', num2str(maxspace),'s'];
for i = 1 : length(bibcell)
    thisbib = bibcell{i};
    bibcell{i} = strrep(thisbib,'|','  |  ');
%     delim = strfind(thisbib,'|');
%     bibkey = thisbib(1:delim(1)-1);
%     year = thisbib(delim(1)+1:delim(2)-1);
%     title = thisbib(delim(2)+1:end);
%     if delim < maxspace
%         bibkey = sprintf(spacing_arg,bibkey);
%     else
%     end
%     bibcell{i} = [bibkey,'| ',year,'|',title];
end
uisetjlistbox(jlistbox_bib,bibcell);

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
        val=get(hObject,'SelectedValue');
        mark1=strfind(val,'>');mark1=mark1(end-1);
        mark2=strfind(val,'<');mark2=mark2(end);
        filename=val(mark1+1:mark2-1);
        [~,selname,ext]=fileparts(filename);
        currdir=get(handles.combobox_currdir,'selecteditem');
        if strcmpi(ext,'.folder')
            rmdir(fullfile(currdir,selname));
        elseif strcmpi(ext,'.m')
            fullfilename = fullfile(currdir,[selname ext]);
            strcmd = sprintf('delete(''%s'')',fullfilename);
            eval(strcmd);
        end
        uijlist_setfiles(handles.jlistbox_filenameinput,currdir,'type',{'.all'});
    end
end
handles.keyholder = ''; % reset keyholder;
setappdata(handles.figure,'handles',handles);