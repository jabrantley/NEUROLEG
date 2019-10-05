%% uh_listfile.m
%% *Description:*
% List file with given extension and keyword in a
% given directory
%% *Usages:*
%
% *Inputs:*
% Directory: Defaults: current directory
% *Outputs:*
% Cell list of filename
% *Options:*
% ext:  Extension, default empty: folder
% keyword: default, '' 
% *Notes:*
%
%% *Authors:*
% * *MATLAB Ver :* 9.0.0.341360 (R2016a)
% * *Date Created :* 02-Aug-2017 18:04:33
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
function varargout = uh_listfile(inputdir,varargin) 
% Parse inputs
filetype = get_varargin(varargin,'filetype','.m');
keyword = get_varargin(varargin,'keyword','');
selectopt = get_varargin(varargin,'select','all');
if ~iscell(filetype)
    filetype = cellstr(filetype);
end
if ~iscell(keyword)
    keyword = cellstr(keyword);
end
% Get all dirs and files in inputdir
itemlist = dir(inputdir);
k = 1;
typelist = {};

for i = 1 : length(itemlist)
    % If input file type is directory or folder
    if any(~cellfun('isempty',strfind({'dir','folder'},filetype)))
        if itemlist(i).isdir
            typelist{k} = itemlist(i).name; k = k+1;
        end
    else
        % If input file type is not directory
        if ~(itemlist(i).isdir)
            filename = itemlist(i).name;
            [~,~,ext] = fileparts(filename);
            ext(strfind(ext,'.')) = '';
            if any(~cellfun('isempty',strfind(filetype,ext)))
                typelist{k} = filename; k = k+1;
            end
        end
    end
end
% Fine tune to match with a list of keyword
keyfilelist = {};
k = 1;
if length(keyword)==1 && isempty(keyword{1})
    keyfilelist = typelist;
else
    for i = 1 : length(typelist)
        for j = 1  : length(keyword)
            if strfind(lower(typelist{i}),lower(keyword{j}))
                keyfilelist{k} = typelist{i}; k = k+1;
                break;
            end
        end
    end
end
% Output selected item, all, first item or last
% item in the list
if strcmpi(selectopt,'all')
    outputlist = keyfilelist;
else
    temp = sort(keyfilelist);
    if any(~cellfun('isempty',strfind({'first','1st'},selectopt)))
        outputlist{1} = temp{1};
    else
        outputlist{1} = temp{end};
    end
end
if nargout == 1
    varargout{1} = outputlist;
end