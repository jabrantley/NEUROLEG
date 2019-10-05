function shortcut = uh_shortcut
% Note: cd to directory contains this file in shortcut function. 
% [~,PCname]=system('hostname');
% % last char is a space;
% PCname(isspace(PCname))=[];
% if strcmpi(PCname,'PhatLuu-DellPC')
%     onedrive='C:\Users\phat\OneDrive';        
% else
%     onedrive='C:\Users\ptluu2\OneDrive';        
% end
% addpath(genpath([onedrive '\UH-research\Avatar Data Analysis\matlabcode\uhlib']));
mydir = uh_settings.class_dir;
addpath(mydir.eeglab);
addpath(mydir.fieldtrip);

shortcut.closeall=@shortcut_closeall;
shortcut.print=@shortcut_print;
shortcut.UHBMIGUI=@shortcut_UHBMIGUI;
shortcut.openfigdir=@shortcut_openfigdir;
shortcut.openrootdir=@shortcut_openrootdir;

function shortcut_closeall
% Shortcut summary goes here    
allfig=findall(0,'type','figure');
printfig=findall(0, '-depth',1, 'type','figure', 'Name','GUIAVATAR_Print');
if ~isempty (printfig)
    clcfig=setdiff(allfig,printfig);
else
    clcfig=allfig;
end
printfig=findall(0, '-depth',1, 'type','figure', 'Name','UHBMI_AVATARGUI');
if ~isempty (printfig)
    clcfig=setdiff(allfig,printfig);
else 
    clcfig=allfig;
end
close(clcfig);
fprintf('DONE: All figures have been closed.\n');

function shortcut_print
global settings;
strcmd=sprintf('cd ''%s''',settings.dir.myroot);
eval(strcmd);
shortcut_addpath;
%==
% Shortcut summary goes here
close all;
GUIAVATAR_Print;

function shortcut_UHBMIGUI
strcmd=sprintf('cd ''%s''',settings.dir.myroot);
eval(strcmd);
%Shortcut summary goes here
clear all; clc;close all;
%==
UHBMI_AVATARGUI;


function shortcut_openfigdir
mydir = uh_settings.class_dir;
% Shortcut summary goes here
strcmd=sprintf('winopen(''%s'')',mydir.figdir);
eval(strcmd);

function shortcut_openrootdir
mydir = uh_settings.class_dir;
strcmd=sprintf('cd ''%s''',mydir.root);
eval(strcmd);
% Shortcut summary goes here
strcmd=sprintf('winopen(''%s'')',mydir.root);
eval(strcmd);