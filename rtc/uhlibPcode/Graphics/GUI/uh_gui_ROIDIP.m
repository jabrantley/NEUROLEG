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
% 
function uh_gui_ROIDIP(varargin)
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
% Debug; 
clc; close all;
mfilepath = mfilename('fullpath'); 
[filedir, filename, ~] = fileparts(mfilepath); 
%====STEP 1: FRAME======================================================== 
handles.iconlist=getmatlabicons; 
% Create a new figure 
[handles.figure, handles.jstatusbarhdl,handles.jwaitbarhdl]=uh_uiframe('figname',mfilename,... 
'units','norm','position',[1.1 0.3 0.75 0.75],... 
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
    {'F:\OneDrive\UH-PROJECT-NEUROLEG\PROCESS DATA_DIPROI',...
    cd,filedir,'C:\','P:\MatlabCode\uhlib','P:\Dropbox\LTP_Publication',...
    'D:\OneDrive','D:\OneDrive\UH-PROJECT-NEUROLEG'},...
    icontext(handles.iconlist.action.newfolder,''),...
    };
w=0.3-gvar.margin.gap; h=0.08;
[container_currdir,handles.pushbutton_updir,handles.combobox_currdir,handles.pushbutton_newdir,...     
]=uigridcomp({'pushbutton','combobox','pushbutton',...     
},... 
'uistring',uistring,... 
'position',[gvar.margin.l 1-gvar.margin.l-h w h],... 
'gridsize',[1 3],'gridmargin',5,'hweight',[1 8 1],'vweight',1); 
% Listbox for file list 
uistring={'','','','',...     
}; 
[container_filelist,handles.jlistbox_filenameinput,...
    handles.jlistbox_alldip,...
    ~,...
    handles.jlistbox_rejdip] = uigridcomp({'list','list','label','list'},...
    'uistring',uistring,...
    'gridsize',[4 1],'gridmargin',5,'hweight',1,'vweight',[2 5 1 2]);
% Pushbutton for moving DIP and SAVE
uistring={'',...
    icontext(handles.iconlist.arrowdown,''),...
    icontext(handles.iconlist.arrowup,''),...
    icontext(handles.iconlist.action.save,'SAVE'),...
    };
[container_dipbutton,~,...
    handles.pushbutton_movedipdown,...
    handles.pushbutton_movedipup,...
    handles.pushbutton_savedip,...
    ]=uigridcomp({'label','pushbutton','pushbutton','pushbutton',...
    },...
    'uistring',uistring,...
    'gridsize',[1 4],'gridmargin',10,'hweight',[3 2 2 3],'vweight',1);
% Axes
handles.axclass = class_axes('gridsize',[1 2 1],'position',[0.3 0.4 0.68 0.58],'widthratio',[1 1],'gapw',0.03,'gaph',0.1,'show',1);
axclass = class_axes('gridsize',[1 1 1],'show',0);
axes(handles.axclass.myax(1,2));
axclass.align_axes('reference',gca,'align','northeastinside','scale',0.5);
handles.axes.topoplot = axclass.myax;
axclass = class_axes('gridsize',[2 1 1],'heightratio',[0.4 0.6],'show',0);
axclass.align_axes('reference',handles.axclass,'align','southleft','scale',[0.95 0.75],'gap',[0.03 0.06]);
handles.axes.bandplot = axclass.myax(1);
handles.axes.specplot = axclass.myax(2);

% Alignment 
uialign(container_filelist,container_currdir,'align','southwest','scale',[1 10.5],'gap',[0 -gvar.margin.gap]); 
uialign(container_dipbutton,container_currdir,'align','southwest','scale',[1 0.9],'gap',[0 -59*gvar.margin.gap]); 
% Initialize 
set(handles.combobox_currdir,'selectedindex',0); 
uijlist_setfiles(handles.jlistbox_filenameinput,get(handles.combobox_currdir,'selecteditem'),...
    'type',{'.mat'},'search',{'BA'},'sort','descend'); 
handles.keyholder = ''; 
% Set callback 
% Keyboar thread 
set(handles.figure,'WindowKeyPressFcn',{@KeyboardThread_Callback,handles}); 
% Pushbutton 
set(handles.pushbutton_updir,'Callback',{@pushbutton_updir_Callback,handles}); 
set(handles.pushbutton_movedipdown,'Callback',{@pushbutton_movedipdown_Callback,handles}); 
set(handles.pushbutton_movedipup,'Callback',{@pushbutton_movedipup_Callback,handles}); 
set(handles.pushbutton_savedip,'Callback',{@pushbutton_savedip_Callback,handles}); 
% combobox 
set(handles.combobox_currdir,'ActionPerformedCallback',{@combobox_currdir_Callback,handles}); 
% jlistbox 
set(handles.jlistbox_filenameinput,'MousePressedCallback',{@jlistbox_filenameinput_Mouse_Callback,handles}); 
set(handles.jlistbox_filenameinput,'KeyPressedCallback',{@KeyboardThread_Callback,handles}); 
set(handles.jlistbox_alldip,'MousePressedCallback',{@jlistbox_alldip_Mouse_Callback,handles}); 
set(handles.jlistbox_alldip,'KeyPressedCallback',{@jlistbox_alldip_Keyboard_Callback,handles}); 
set(handles.jlistbox_rejdip,'MousePressedCallback',{@jlistbox_rejdip_Mouse_Callback,handles}); 
% Setappdata 
setappdata(handles.figure,'handles',handles); 
%============= 
 
function pushbutton_updir_Callback(hObject,eventdata,handles) 
handles=getappdata(handles.figure,'handles'); 
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
setappdata(handles.figure,'handles',handles); 
 
function pushbutton_movedipdown_Callback(hObject,eventdata,handles) 
handles=getappdata(handles.figure,'handles'); 
currdip = getdipID(handles);
seldip= getdipID(handles,'select','selected');
rejdiplist = getdipID(handles,'hObject',handles.jlistbox_rejdip);
selindices = get(handles.jlistbox_alldip,'selectedindices');
% Update list
uisetjlistbox(handles.jlistbox_alldip,model2list(handles.BAcluster,sort(setdiff(currdip,seldip))));
uisetjlistbox(handles.jlistbox_rejdip,model2list(handles.BAcluster,sort([rejdiplist, seldip])));
try
    set(handles.jlistbox_alldip,'selectedindex',selindices(1));
catch
     set(handles.jlistbox_alldip,'selectedindex',0);
end
set(handles.jlistbox_rejdip,'selectedindex',length([rejdiplist,seldip])-1);
setappdata(handles.figure,'handles',handles); 

function pushbutton_movedipup_Callback(hObject,eventdata,handles) 
handles=getappdata(handles.figure,'handles'); 
currdip = getdipID(handles);

rejdiplist = getdipID(handles,'hObject',handles.jlistbox_rejdip);
selrejdip= getdipID(handles,'hObject',handles.jlistbox_rejdip,'select','selected');
% Update list
uisetjlistbox(handles.jlistbox_alldip,model2list(handles.BAcluster,sort([currdip,selrejdip])));
uisetjlistbox(handles.jlistbox_rejdip,model2list(handles.BAcluster,sort(setdiff(rejdiplist,selrejdip))));
setappdata(handles.figure,'handles',handles); 

function pushbutton_savedip_Callback(hObject,eventdata,handles) 
handles = getappdata(handles.figure,'handles'); 
currdir = get(handles.combobox_currdir,'selectedItem')
filename = html2item(get(handles.jlistbox_filenameinput,'SelectedValue'));
currdip = getdipID(handles);
rejdiplist = getdipID(handles,'hObject',handles.jlistbox_rejdip);
BAcluster = handles.BAcluster;
for i = 1 : length(BAcluster.model)
    if any(currdip == i), BAcluster.model(i).isKeep = 1;
    else, BAcluster.model(i).isKeep = 0;
    end
end
myFile = class_FileIO('filename',filename,'filedir',currdir);
myFile.savevars(BAcluster);
assignin('base','BAcluster',BAcluster);
% prompt = {'Enter Filename:'};
% dlg_title = 'Save';
% num_lines = 1;
% defaultans = {sprintf('%s-copy.mat',filename)};
% answer = inputdlg(prompt,dlg_title,num_lines,defaultans,[1 50]);
setappdata(handles.figure,'handles',handles); 

function jlistbox_filenameinput_Mouse_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
handles=getappdata(handles.figure,'handles'); 
eventinf=get(eventdata);
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
        % Load data to dip list
        fprintf('Load..%s\n',myfile.fullfilename);
        matinfo = matfile(myfile.fullfilename);
%         try
            BAcluster = matinfo.BAcluster;
            if isfield(BAcluster.model,'isKeep')
                keeplist = find([BAcluster.model.isKeep] == 1);
                rejlist = find([BAcluster.model.isKeep] == 0);
                uisetjlistbox(handles.jlistbox_alldip,model2list(BAcluster,keeplist));
                uisetjlistbox(handles.jlistbox_rejdip,model2list(BAcluster,rejlist));
            else
                uisetjlistbox(handles.jlistbox_alldip,model2list(BAcluster,1:length(BAcluster.model)));
            end
            handles.BAcluster = BAcluster;
%         catch
%             fprintf('Not exist.\n');
%         end
    else
    end
end
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

function diplist = model2list(BAcluster,IDlist)
diplist = {};
for k = 1:length(IDlist)
    i = IDlist(k);
    diplist{k} = sprintf('%04d  -  X:%02d, Y:%02d, Z:%02d  -  %s',...
        BAcluster.model(i).dipID,...
        round(BAcluster.model(i).posxyz(1)),round(BAcluster.model(i).posxyz(2)),round(BAcluster.model(i).posxyz(3)),...
        BAcluster.model(i).filename);
end

function jlistbox_alldip_Mouse_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
setappdata(handles.figure,'handles',handles)

function jlistbox_rejdip_Mouse_Callback(hObject,eventdata,handles)
handles=getappdata(handles.figure,'handles');
setappdata(handles.figure,'handles',handles)

function jlistbox_alldip_Keyboard_Callback(hObject,eventdata,handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
handles=getappdata(handles.figure,'handles');
if isprop(eventdata,'Key')
    key = lower(eventdata.Key); % Matlab component; Ctrl: 'control'
else
    key = lower(char(eventdata.getKeyText(eventdata.getKeyCode)));    % Java component;
end
if any(~cellfun('isempty',strfind({'right','space'},key)));
    guiUpdate(handles,'dipplot',1,'psdplot',1,'topoplot',1,'specplot',1);    
end
if any(~cellfun('isempty',strfind({'delete','d','numpad-0'},key)))
    pushbutton_movedipdown_Callback(handles.pushbutton_movedipdown,[],handles);
    hObject.requestFocus;
end
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles)

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
setappdata(handles.figure,'handles',handles); 
 
function handles = uimenubar(handles) 
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
% + SubGUI
% + Help 
jMenuFile=JMenu('File'); 
jMenuBar.add(jMenuFile); % Add to jMenuBar 
jMenuFile_New = JMenu('New'); 
jMenuFile.add(jMenuFile_New); % Add to jMenuFile 
jMenuFile_New_Type1 = JMenuItem('Type 1...',ImageIcon(icons.file.m)); 
jMenuFile_New.add(jMenuFile_New_Type1); 
jMenuFile_Open = javax.swing.JMenuItem('Open...',ImageIcon(icons.action.open)); 
jMenuFile.add(jMenuFile_Open); 

% subGUI Menu
jMenusubgui = JMenu('subGUI'); 
jMenuBar.add(jMenusubgui); 
jMenusubgui_print = JMenuItem('Print',ImageIcon(icons.action.print)); 
jMenusubgui.add(jMenusubgui_print); 
jMenuBar.setPreferredSize(Dimension(100,28)); 
jMenuBar.setBackground(Color.white); 
handles.jMenuBar=jMenuBar; 

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
% print menu
hjMenusubgui_print = handle(jMenusubgui_print,'CallbackProperties'); 
set(hjMenusubgui_print,'ActionPerformedCallback',{@jMenusubgui_print_Callback,handles}); 
% Help 
hjMenuHelp_Doc = handle(jMenuHelp_Doc,'CallbackProperties'); 
set(hjMenuHelp_Doc,'ActionPerformedCallback',{@jMenuHelp_Doc_Callback,handles}); 

javacomponent(jMenuBar,'North',handles.figure);

function jMenusubgui_print_Callback(hObject, eventdata, handles)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
global gvar;
handles=getappdata(handles.figure,'handles');
% DEFINE
wintime = 3; % 3secs before and after event time
srate = handles.BAcluster.model(1).srate;
% GUI input
currdir = get(handles.combobox_currdir,'selecteditem');
currdip = getdipID(handles);
seldip = getdipID(handles,'select','selected');
% Raw activation
if uh_isvarexist('currdipAct')
    currdipAct = evalin('base','currdipAct');
else
    currdipAct = [];
    for i = 1 : length(currdip)
        fprintf('Loading selected IC act:%d - %d/%d. \n',currdip(i),i,length(currdip));
        inputfile = class_FileIO('filedir',currdir,'filename',handles.BAcluster.model(currdip(i)).filename);
        thisICact = handles.BAcluster.model(currdip(i)).ICact;
        timeline = linspace(0,length(thisICact)/srate,length(thisICact));
        transtime = getTranstime(inputfile);
        for j = 1 : length(transtime)
            markerpos = uh_getmarkerpos(transtime(j),timeline);
            windowpos = markerpos-wintime*srate:markerpos+wintime*srate;
            currdipAct = [currdipAct; thisICact(windowpos)];
        end
    end
    assignin('base','currdipAct',currdipAct);
end
% figure;
% for i = 1 : size(currdipAct,1)
%     plot(currdipAct(i,:)); hold on
% end
% plot(mean(currdipAct,1),'r','linewidth',1.5)
% line('xdata',wintime*srate*[1 1],'ydata',get(gca,'ylim'),'color','k','linestyle','--');
% thisICact = handles.BAcluster.model(seldip).ICact;
% % Filter to betaband
% betaact = uh_filter(thisICact,'fs',handles.BAcluster.model(seldip).srate,...
%     'cutoff',gvar.beta,'order',4,'method','filtfilt');
% axes(handles.axes.bandplot);
% cla(gca,'reset');
% ictimeline = linspace(0,length(thisICact)/handles.BAcluster.model(seldip).srate,length(thisICact));
% betaSquared = abs(betaact);
% betaEnvelop = uh_filter(betaSquared,'fs',handles.BAcluster.model(seldip).srate,...
%     'cutoff',6,'order',4,'type','low','method','filtfilt');
% plot(ictimeline,thisICact,'k');  hold on;
% plot(ictimeline,betaact,'b');
% plot(ictimeline,betaEnvelop,'r');
% for i = 1 : length(transtime)
%     line('xdata',transtime(i).*[1 1],'ydata',get(gca,'ylim'),'color','r','linewidth',0.75);
% end
% set(gca,'xlim',[ictimeline(1) ictimeline(end)],...
%     'ylim',[mean(thisICact) - 3*std(thisICact), mean(thisICact) + 3*std(thisICact)])
% Output
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);


function dipIDlist = getdipID(handles,varargin)
selectopt = get_varargin(varargin,'select','all');
hObject = get_varargin(varargin,'hObject',handles.jlistbox_alldip);
celllist = uigetjlistbox(hObject,'select',selectopt);
dipIDlist = [];
for i = 1 : length(celllist)
    thisrow = celllist{i};
    cellstrs = strsplit(thisrow,'-');    
    dipIDlist(i) = str2num(cellstrs{1});
end

function guiUpdate(handles,varargin)
[stacktrace, ~]=dbstack;
thisFuncName=stacktrace(1).name;
fprintf('RUNNING: %s.\n',thisFuncName);
global gvar;
handles=getappdata(handles.figure,'handles'); 
% Parser input
dipopt = get_varargin(varargin,'dipplot',0);
topopopt = get_varargin(varargin,'topoplot',0);
psdopt = get_varargin(varargin,'psdplot',0);
specopt = get_varargin(varargin,'specplot',0);
% GUI input
currdip = getdipID(handles);
seldip = getdipID(handles,'select','selected');
rejdip = getdipID(handles,'hObject',handles.jlistbox_rejdip);
selrejdip = getdipID(handles,'hObject',handles.jlistbox_rejdip,'select','selected');
% Update plot
if dipopt == 1    
    axes(handles.axclass.myax(1,1,1))
    cla(gca,'reset');    
    dipcolor = repmat({'y'},1,length(currdip));
    dipcolor(seldip) = {'g'};
    % dipcolor(rejdip) = {'b'};
    % dipcolor(selrejdip) = {'r'};
    axes(handles.axclass.myax(1,1,1));
    cla(gca,'reset');
    set(gca,'color','none')
    dipplot(handles.BAcluster.model(seldip),'mri',handles.BAcluster.mrifile,...
        'dipolelength',0.01,'dipolesize',20,'color',{'r'},...
        'summary','off','num','on','verbose','off','gui','off','holdon','off');
    set(gcf,'color','w')
    view(0,0)
end
if psdopt == 1
    axes(handles.axclass.myax(2)); hold on;
    cla(gca,'reset');
    if uh_isvarexist('dipspecdB')
        dipspecdB = evalin('base','dipspecdB');
        freqs = evalin('base','freqs');
    else
        for i = 1: length(handles.BAcluster.model)
            [dipspecdB(i,:),freqs] = spectopo(handles.BAcluster.model(i).ICact,...
                0,100,'plot','off');
        end
        assignin('base','dipspecdB',dipspecdB)
        assignin('base','freqs',freqs)
    end    
    for i = 1 : length(currdip)
        plot(freqs,dipspecdB(currdip(i),:),'color',gvar.mycolor.grey); hold on;
    end
    cmapcolor = jet(length(seldip));
    for i = 1 : length(seldip)
        plot(freqs,dipspecdB(seldip(i),:),'color',cmapcolor(i,:));
        text(freqs(10),dipspecdB(seldip(i),10),sprintf('%d',seldip(i)),'color','b');
    end
    plot(freqs,mean(dipspecdB(currdip,:),1),'r','linewidth',1.25);
    set(gca,'ylim',[-40 20]);
    ylabel('Log Power Spectral Density 10*log_{10}(\muV^{2}/Hz)')
    xlabel('Freq (Hz)')
    text(25,-35,sprintf('Number of ICs: %d',length(currdip)),...
        'horizontalalignment','center',...
        'verticalalignment','top');
    box off;
end
if topopopt == 1   
    if length(seldip) == 1
        axes(handles.axes.topoplot)
        cla(gca,'reset');
        topoplot(handles.BAcluster.model(seldip).icawinv,handles.BAcluster.model(seldip).chanlocs,...
            'verbose','off','style','fill','chaninfo',...
            handles.BAcluster.model(seldip).chaninfo,'numcontour',8,'nosedir','+Y')
    end
end
if specopt == 1
    if length(seldip) == 1
        axes(handles.axes.specplot);
        cla(gca,'reset');
        winsize = 50; stepsize = 1; Fs = handles.BAcluster.model(seldip).srate;
        if uh_isvarexist('cluspsdpower')
            clusf = evalin('base','clusf');
            clustimeline = evalin('base','clustimeline');
            cluspsdpower = evalin('base','cluspsdpower');
        else
            for i = 1 : length(handles.BAcluster.model)
                fprintf('Loading spectrogram to WS dip: %d/%d.\n',i,length(handles.BAcluster.model));
                thisICact = handles.BAcluster.model(i).ICact;
                [~,clusf{i},clustimeline{i},cluspsdpower{i}] = spectrogram(thisICact,winsize,winsize-stepsize,2^(nextpow2(winsize)),Fs);
                assignin('base','clusf',clusf);
                assignin('base','clustimeline',clustimeline);
                assignin('base','cluspsdpower',cluspsdpower);
            end
        end
        f = clusf{seldip};
        timeline = clustimeline{seldip};
        psdpower = cluspsdpower{seldip};
        
        limc = [-80 10];
        uh_plot_ersp(db(psdpower),'xlim',[timeline(1) timeline(end)],'ylim',[f(1), f(end)],'clim',limc);
        % Find the transition event from LW to SA.
        currdir = get(handles.combobox_currdir,'selecteditem');
        inputfile = class_FileIO('filedir',currdir,'filename',handles.BAcluster.model(seldip).filename);
        transtime = getTranstime(inputfile);
        for i = 1 : length(transtime)
            line('xdata',transtime(i).*[1 1],'ydata',get(gca,'ylim'),'color','r','linewidth',1.25);
        end
        % Plot beta band limit
        for i = 1 : 2
            line('xdata',get(gca,'xlim'),'ydata',gvar.beta(i).*[1 1],'color','r','linestyle','--');
        end
        % Annotation
        % Colorbar;
        xbar = double(timeline(end))+5; ybar = 25; wbar = 3; hbar = 50;
        myrect = class_rectangle('center',class_point('xdata',xbar,'ydata',ybar),'width',wbar,'height',hbar);
        set(myrect,'facecolor','interp','cdata',[limc(1) limc(2) limc(2) limc(1)]);
        myrect.drawshape;
        class_text('xdata',xbar+wbar/2+1,'ydata',ybar+hbar/2+5,'string','dB','horizontalalignment','center','fontweight','bold','show',1);
        class_text('xdata',xbar+wbar/2+1,'ydata',ybar+hbar/2,'string',num2str(limc(2)),'horizontalalignment','left','show',1);
        class_text('xdata',xbar+wbar/2+1,'ydata',ybar,'string','0','horizontalalignment','left','fontweight','bold','show',1);
        class_text('xdata',xbar+wbar/2+1,'ydata',ybar-hbar/2,'string',[num2str(limc(1))],'horizontalalignment','left','show',1);
        xlabel('Time (s)');
        ylabel('Frequency (Hz)');
        
        % betaband plot
%         bandpos = uh_getmarkerpos(gvar.beta,f);
%         dbpower = db(psdpower);
%         bandpower = mean(dbpower(bandpos,:),1);
%         axes(handles.axes.bandplot);
%         cla(gca,'reset');
%         plot(timeline,bandpower,'r');
%         set(gca,'xlim',[timeline(1) timeline(end)])
        
        % Beta power envelop;
        % Raw activation
        thisICact = handles.BAcluster.model(seldip).ICact;
        % Filter to betaband
        betaact = uh_filter(thisICact,'fs',handles.BAcluster.model(seldip).srate,...
            'cutoff',gvar.beta,'order',4,'method','filtfilt');
        axes(handles.axes.bandplot);
        cla(gca,'reset');
        ictimeline = linspace(0,length(thisICact)/handles.BAcluster.model(seldip).srate,length(thisICact));
        betaSquared = abs(betaact);
        betaEnvelop = uh_filter(betaSquared,'fs',handles.BAcluster.model(seldip).srate,...
            'cutoff',6,'order',4,'type','low','method','filtfilt');
        plot(ictimeline,thisICact,'k');  hold on;
        plot(ictimeline,betaact,'b');        
        plot(ictimeline,betaEnvelop,'r');
        for i = 1 : length(transtime)
            line('xdata',transtime(i).*[1 1],'ydata',get(gca,'ylim'),'color','r','linewidth',0.75);
        end
        set(gca,'xlim',[ictimeline(1) ictimeline(end)],...
            'ylim',[mean(thisICact) - 3*std(thisICact), mean(thisICact) + 3*std(thisICact)])
        
    end
end
% Output
fprintf('DONE: %s.\n',thisFuncName);
setappdata(handles.figure,'handles',handles);

function transtime = getTranstime(inputfile)
eegfilename = inputfile.filename;
iden = strfind(eegfilename,'-eeg');
eegfilename(iden:end) = [];
kinfilename = fullfile(inputfile.filedir,[eegfilename, '-kin.mat']);
kinmatfile = matfile(kinfilename);
kin = kinmatfile.kin;
gc = kin.gc;
label = gc.label; gctime = gc.time;
transleg = gc.transleg;
% find SA
saidx = find(cellfun(@isempty,strfind(label,'SA')) == 0);
sabreak = find(diff(saidx)>2);
firstSA = saidx([1 sabreak+1]);
firstSAgctime = gctime(firstSA,:);
transtime = [];
for i = 1 : size(firstSAgctime,1)
    if i == 1
        if strcmpi(transleg{1},'R'), transtime(i) = firstSAgctime(i,1);
        else,transtime(i) = firstSAgctime(i,3);
        end
    elseif i == 2
        if strcmpi(transleg{5},'R'), transtime(i) = firstSAgctime(i,1);
        else,transtime(i) = firstSAgctime(i,3);
        end
    end    
end