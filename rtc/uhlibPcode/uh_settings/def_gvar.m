function gvar = def_gvar
% System Settings
gvar.username = getenv('username');
% Graphics
gvar.margin.l=0.01;gvar.margin.r=0.01;
gvar.margin.t=0.01;gvar.margin.b=0.05;
gvar.margin.gap=0.01;
gvar.page.bgcolor='w';
gvar.myfont='Arial';
gvar.fontsizexl = 14;
gvar.fontsizel = 12;
gvar.fontsize = 10;
gvar.fontsizes = 8;
gvar.axfont = 8;
gvar.marker={'o','^','square','diamond','v','>','<','+','*','.','x'};
gvar.mycolor = class_color;
gvar.mysymbol = uh_symbol;
% =======EEG parameters
gvar.delta = [0.1 4];
gvar.theta = [4 7];
gvar.alpha = [8 13];
gvar.beta = [14 30];
gvar.lowgamma = [30 49];
% Utilities
gvar.timenow = class_datetime;
%===============================KIN Parameters========================
gvar.romhip=[-40 40];gvar.romjoint{1}=gvar.romhip;
gvar.romknee=[-90 10];gvar.romjoint{2}=gvar.romknee;
gvar.romankle=[-40 40];gvar.romjoint{3}=gvar.romankle;
gvar.lthigh=332;
gvar.lshank=391;
gvar.hankle=50;
gvar.leglength=gvar.lthigh+gvar.lshank+gvar.hankle;
gvar.jointname={'Hip','Knee','Ankle'};
gvar.thetahka={sprintf('\\it\\theta_{h}'),sprintf('\\it\\theta_{k}'),sprintf('\\it\\theta_{a}')};
