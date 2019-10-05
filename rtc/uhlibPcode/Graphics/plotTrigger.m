%% plotTrigger.m
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
% * *Date Created :* 07-Sep-2018 13:06:39
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
function varargout = plotTrigger(varargin) 
if nargin == 1
    triggerIn = varargin{1};
    axin = gca;
    limVal = get(axin,'ylim');
    linecolor = {'k'};
    linestyle = '-';
else
    triggerIn = get_varargin(varargin,'data',[]);
    axin = get_varargin(varargin,'axin',gca);
    limVal = get_varargin(varargin,'ylim',get(axin,'ylim'));
    linecolor = get_varargin(varargin,'linecolor',{'k'});
    linestyle = get_varargin(varargin,'linestyle','-');
end
if length(linecolor) == 1
    linecolor = repmat(linecolor,length(triggerIn),1);
end
% Debug 
% EEGraw = evalin('base','EEGraw');
% triggerIn = EEGraw.event;
% xdata = triggerIn(1):1:triggerIn(end);
% ydata = repmat(limVal(1),1,length(xdata));
% ydata(triggerIn) = limVal(2);
axes(axin);
% plot(xdata,ydata,'color',linecolor,...
%     'linestyle',linestyle);
for i = 1 : length(triggerIn)
    line('xdata',triggerIn(i).*[1 1],'ydata',limVal,...
        'color',linecolor{i},...
        'linestyle',linestyle);
end

