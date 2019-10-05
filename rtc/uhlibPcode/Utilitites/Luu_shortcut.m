function Luu_shortcut
% Lab PC
% Close Fig shortcut% Shortcut summary goes here
allfig=findall(0,'type','figure');
printfig=findall(0, '-depth',1, 'type','figure', 'Name','UHBMIGUI_PRINT');
avatarfig=findall(0, '-depth',1, 'type','figure', 'Name','UHBMIGUI_AVATAR');
clcfig=setdiff(allfig,[printfig,avatarfig]);
close(clcfig);
%-----------------
% Open Print GUI Shortcut
% Shortcut summary goes here
cd ('C:\Phat Luu\MatlabCode\UHBMIGUI_PRINT');
UHBMIGUI_PRINT;
%-----------------------
% Open Avatar GUI shortcut
% Shortcut summary goes here
cd('C:\Phat Luu\MatlabCode\UHBMIGUI_AVATAR');
UHBMIGUI_AVATAR;
%------------------------
% Add uhlib shortcut
% Shortcut summary goes here
uhlibpath = 'C:\Phat Luu\MatlabCode\uhlib';
addpath(genpath(uhlibpath));
fprintf('uhlib has been added.\n');
fprintf('<a href="matlab:winopen(''%s'')">%s</a>.\n',uhlibpath,uhlibpath);
% ------------------------
% Add EEGLAB shortcut
% Shortcut summary goes here
eegpath = 'C:\Phat Luu\MatlabCode\EEGLAB';
addpath(eegpath);
fprintf('EEGLAB is added.\n');
fprintf('<a href="matlab:winopen(''%s'')">%s</a>.\n',eegpath,eegpath);
eeglab;
close(gcf);
%----------------------------
% Create Path shorcut 
% Shortcut summary goes here
mypath.mcode.uhlib = 'C:\Phat Luu\MatlabCode\uhlib';
mypath.mcode.avatargui = 'C:\Phat Luu\MatlabCode\UHBMIGUI_AVATAR';
mypath.mcode.neuroleggui = 'C:\Phat Luu\MatlabCode\UHBMIGUI_NEUROLEG';

mypath.rawmat.gonio = 'D:\OneDrive\UH-PROJECT-AVATAR\RAW DATA\STUDY-Gonioperturb';
mypath.rawmat.lesion = 'D:\OneDrive\UH-PROJECT-AVATAR\RAW DATA\STUDY-Lesion';
mypath.promat.gonio = 'C:\Phat Luu\UH PROCESS DATA\STUDY-GonioPerturb';
mypath.promat.lesion = 'C:\Phat Luu\UH PROCESS DATA\STUDY-Lesion';
mypath.promat.neuroleg = 'C:\Phat Luu\UH PROCESS DATA\STUDY-NeuroLeg';

mypath.report.goniofig = 'D:\OneDrive\UH-PROJECT-AVATAR\REPORT\STUDY-Gonioperturb\Figures';
mypath.report.lesionfig = 'D:\OneDrive\UH-PROJECT-AVATAR\REPORT\STUDY-Lesion\Figures';

fprintf('<a href="matlab:winopen(''%s'')">%s</a>.\n',mypath.mcode.uhlib,mypath.mcode.uhlib);
fprintf('<a href="matlab:winopen(''%s'')">%s</a>.\n',mypath.mcode.avatargui,mypath.mcode.avatargui);
fprintf('<a href="matlab:winopen(''%s'')">%s</a>.\n',mypath.mcode.neuroleggui,mypath.mcode.neuroleggui);
fprintf('<a href="matlab:winopen(''%s'')">%s</a>.\n',mypath.rawmat.gonio,mypath.rawmat.gonio);
fprintf('<a href="matlab:winopen(''%s'')">%s</a>.\n',mypath.rawmat.lesion,mypath.rawmat.lesion);
fprintf('<a href="matlab:winopen(''%s'')">%s</a>.\n',mypath.promat.gonio,mypath.promat.gonio);
fprintf('<a href="matlab:winopen(''%s'')">%s</a>.\n',mypath.promat.lesion,mypath.promat.lesion);
fprintf('<a href="matlab:winopen(''%s'')">%s</a>.\n',mypath.report.goniofig,mypath.report.goniofig);
fprintf('<a href="matlab:winopen(''%s'')">%s</a>.\n',mypath.report.lesionfig,mypath.report.lesionfig);

assignin('base','mypath',mypath);

%-------------------------------------