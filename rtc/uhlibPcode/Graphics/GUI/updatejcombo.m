%% updatejcombo.m
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
% * *Date Created :* 04-Dec-2016 20:51:27
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
function updatejcombo(jcombohdl,newitem,varargin)
maxitem = get_varargin(varargin,'maxitem',10);
jcombohdl.insertItemAt(newitem,0);
lastrow=jcombohdl.getItemCount;
if lastrow > maxitem
    jcombohdl.removeItemAt(lastrow-1); %java index from 0
end
jcombohdl.setSelectedIndex(0);