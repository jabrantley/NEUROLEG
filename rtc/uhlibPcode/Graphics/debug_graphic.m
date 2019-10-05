function debug_graphic
% Debug rectangle
% myfig = figure;
% myax = axes;
%%
% Initialize
%=====
%% 
% --------class_text
gvar = def_gvar;clc; close all;
myax = gca; cla(gca,'reset');
mytext = class_text('string','Test','location','north');
% mytext.xlabel = 1;
% set(mytext,'position',[1 1])
mytext.showtext
%%
% ------------------Print color pallete
gvar = def_gvar;clc; close all;
myax = gca; cla(gca,'reset');
this = class_color('alpha',0.6);
this.showcolorpallet('pallete',[this.sroncolor.normal, this.sroncolor.light],'rows',7,'cols',4,'gaps',[0.05 0.35]);
class_text('location','xlabel','string','COLOR FRIENDLY PALLETE','show',1);
figfile = class_FileIO('filename','colorpallete');
set(gcf,'color','w');
printopt = 0;
if printopt==1    
    myprinter = class_export_fig('filename',figfile.fullfilename,...
        'format','jpg','resolution',800,'paper',[0 0 4 5],'handles',gcf);    
    myprinter.export;    
end
%%
%-----------Color map
gvar = def_gvar;clc; close all;
myax = gca; cla(gca,'reset');
colormap(gvar.mycolor.cmap)
colorbar;

%%
% --------class_Point
gvar = def_gvar;clc; close all;
myax = gca; cla(gca,'reset');
this = class_point('xdata',0,'ydata',0,'string','A','textcolor','r');
set(this.textobj,'textgap',[-0.1 0.1]);
% set(this.textobj,'color','r','verticalalignment','bottom','fontweight','bold')
this.drawshape
set(gca,'xlim',[0 1],'ylim',[0 1]);
%%
% --------class_line
gvar = def_gvar;clc; close all;
myax = gca; cla(gca,'reset');
this = class_line('string','Test');
textobj = this.textobj
set(this.center,'marker','o','markersize',6);
% set(this.textobj,'string','Test','textgap',[-0.1 0.1]);
this.center.drawshape;
this.drawshape;
set(gca,'xlim',[0 1],'ylim',[0 1]);
%%
% Rectangle and alignment
gvar = def_gvar;clc;
myax = gca; cla(gca,'reset');
myrec = class_rectangle('center',class_point('xdata',0.2,'ydata',0.5),'width',0.2,'height',0.1,...
    'facecolor',gvar.mycolor.b,'edgecolor','r','linestyle','--',...
    'string','1');
myrec.textobj
myrec.drawshape;
myrec2 = class_rectangle('string','2');
myrec2.align('ref',myrec,'align','south','gap',[0.0 -0.02],'scale',[2 1]);
myrec2.drawshape;
set(myrec2.vertex3.textobj,'string','3','textgap',[0.1 0.1]);
myrec2.vertex3.drawshape;
set(gca,'xlim',[0 1],'ylim',[0 1]);
%% 
% Rectangle palette
cla(gca,'reset');
myrec = class_rectangle_mat('draw',1,'gap',[0.1 0.1]);
set(myrec.rect{1,1},'facecolor','k','linecolor','r');
myrec.rect{1,1}.drawshape;
set(myrec.rect{1,2},'facecolor','r','linecolor','r');
myrec.rect{1,2}.drawshape;
set(myrec.rect{2,1},'facecolor','b','linecolor','r');
myrec.rect{2,1}.drawshape;

%%
% Debug arrow
cla(gca,'reset');
this = class_arrow('start',class_point(1,0),'end',class_point(0,1),'type','both','ratio',0.02);
this.endanchor.facecolor = 'r';
this.drawshape;

