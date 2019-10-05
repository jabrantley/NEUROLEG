%% uh_arrow.m
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
% * *Date Created :* 25-Jan-2017 19:54:37
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
function varargout = uh_arrow(varargin) 
xdata = get_varargin(varargin,'xdata',[0 0]);
ydata = get_varargin(varargin,'ydata',[0 0]);
arrowsize = get_varargin(varargin,'arrowsize',[5 5]);
baseangle = get_varargin(varargin,'baseangle',60);
color = get_varargin(varargin,'color','k');
strinput = get_varargin(varargin,'string','');
textgap = get_varargin(varargin,'textgap',[0 0]);
if length(xdata) == 1    
    direction = 'vertical';
    arrowgap = get_varargin(varargin,'arrowgap',0.1*abs(diff(ydata)));
else    
    direction = 'horizontal';
    arrowgap = get_varargin(varargin,'arrowgap',0.1*abs(diff(xdata)));
end
if length(arrowsize) == 1, arrowsize = arrowsize.*[1 1]; end
if strcmpi(direction,'horizontal')
    arrow([mean(xdata)-arrowgap, ydata],[xdata(1) ydata],arrowsize(1),'BaseAngle',baseangle,'color',color);
    arrow([mean(xdata)+arrowgap ydata],[xdata(2) ydata],arrowsize(2),'BaseAngle',baseangle,'color',color);
    class_text('position',[mean(xdata), ydata],'string',strinput,...
        'horizontalalignment','center','textgap',textgap,'show',1);
else
    arrow([xdata, mean(ydata)-arrowgap],[xdata ydata(1)],arrowsize(1),'BaseAngle',baseangle,'color',color);
    arrow([xdata, mean(ydata)+arrowgap],[xdata ydata(2)],arrowsize(2),'BaseAngle',baseangle,'color',color);
    class_text('position',[mean(xdata), ydata],'string',strinput,...
        'horizontalalignment','center','textgap','rotation',90,textgap,'show',1);
end
