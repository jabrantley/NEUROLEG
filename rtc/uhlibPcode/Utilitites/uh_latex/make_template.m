%% make_template.m
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
% * *Date Created :* 03-Dec-2016 20:06:54
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
function varargout = make_template(varargin) 
filename = get_varargin(varargin,'filename','untitiled');
filedir = get_varargin(varargin,'filedir',cd);
template = get_varargin(varargin,'template','draft');
openopt = get_varargin(varargin,'open',1);
mfilepath = mfilename('fullpath');

[mdir, ~, ~] = fileparts(mfilepath);
%-------
if strcmpi(template,'draft')
    template_mfile = class_FileIO('filedir',mdir,'filename','template_draft','ext','.m');
elseif strcmpi(template,'ieeeconf')
elseif strcmpi(template,'ieeejournal')
end
output_mfile = class_FileIO('filedir',filedir,'filename',filename,'ext', '.m');
mfid = fopen(output_mfile.fullfilename,'w');
texlines = template_mfile.uh_textscan;
funcflag = 0;
for i = 1 : length(texlines)    
    thisline = texlines{i};
    if strfind(thisline,'function') == 1 & funcflag ==0
        fprintf(mfid,'function %s(varargin)\n',output_mfile.filename);
        funcflag = 1;
    else
        fprintf(mfid,'%s \n',texlines{i});
    end    
end
fclose(mfid);
if openopt == 1
    edit(output_mfile.fullfilename)
end