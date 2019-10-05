%% globFiles.m
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
% * *MATLAB Ver :* 9.3.0.713579 (R2017b)
% * *Date Created :* 12-Sep-2018 22:03:55
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
function varargout = globFiles(varargin) 
inputDir = get_varargin(varargin,'dir',cd);
key = get_varargin(varargin,'key','');
filetype = get_varargin(varargin,'filetype','all');
filetype(strfind(filetype,'.')) = []; % remove the . if any
% List directory in current directory
globList = {};
if strcmpi(filetype,'dir')
    strcmd = sprintf('globList = glob(''%s/*/'');',inputDir);
    eval(strcmd);
elseif strcmpi(filetype,'all')
    strcmd = sprintf('globList = glob(''%s/*'');',inputDir);
    eval(strcmd);
elseif strcmpi(filetype, 'alltree')
    strcmd = sprintf('globList = glob(''%s/**'');',inputDir);
    eval(strcmd);
else
    strcmd = sprintf('globList = glob(''%s/*.%s'');',inputDir,filetype);
    eval(strcmd);
end
outputList = globList;
if ~isempty(key) && ~isempty(outputList)
    k = 1;
    outputList = {};
    for i = 1 : length(globList)
        if strfind(globList{i}, key)
            outputList{k} = globList{i};
            k = k + 1;
        end
    end
end
% Recursively list all the sub directories
% strcmd = sprintf('globList = glob(''%s/**/'');',inputDir);
% eval(strcmd);
% globList
if nargout == 1
    varargout{1} = outputList;
else
    celldisp(outputList);
end