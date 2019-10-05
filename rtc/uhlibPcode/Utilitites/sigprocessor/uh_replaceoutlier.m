function yout=uh_replaceoutlier(signal,varargin)
winsize = get_varargin(varargin,'winsize',4);
interpmethod = get_varargin(varargin,'method','pchip');

outlier=uh_getoutlierwindow(signal,'winsize',winsize);
remsig=signal(setdiff(1:length(signal),outlier));
yout=interp1(setdiff(1:length(signal),outlier),remsig,1:length(signal),interpmethod);