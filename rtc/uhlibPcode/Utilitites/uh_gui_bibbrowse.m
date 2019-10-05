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
function uh_gui_bibbrowse(varargin)
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
handles.keyholder = ''; 
% Setappdata 
setappdata(handles.figure,'handles',handles); 
% Set callback 
set(handles.pushbutton_updir,'Callback',{@pushbutton_updir_Callback,handles}); 
% combobox 
set(handles.combobox_currdir,'ActionPerformedCallback',{@combobox_currdir_Callback,handles}); 
% jlistbox 
set(handles.jlistbox_filenameinput,'MousePressedCallback',{@jlistbox_filenameinput_Mouse_Callback,handles}); 
set(handles.jlistbox_filenameinput,'KeyPressedCallback',{@KeyboardThread_Callback,handles}); 
%============= 
function pushbutton_updir_Callback(hObject,eventdata,handles) 
handles=getappdata(handles.figure,'handles'); 
 
setappdata(handles.figure,'handles',handles); 
