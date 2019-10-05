%% makePythonDeepLearningProject.m
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
% * *Date Created :* 30-Jul-2018 00:13:10
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
function varargout = makePythonDeepLearningProject(varargin) 
filename = get_varargin(varargin,'filename','untitiled');
filedir = get_varargin(varargin,'filedir',cd);
mfilepath = mfilename('fullpath');
[mdir, ~, ~] = fileparts(mfilepath);
%-------
author = get_varargin(varargin,'author','Phat Luu');
email = get_varargin(varargin,'email','ptluu2@central.uh.edu');
filedir = get_varargin(varargin,'filedir',cd);
% fcnname = get_varargin(varargin,'filename','Untitled');
headerlines{1} = sprintf('"""\n');
headerlines{end+1} = sprintf('Created on: %s\n',datestr(now));
headerlines{end+1} = sprintf('Author: %s\n',author);
headerlines{end+1} = sprintf('Email: %s\n',email);
headerlines{end+1} = sprintf('Brain Machine Interfaces Lab');
headerlines{end+1} = sprintf('University of Houston');
headerlines{end+1} = sprintf('"""\n');
create_headerinfo(filename,author,email);
% Create folders and basic python files for the project
% Data folder
folderList = {'logModels','TF_Graph'};
% saved checkpoint model folder
for i = 1 : length(folderList)
    strcmd = sprintf('mkdir(''%s'')',...
        fullfile(filedir,folderList{i}));
end
eval(strcmd);
% List of Python file to create
% fileList = strcat(filename,{'Model','Train','Test','DataHelper'});
fileList = strcat(filename,{'Train'});
templatefileList = {'pyCNNtrainTemplate.txt'};
for i = 1 : length(fileList)
    filename = fileList{i};
    templateFilename = templatefileList{i};
    myPyfile = class_FileIO('filedir',filedir,'filename',filename,'ext', '.py');      
    templateFile = class_FileIO('filedir',mdir,'filename',templateFilename,'ext', '.py');      
    templateFile.fullfilename
    wfid = fopen(myPyfile.fullfilename,'w');    
    rfid = fopen(templateFile.fullfilename,'r');
    for j=1:length(headerlines)
        fprintf(wfid,'%s\n', headerlines{j});
    end      
    filescan = textscan(rfid,'%s','delimiter','\n');
    filescan = filescan{:}; % Open settings file (importdata does not work)
    for line = 1:length(filescan)
        fullLine=filescan{line};
        fprintf(wfid, fullLine);
        fprintf(wfid,'\n');
    end
    % winopen(filename);
    fclose(rfid);
    fclose(wfid);
end


% template_mfile = class_FileIO('filedir',mdir,'filename','templatecode_gui','ext','.m');
% output_mfile = class_FileIO('filedir',filedir,'filename',filename,'ext', '.m');
% mfid = fopen(output_mfile.fullfilename,'w');
% texlines = template_mfile.uh_textscan;
% checkcond = 0;
% for i = 1 : length(texlines)    
%     thisline = texlines{i};
%     if strfind(thisline,'function') == 1 & checkcond == 0
%         fprintf(mfid,'function %s(varargin)\n',output_mfile.filename);
%         checkcond = 1;
%     else
%         fprintf(mfid,'%s \n',texlines{i});
%     end    
% end
% fclose(mfid);
% edit(output_mfile.fullfilename);