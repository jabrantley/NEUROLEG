function debug_classplot
% Initialize
% figure;
%-----
%%
% Debug boxplot
gvar = def_gvar;clc; close all;
myax = gca; cla(gca,'reset');
%-----
xdata = 1 : 5;
ydata = randn(400, length(xdata));
ydata(50:end,:) = ydata(50:end,:) + 3;
this = uh_plot.boxplot(xdata,ydata,'notch',0.25,'jitter',0.75,'facecolor',gvar.mycolor.blindcolor{8},'facealpha',0.5,...
    'edgecolor','k','edgewidth',1.25,...
    'linecolor','k','linestyle','--',...
    'tail',0.1,'marker','+','markersize',6,'markerfacecolor','k',...
    'xlabel',{'Group 1','Group 2','Group 3','Group 4','Group 5'});
% this.plotopt.outliers = 0;
set(this.patchobj(1),'facecolor','r');
set(this.patchobj(end),'facecolor','k');
this.showplot;
for i = 1 : 5    
    set(this.medianline(i),'linestyle','-','linewidth',1.25,'linecolor','k');
    this.medianline(i).drawshape;
    set(this.medianline(i).center,'marker','o','markersize',8,'markerfacecolor','r');
    this.medianline(i).center.drawshape;    
%     set(this.xlabel(i),'string',sprintf('Group %d',i),'ydata',-3.5,...
%         'fontweight','bold','rotation',15,'horizontalalignment','center');
%     this.xlabel(i).showtext;
end
limx = [0 6]; limy = [-3 8];
set(gca,'xlim',limx,'ylim',limy);
% Compare with Matlab boxplot
% limx = [0 6];
% limy = [-6 6];
% set(gca,'xlim',limx,'ylim',limy);
% figure;
% boxplot(ydata,'whisker',1.5);
% set(gca,'xlim',limx,'ylim',limy);

