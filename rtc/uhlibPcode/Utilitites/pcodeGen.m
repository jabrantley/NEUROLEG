%% pcodeGen.m
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
% * *Date Created :* 17-Aug-2018 23:19:48
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
function varargout = pcodeGen(varargin) 
rootDir = 'P:\MatlabCode';
uhlib = fullfile(rootDir,'uhlib');
cloneDir = 'uhlibPcode';
if ~strcmpi(pwd, rootDir)
    cd(rootDir);    
end
if ~exist(cloneDir)
    mkdir(cloneDir);
    strcmd = sprintf('copyfile uhlib %s', cloneDir);
    eval(strcmd);
end
strcmd = sprintf('mfileList = glob(''**/%s/**.m'')',cloneDir);
eval(strcmd)
for i = 1 : length(mfileList)
    thisFile = mfileList{i};
    [pDir, filename] = fileparts(thisFile);
    cd(fullfile(rootDir,pDir));
    try
        pcode(filename);
        delete(fullfile(rootDir,thisFile));
        fprintf('DONE: %s.\n',thisFile);
    catch
        fprintf('Failed to generate pcode for %s.\n',thisFile);
    end
end
cd(fullfile(rootDir,cloneDir));
if exist('.git')
    rmdir .git s
end
cd(rootDir);