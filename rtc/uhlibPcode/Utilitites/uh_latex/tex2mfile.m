%% tex2mat.m
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
% * *Date Created :* 03-Dec-2016 17:23:02
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
function varargout = tex2mfile(varargin) 
filename = get_varargin(varargin,'filename','untitiled');
filedir = get_varargin(varargin,'filedir',cd);
% debug;
filename = 'sample_draft';
filedir = 'P:\Dropbox\LTP_Publication\2016-latex';
texfile = class_FileIO('filedir',filedir,'filename',filename,'ext','.tex');
mfile = class_FileIO('filedir',filedir,'filename',filename,'ext', '.m');
texfile.fullfilename
mfid = fopen(mfile.fullfilename,'w');
texlines = texfile.uh_textscan;
fprintf(mfid,'function %s(varargin)\n',mfile.filename);
fprintf(mfid,'mfullfilename = mfilename(''fullpath'');\n');
fprintf(mfid,'texfullfilename = strrep(mfullfilename,''.m'',''.tex'');\n');
fprintf(mfid,'fid = fopen(texfullfilename,''w'');\n');
fprintf(mfid,'pdfopt = get_varargin(varargin,''pdf'',1);\n');
for i = 1 : length(texlines)
    fprintf(mfid,'texprint(fid,''%s'');\n',strrep(texlines{i},'''',''''''));
end
% Export to pdf option
fprintf(mfid,'if pdfopt == 1 \n');
fprintf(mfid,'    strcmd = sprintf(''pdflatex %%s'',texfullfilename); \n');
fprintf(mfid,'    status = system(strcmd,''-echo''); \n');
fprintf(mfid,'end \n');
fclose(mfid);
edit(mfile.fullfilename)





