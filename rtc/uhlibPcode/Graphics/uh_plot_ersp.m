function uh_plot_ersp(matplot,varargin)
limx = get_varargin(varargin,'xlim',[0 100]);
limy = get_varargin(varargin,'ylim',[0 50]);
limc = get_varargin(varargin,'clim',[-1 1]);
colorbaropt = get_varargin(varargin,'colorbar',0);

% imagesc(linspace(limx(1),limx(2),size(matplot,2)),linspace(limy(1),limy(2),size(matplot,1)),matplot);
pcolor(linspace(limx(1),limx(2),size(matplot,2)),linspace(limy(1),limy(2),size(matplot,1)),matplot);
shading 'interp';
set(gca,'xlim',limx,'ylim',limy,'clim',limc,'ydir','normal');
colormap(jet(256));
hold on;
if colorbaropt == 1
    colorbar;
end