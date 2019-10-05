function uh_insertfileheader(varargin)
author = get_varargin(varargin,'author','Phat Luu');
email = get_varargin(varargin,'email','ptluu2@central.uh.edu');
% filename = get_varargin(varargin,'filename','testfilename');
myfile = class_FileIO('filedir',cd,'filename','debug_addheader.m');
filename = myfile.fullfilename;
[~,~,ext] = fileparts(filename);
if isempty(ext)
    filename = [filename '.m'];
end
%-----
headerlines = create_headerinfo(filename,author,email);
fid = fopen(filename,'r'); % Open file for reading
currentlines = textscan(fid,'%s','delimiter','\n');
currentlines = currentlines{:}; % Open settings file (importdata does not work)
%
fid = fopen(filename,'w'); % Open file for writing;
outputlines = [headerlines; currentlines];
for j=1:length(outputlines)
    fprintf(fid,'%s\n', outputlines{j});
end


function infotextline = create_headerinfo(filename,author,email)
infotextline{1,1} = ['%% ',filename];
infotextline{end+1,1} = '% * *Description:*';
infotextline{end+1,1} = '% * *Usages:*';
infotextline{end+1,1} = '%';
infotextline{end+1,1} = '%       Inputs:';
infotextline{end+1,1} = '% ';
infotextline{end+1,1} = '%       Outputs:';
infotextline{end+1,1} = '% ';
infotextline{end+1,1} = '%       Options:';
infotextline{end+1,1} = '% ';
infotextline{end+1,1} = '%       Notes:';
infotextline{end+1,1} = '%';
infotextline{end+1,1} = ['% * *MATLAB Ver* : %s', version];
infotextline{end+1,1} = ['% * *Date Created* : %s', datestr(now)];
infotextline{end+1,1} = ['% * *Author:* %s. %s',author,email];
infotextline{end+1,1} = '%';
infotextline{end+1,1} = '% _Laboratory for Noninvasive Brain Machine Interface Systems. University of Houston_';
infotextline{end+1,1} = '% ';
infotextline{end+1,1} = '';
infotextline{end+1,1} = '% This program is free software; you can redistribute it and/or modify';
infotextline{end+1,1} = '% it under the terms of the GNU General Public License as published by';
infotextline{end+1,1} = '% the Free Software Foundation; either version 2 of the License, or';
infotextline{end+1,1} = '% (at your option) any later version.';
infotextline{end+1,1} = '%';
infotextline{end+1,1} = '% This program is distributed in the hope that it will be useful,';
infotextline{end+1,1} = '% but WITHOUT ANY WARRANTY; without even the implied warranty of';
infotextline{end+1,1} = '% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the';
infotextline{end+1,1} = '% GNU General Public License for more details.';
infotextline{end+1,1} = '% -----';
infotextline{end+1,1} = '';