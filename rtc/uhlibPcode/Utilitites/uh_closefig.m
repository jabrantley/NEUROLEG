%% uh_closefig.m
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
% * *Date Created :* 17-Apr-2017 13:13:34
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
function varargout = uh_closefig(varargin) 
% Shortcut summary goes here
allfig=findall(0,'type','figure');
printfig=findall(0, '-depth',1, 'type','figure', 'Name','UHBMIGUI_PRINT');
avatarfig=findall(0, '-depth',1, 'type','figure', 'Name','UHBMIGUI_AVATAR');
neurolegfig=findall(0, '-depth',1, 'type','figure', 'Name','UHBMIGUI_NEUROLEG');
brainstormfig = findall(0, '-depth',1, 'type','figure', 'Name','Brainstorm');
clcfig=setdiff(allfig,[printfig,avatarfig,neurolegfig,brainstormfig]);
close(clcfig);