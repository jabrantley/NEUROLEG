%% readBiometricsTxt.m
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
% * *Date Created :* 06-Sep-2018 16:12:27
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
function varargout = readBiometricsTxt(varargin) 
fullfilename = get_varargin(varargin,'fullfilename','untitled.txt');
dataIn = importdata(fullfilename);
data = dataIn.data;
textdata = dataIn.textdata;
numCh = length(textdata) - 2;
EMGdata = data(:, 1:numCh);
triggerVal = data(:,end);
k = 1;
for i = 1 : length(textdata)
    thisline = textdata{i};    
    temp = regexp(thisline,'''(.*)''','tokens');
    if ~isempty(temp)
        chName{k,1} = cellstr(temp{1});
        k = k + 1;
    end
end
EMG.label = chName;
triggerpos = find(diff(triggerVal) == 4);
EMG.data = EMGdata(triggerpos(1):triggerpos(end),:);
trigger = triggerpos - triggerpos(1) + 1;
EMG.trigger = trigger;
if nargout == 1
    varargout{1} = EMG;
else
    assignin('base','EMG',EMG);
end


% whos dataIn
% disp(dataIn.data)
% fid = fopen(fullfilename);
% filescan = textscan(fid,'%s','delimiter','\n');
% filescan = filescan{:}; % Open settings file (importdata does not work)
% k = 1;
% marker = [];
% for line = 1:length(filescan)
%     fullLine=filescan{line};    
%     if length(fullLine) > 2
%         if strcmpi(fullLine(1:2),'mk');
%             mkLine =  fullLine;
%             temp = textscan(mkLine,'%s %s');                        
%             markerinfo = cell2mat(textscan(temp{2}{1},'%f',...
%                 'Delimiter',','));
%             if ~isempty(markerinfo)
%                 marker(k,:) = markerinfo;
%                 k = k + 1;
%             end
%         end
%     end
% end
% if nargout == 1
%     varargout{1} = marker;
%     assignin('base','marker',marker)
% else
% end