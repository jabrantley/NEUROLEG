%% uh_GCheelError.m
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
% * *Date Created :* 28-Dec-2016 00:50:32
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
function varargout = uh_GCheelError(varargin) 
% Input and options
template = get_varargin(varargin,'template',[]);
movdot = get_varargin(varargin,'actual',[]);
if isempty(template) || isempty(movdot)
    fprintf('Heel template and actual template cannot be empty');
    return;
end
shiftval = get_varargin(varargin,'shift',[500, 1000]); % Shift to positive value for poly2mask
plotopt = get_varargin(varargin,'plot',0);
pixel = get_varargin(varargin,'pixel',[1000 1000]);
axin = get_varargin(varargin,'axin',[]);
gridopt = get_varargin(varargin,'grid',0);
gridgap = get_varargin(varargin,'gridgap',1);
%
template = (template + repmat(shiftval,size(template,1),1));
movdot = (movdot + repmat(shiftval,size(movdot,1),1));
b1 = poly2mask(template(:,1),template(:,2),pixel(2),pixel(1));
b2 = poly2mask(movdot(:,1),movdot(:,2),pixel(2),pixel(1));
allimg = b1|b2;
sec = b1&b2;
allimg(sec)=0;
ydiff = bwarea(allimg);
signdiff = bwarea(b1) < bwarea(b2); % if template > movdot area
if signdiff == 0, signdiff = -1; end;
yout = signdiff*ydiff;
if plotopt == 1
    if isempty(axin) figure; else axes(axin); end;    
    greymap = [255 255 255; 125 125 125] / 255;
    imshow(allimg,greymap); hold on;    
    if gridopt == 1
        for i = 1 : gridgap : pixel(2)
            line('xdata',get(gca,'xlim'),'ydata',i.*[1 1],'color',[200 200 200]./256); hold on;
        end
        for i = 1 : gridgap : pixel(1)
            line('ydata',get(gca,'ylim'),'xdata',i.*[1 1],'color',[200 200 200]./256); hold on;
        end
    end
    plot(template(:,1),template(:,2),'r','linewidth',1.5);
    plot(movdot(:,1),movdot(:,2),'k--');
    set(gca,'YDir','normal');
    axis on;   
    axis equal;
    set(gca,'xlim',[0 pixel(1)],'ylim',[0 pixel(2)]);    
    set(gcf,'color','w');
end
if nargout == 1
    varargout{1} = yout;
end
