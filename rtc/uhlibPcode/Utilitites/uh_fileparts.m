%% uh_fileparts.m
%% *Description:*
% Get parent path to a given level
%% *Usages:*
% 
% *Inputs:*
% fullpath;
% 'level'
% *Outputs:*
% 
% *Options:*
% 
% *Notes:*
%
%% *Authors:*
% * *MATLAB Ver :* 9.0.0.341360 (R2016a)
% * *Date Created :* 07-Apr-2017 11:19:00
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
function varargout = uh_fileparts(varargin) 
level = get_varargin(varargin,'level',1);
% Find fullfilename that call this function,
[stacktrace, ~]=dbstack('-completenames',1); 
fullpath = get_varargin(varargin,'fullpath',cd);
pathstr = '';
for i = 1 : level
    if i == 1
        [pathstr,subpathstr,~] = fileparts(fullpath);
    else
        [pathstr,subpathstr,~] = fileparts(pathstr);
    end
end
if nargout == 1
    varargout{1} = pathstr;
elseif nargout == 2
    varargout{1} = pathstr;
    varargout{2} = subpathstr;
else
end
    

