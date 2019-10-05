%% plotnbchan.m
%% *Description:*
% This function plot n number of channels in the same plot.
% The plot looks like Brainvision data
%% *Usages:*
%
% *Inputs:*
% Matrix of data.
% *Outputs:*
% Plot
% *Options:*
% 
% *Notes:*
%
%% *Authors:*
% * *MATLAB Ver :* 9.0.0.341360 (R2016a)
% * *Date Created :* 07-Sep-2018 11:20:09
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
function varargout = plotnbchan(varargin) 
xdata = get_varargin(varargin,'xdata',[]);
ydata = get_varargin(varargin,'ydata',[]);
ax = get_varargin(varargin,'axis',gca); % select axis to plot.
gap = get_varargin(varargin,'gap',3); % gap in std
% ydata is a matrix, signals could be column or row format.
dim = get_varargin(varargin,'dim',2); % Select columns as signal as default
color = get_varargin(varargin,'color',{'k'});
linestyle = get_varargin(varargin,'linestyle',{'-'});
linewidth = get_varargin(varargin,'linewidth',[0.75]);
%
% Debugging;
% EEGraw = evalin('base','EEGraw');
% ydata = EEGraw.data;
% trigger = EEGraw.event;
% dim = 1;
% EMG = evalin('base','EMG');
% ydata = EMG.data;
% trigger = EMG.trigger;
% dim = 2;
% close all;
% figure;
% gap = 5;
% Compute number of channels and number of data points.
if dim == 1
    ydata = ydata';
    dim = 2;
end
[pnts, nbchan] = size(ydata);
if length(gap) == 1
    gap = gap*ones(1, nbchan);
end
if isempty(xdata)
    xdata = transpose(1 : pnts);
end
% Interpolate Nan data;
for i = 1 : nbchan
    temp = ydata(:,i);
    if any(isnan(temp))        
        pp = interp1(xdata(~isnan(temp)),temp(~isnan(temp)),...
            'linear','pp');
        ydata(:,i) = fnval(pp,xdata);        
    end
end
meanVal = mean(ydata);
stdVal = std(ydata);
% Remove the mean
stdVal = [0, stdVal]; stdVal(end) = [];
stdCumsum = cumsum(stdVal);
% Remove mean
ydata = ydata - repmat(meanVal,pnts,1);
% Shift each signals down
ydata = ydata - repmat(gap.*stdCumsum, pnts,1);
assignin('base','ydata',ydata);
% Plot
if length(color) == 1
    color = repmat(color,1,nbchan);
end
if length(linestyle) == 1
    linestyle = repmat(linestyle,1,nbchan);
end
if length(linewidth) == 1
    linewidth = repmat(linewidth,1,nbchan);
end
for i = 1 : nbchan
    linehdl = plot(xdata,ydata(:,i));
    set(linehdl,'color',color{i},...    
        'linestyle',linestyle{i},...
        'linewidth', linewidth(i));
    hold on;
end
limy = [min(ydata(:,end)), max(ydata(:,1))];
try
    set(gca,'ylim',limy);
catch
end
% Channel 1 on top
% plotTrigger('data',trigger,'ylim',get(gca,'ylim'),'linecolor','r');
% Annotate




