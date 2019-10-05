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
function uh_gui_mri_boundary(varargin)
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
    'units','norm','position',[1.1 0.2 0.7 0.7],...
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
% Look for eeglab folder
matlabcodepath = uh_fileparts('level',3);
dirlist = dir(matlabcodepath);
for i = 1 : length(dirlist)
    if strfind(dirlist(i).name,'eeglab')
        eeglabdir = fullfile(matlabcodepath,dirlist(i).name); break;
    end
end
uistring={icontext(handles.iconlist.action.updir,''),...
    {uh_fileparts('fullpath',mfilename('fullpath'))},...
    icontext(handles.iconlist.action.newfolder,''),...
    };
w=1-gvar.margin.gap; h=0.1;
[container_currdir,handles.pushbutton_updir,handles.combobox_currdir,handles.pushbutton_newdir,...
    ]=uigridcomp({'pushbutton','combobox','pushbutton',...
    },...
    'uistring',uistring,...
    'position',[gvar.margin.l 1-4*gvar.margin.l-h 0.25 h],...
    'gridsize',[1 3],'gridmargin',5,'hweight',[1 8 1],'vweight',1);
% Listbox for file list
uistring={'',...
    };
[container_filelist,handles.jlistbox_filenameinput,...
    ]=uigridcomp({'list',...
    },...
    'uistring',uistring,...
    'gridsize',[1 1],'gridmargin',5,'hweight',1,'vweight',1);
% Axes to dislay MRI image;
handles.axes_mriimg = axes;
% Combobox control Axes view
uistring={icontext(handles.iconlist.action.view,'View'),...
{'X-Y','Y-Z','X-Z','Y-Z-in'},...
'',...
};
[container_view,~,handles.combobox_view,...
]=uigridcomp({'label','combobox','label',...
},...
'uistring',uistring,...
'gridsize',[1 3],'gridmargin',5,'hweight',[2 4 4],'vweight',1);
% List box to display current data;
uistring={'',...
    };
[container_matdata,handles.jlistbox_matdata,...
    ]=uigridcomp({'list',...
    },...
    'uistring',uistring,...
    'gridsize',[1 1],'gridmargin',5);
% Control buttons to save matdata
% Save matdata
uistring={icontext(handles.iconlist.action.delete,'Del'),...
    '',...
    icontext(handles.iconlist.action.save,'Save'),...
    };
[container_save,handles.pushbutton_del,~,handles.pushbutton_save,...
    ]=uigridcomp({'pushbutton','label',...
    'pushbutton'},...
    'uistring',uistring,...
    'gridsize',[1 3],'gridmargin',5,'hweight',[3 4 3]);
% Alignment
uialign(container_filelist,container_currdir,'align','southwest','scale',[1 8],'gap',[0 -gvar.margin.gap]);
uialign(handles.axes_mriimg,container_currdir,'align','east','scale',[2.1 8],'gap',[3*gvar.margin.gap 0]);
uialign(container_view, handles.axes_mriimg,'align','southwest','scale',[1 0.1],'gap',[0 -2*gvar.margin.gap]);
uialign(container_matdata,handles.axes_mriimg,'align','east','scale',[0.33 1],'gap',[gvar.margin.gap 0]);
uialign(container_save,container_matdata,'align','southwest','scale',[1 0.1],'gap',[0 -gvar.margin.gap]);
% Initialize
handles.mribound = struct;
handles.mribound.xy = [];
handles.mribound.yz = [];
handles.mribound.xz = [];
set(handles.combobox_currdir,'selectedindex',0); % Combobox currentdir
uijlist_setfiles(handles.jlistbox_filenameinput,get(handles.combobox_currdir,'selecteditem'),'type',{'.all'}); % List file in the current dir
set(handles.combobox_view,'selectedindex',0); % View Axes
handles.keyholder = '';
mrifile = 'standard_mri.mat';
handles.mripath = fullfile(eeglabdir,'plugins\dipfit2.3\standard_BEM',mrifile);
axes(handles.axes_mriimg);
show_mriimg('path',handles.mripath,'view','xy');
% Setappdata
setappdata(handles.figure,'handles',handles);
% Set callback
set(handles.pushbutton_updir,'Callback',{@pushbutton_updir_Callback,handles});
set(handles.pushbutton_del,'Callback',{@pushbutton_del_Callback,handles});
set(handles.pushbutton_save,'Callback',{@pushbutton_save_Callback,handles});
set(handles.pushbutton_del,'Callback',{@pushbutton_del_Callback,handles});
% combobox
set(handles.combobox_currdir,'ActionPerformedCallback',{@combobox_currdir_Callback,handles});
% Axes
set(handles.axes_mriimg,'ButtonDownFcn',{@axes_buttondown_Callback,handles});
% combobox viewpoint
set(handles.combobox_view,'ActionPerformedCallback',{@combobox_view_Callback,handles});
% jlistbox
set(handles.jlistbox_filenameinput,'MousePressedCallback',{@jlistbox_filenameinput_Mouse_Callback,handles});
set(handles.jlistbox_filenameinput,'KeyPressedCallback',{@KeyboardThread_Callback,handles});
set(handles.jlistbox_matdata,'MousePressedCallback',{@jlistbox_matdata_Mouse_Callback,handles});
% Keyboard thread 
set(handles.figure,'WindowKeyPressFcn',{@KeyboardThread_Callback,handles});

%=============
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

function combobox_view_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
selitem=get(hObject,'selecteditem');
cla(handles.axes_mriimg,'reset');
if strcmpi(selitem,'x-y')
    show_mriimg('path',handles.mripath,'view','xy');
elseif strcmpi(selitem,'y-z')
    show_mriimg('path',handles.mripath,'view','yz');
elseif strcmpi(selitem,'x-z')
    show_mriimg('path',handles.mripath,'view','xz');
end
jlistbox_matdata_load(handles);
jlistbox_matdata_show(handles);
setappdata(handles.figure,'handles',handles);

function jlistbox_filenameinput_Mouse_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
eventinf=get(eventdata);
if eventinf.Button==1 && eventinf.ClickCount==2 %double left click
    handles = jlistbox_filenameinput_load(hObject,handles);
elseif eventinf.Button==3       %Right Click
    handles.jmenu.show(hObject,eventinf.X,eventinf.Y);
    handles.itempos.x=eventinf.X;
    handles.itempos.y=eventinf.Y;
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
    handles.mribound = evalin('base','mribound');
    setappdata(handles.figure,'handles',handles);
    jlistbox_matdata_load(handles);
    jlistbox_matdata_show(handles);
else
end
fprintf('DONE...%s.\n',thisFuncName);
% Setappdata
setappdata(handles.figure,'handles',handles);

function jlistbox_matdata_Mouse_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUN:%s.\n',thisFuncName);
%====
jlistbox_matdata_show(handles);
%=====
fprintf('DONE:%s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

function handles = jlistbox_matdata_add(data,handles);
handles=getappdata(handles.figure,'handles');
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUN:%s.\n',thisFuncName);
%====
viewopt = get(handles.combobox_view,'selecteditem');
if strcmpi(viewopt,'x-y')
    updateddata = [handles.mribound.xy; data];    
    showdata = updateddata;
    handles.mribound.xy = updateddata;
elseif strcmpi(viewopt,'y-z')
    updateddata = [handles.mribound.yz; data];
    showdata = updateddata;
    handles.mribound.yz = updateddata;    
elseif strcmpi(viewopt,'x-z')
    updateddata = [handles.mribound.xz; data];
    showdata = updateddata;
    handles.mribound.xz = updateddata;
end
for i = 1 : size(showdata,1)
    currentdata{i}= sprintf('%.2f \t\t\t %.2f',showdata(i,1),showdata(i,2));
end
uisetjlistbox(handles.jlistbox_matdata,currentdata);
%=====
fprintf('DONE:%s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

function handles = jlistbox_matdata_load(handles);
handles=getappdata(handles.figure,'handles');
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUN:%s.\n',thisFuncName);
%====
viewopt = get(handles.combobox_view,'selecteditem');
if strcmpi(viewopt,'x-y')
    data = handles.mribound.xy;
elseif strcmpi(viewopt,'y-z')
    data = handles.mribound.yz;
elseif strcmpi(viewopt,'x-z')
    data = handles.mribound.xz;
end
if ~isempty(data)
    for i = 1 : size(data,1)
        currentdata{i}= sprintf('%.2f \t\t\t %.2f',data(i,1),data(i,2));
    end
    uisetjlistbox(handles.jlistbox_matdata,currentdata);
else
    uisetjlistbox(handles.jlistbox_matdata,{});
end
setappdata(handles.figure,'handles',handles);
%====
fprintf('DONE:%s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

function handles = pushbutton_save_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUN:%s.\n',thisFuncName);
%=====
currentdata = uigetjlistbox(handles.jlistbox_matdata,'select','all');
for i = 1 : length(currentdata)
    data(i,:) = str2num(currentdata{i});
end
%=====
mribound = handles.mribound;
currdir = get(handles.combobox_currdir,'selecteditem');
filename = uigetjlistbox(handles.jlistbox_filenameinput,'select','selected')
% myfile = class_FileIO('filedir',currdir,'filename',[mfilename,'_data'],'ext','.mat');
myfile = class_FileIO('filedir',currdir,'filename',filename{1},'ext','.mat');
myfile.savevars(mribound);
combobox_currdir_Callback(handles.combobox_currdir,[],handles);
%====
fprintf('DONE:%s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

function handles = pushbutton_del_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUN:%s.\n',thisFuncName);
%=====
viewopt = get(handles.combobox_view,'selecteditem');
selind = get(handles.jlistbox_matdata,'selectedindices')
if strcmpi(viewopt,'x-y')
    handles.mribound.xy(selind+1,:) = [];
elseif strcmpi(viewopt,'y-z')
    handles.mribound.yz(selind+1,:) = [];
elseif strcmpi(viewopt,'x-z')
    handles.mribound.xz(selind+1,:) = [];
end
setappdata(handles.figure,'handles',handles);
jlistbox_matdata_load(handles);
setappdata(handles.figure,'handles',handles);
jlistbox_matdata_show(handles);
%====
fprintf('DONE:%s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

function handles = jlistbox_matdata_show(handles)
handles=getappdata(handles.figure,'handles');
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUN:%s.\n',thisFuncName);
%=====
currentdata = uigetjlistbox(handles.jlistbox_matdata,'select','all');
data = [];
for i = 1 : length(currentdata)
    data(i,:) = str2num(currentdata{i});
end 
axes(handles.axes_mriimg);
% cla(gca,'reset');
% combobox_view_Callback(handles.combobox_view,[],handles);
if ~isempty(data)
    plot(data(:,1),data(:,2),'marker','o','color','r','markerfacecolor','r');
end
selecteditem = handles.jlistbox_matdata.getSelectedValues;
if ~isempty(selecteditem)
    selecteditems = uigetjlistbox(handles.jlistbox_matdata,'select','selected');
    for i = 1 : length(selecteditems)
        data = str2num(selecteditems{i});
        plot(data(:,1),data(:,2),'marker','o','markerfacecolor','g');
    end
end
%=====
fprintf('DONE:%s.\n',thisFuncName);
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
fprintf('KeyPressed: %s\n',key);
% Go to component;
if strcmpi(handles.keyholder,'g')    
elseif strcmpi(handles.keyholder,'shift')    
elseif strcmpi(handles.keyholder,'ctrl') || strcmpi(handles.keyholder,'control') && strcmpi(key,'s')    
else
    if (strcmpi(key,'return') || strcmpi(key,'enter'))        
    elseif strcmpi(key,'uparrow') || strcmpi(key,'downarrow')     
    elseif strcmpi(key,'up') || strcmpi(key,'down')        
    elseif strcmpi(key,'left')        
    elseif strcmpi(key,'right')        
    elseif strcmpi(key,'space')    
        [data(1), data(2)] = ginput(1);
        handles = jlistbox_matdata_add(data,handles);
        handles = jlistbox_matdata_show(handles)
    elseif strcmpi(key,'a')                    
    elseif strcmpi(key,'s')         
    elseif strcmpi(key,'d')         
    elseif strcmpi(key,'f')         
    elseif strcmpi(key,'r')         
    elseif strcmpi(key,'e')         
    elseif strcmpi(key,'x') || strcmpi(key,'delete') && hObject == handles.jlistbox_matdata        
    elseif strcmpi(key,'f1')        
    end
end
handles.keyholder = ''; % reset keyholder;
setappdata(handles.figure,'handles',handles);

function handles = axes_buttondown_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING...%s.\n',thisFuncName);
%=====
% [mousex, mousey] = ginput(1)
fprintf('DONE...%s.\n',thisFuncName);
% Setappdata
setappdata(handles.figure,'handles',handles);

function show_mriimg(varargin)
viewopt = get_varargin(varargin,'view','xy');
mripath = get_varargin(varargin,'path','C:\');
mridata = load(mripath);
mri = mridata.mri;
dat.imgs = mri.anatomy;
dat.imgcoords = {mri.xgrid mri.ygrid mri.zgrid };
dat.maxcoord  = [max(dat.imgcoords{1}) max(dat.imgcoords{2}) max(dat.imgcoords{3})];
% dat.zeroloc = [ xx yy zz ];
dat.transform = mri.transform;
dat.axistight = 1;
dat.cornermri = 0;
dat.drawedges = 'off';
[xx yy zz] = transform(0,0,0, pinv(dat.transform)); % elec -> MRI space
indx = minpos(dat.imgcoords{1}-zz);
indy = minpos(dat.imgcoords{2}-yy);
indz = minpos(dat.imgcoords{3}-xx);
plotimgs( dat,min(max([indx indy indz],1),size(dat.imgs)), dat.transform,'view',viewopt);

function plotimgs(dat, mricoord, transmat,varargin);
% loading images
% --------------
viewopt = get_varargin(varargin,'view','xy');
if ndims(dat.imgs) == 4 % true color data
    img1(:,:,3) = rot90(squeeze(dat.imgs(mricoord(1),:,:,3)));
    img2(:,:,3) = rot90(squeeze(dat.imgs(:,mricoord(2),:,3)));
    img3(:,:,3) = rot90(squeeze(dat.imgs(:,:,mricoord(3),3)));
    img1(:,:,2) = rot90(squeeze(dat.imgs(mricoord(1),:,:,2)));
    img2(:,:,2) = rot90(squeeze(dat.imgs(:,mricoord(2),:,2)));
    img3(:,:,2) = rot90(squeeze(dat.imgs(:,:,mricoord(3),2)));
    img1(:,:,1) = rot90(squeeze(dat.imgs(mricoord(1),:,:,1)));
    img2(:,:,1) = rot90(squeeze(dat.imgs(:,mricoord(2),:,1)));
    img3(:,:,1) = rot90(squeeze(dat.imgs(:,:,mricoord(3),1)));
else
    img1 = rot90(squeeze(dat.imgs(mricoord(1),:,:)));
    img2 = rot90(squeeze(dat.imgs(:,mricoord(2),:)));
    img3 = rot90(squeeze(dat.imgs(:,:,mricoord(3))));
    
    if ndims(img1) == 2, img1(:,:,3) = img1; img1(:,:,2) = img1(:,:,1); end;
    if ndims(img2) == 2, img2(:,:,3) = img2; img2(:,:,2) = img2(:,:,1); end;
    if ndims(img3) == 2, img3(:,:,3) = img3; img3(:,:,2) = img3(:,:,1); end;
end;

% computing coordinates for planes
% --------------------------------
wy1 = [min(dat.imgcoords{2}) max(dat.imgcoords{2}); min(dat.imgcoords{2}) max(dat.imgcoords{2})];
wz1 = [min(dat.imgcoords{3}) min(dat.imgcoords{3}); max(dat.imgcoords{3}) max(dat.imgcoords{3})];
wx2 = [min(dat.imgcoords{1}) max(dat.imgcoords{1}); min(dat.imgcoords{1}) max(dat.imgcoords{1})];
wz2 = [min(dat.imgcoords{3}) min(dat.imgcoords{3}); max(dat.imgcoords{3}) max(dat.imgcoords{3})];
wx3 = [min(dat.imgcoords{1}) max(dat.imgcoords{1}); min(dat.imgcoords{1}) max(dat.imgcoords{1})];
wy3 = [min(dat.imgcoords{2}) min(dat.imgcoords{2}); max(dat.imgcoords{2}) max(dat.imgcoords{2})];
if dat.axistight & ~dat.cornermri
    wx1 = [ 1 1; 1 1]*dat.imgcoords{1}(mricoord(1));
    wy2 = [ 1 1; 1 1]*dat.imgcoords{2}(mricoord(2));
    wz3 = [ 1 1; 1 1]*dat.imgcoords{3}(mricoord(3));
else
    wx1 =  [ 1 1; 1 1]*dat.imgcoords{1}(1);
    wy2 =  [ 1 1; 1 1]*dat.imgcoords{2}(end);
    wz3 =  [ 1 1; 1 1]*dat.imgcoords{3}(1);
end;
% transform MRI coordinates to electrode space
% --------------------------------------------
[ elecwx1 elecwy1 elecwz1 ] = transform( wx1, wy1, wz1, transmat);
[ elecwx2 elecwy2 elecwz2 ] = transform( wx2, wy2, wz2, transmat);
[ elecwx3 elecwy3 elecwz3 ] = transform( wx3, wy3, wz3, transmat);
% ploting surfaces
% ----------------
options = { 'FaceColor','texturemap', 'EdgeColor','none', 'CDataMapping', ...
    'direct','tag','img', 'facelighting', 'none' };
hold on;
if strcmpi(viewopt,'yz')
%     surface(elecwx3, elecwy3, zeros(size(elecwz3)), img1(end:-1:1,:,:), options{:});axis equal;
    surface(elecwy1, elecwz1, [0 0; 0 0], img1(end:-1:1,:,:), options{:});axis equal;
elseif strcmpi(viewopt,'xz')
    %     surface(elecwx3, elecwy3, zeros(size(elecwz3)), img2(end:-1:1,:,:), options{:});axis equal;
    surface(elecwx2, elecwz2, [0 0; 0 0], img2(end:-1:1,:,:), options{:});axis equal;
elseif strcmpi(viewopt,'xy')
    surface(elecwx3, elecwy3, [0 0; 0 0], img3(end:-1:1,:,:), options{:});axis equal;
end
dlim = [-120 120];
set(gca,'xlim',dlim,'ylim',dlim,'zlim',dlim)

function [x,y,z] = transform(x, y, z, transmat);

if isempty(transmat), return; end;
for i = 1:size(x,1)
    for j = 1:size(x,2)
        tmparray = transmat * [ x(i,j) y(i,j) z(i,j) 1 ]';
        x(i,j) = tmparray(1);
        y(i,j) = tmparray(2);
        z(i,j) = tmparray(3);
    end;
end;

function index = minpos(vals);
vals(find(vals < 0)) = inf;
[tmp index] = min(vals);

function show_dipole(varargin)
viewopt = get_varargin(varargin,'view','xy');
mripath = get_varargin(varargin,'path','C:\');
sources(1).posxyz = [-59 48 -28];   % position for the first dipole
sources(1).momxyz = [  0 58 -69];   % orientation for the first dipole
sources(1).rv     = 0.036;          % residual variance for the first dipole
try
    dipplot(sources,'mri',mripath,'summary','off','num','off','verbose','off','gui','off','color',{'k'},...
        'drawedges','off');
    if strcmpi(viewopt,'xy')
        view([0 90]); % X Y view
    elseif strcmpi(viewopt,'yz')
        view([90 0]); % Y Z view
    elseif strcmpi(viewopt,'xz')
        view([0 0]); % X Z view
    end
    axis equal;
    rotate3d off;
catch
    uh_fprintf('Invalid MRI path or EEGLAB is not initiated.\','color','r');
end
