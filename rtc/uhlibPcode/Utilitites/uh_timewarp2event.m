%% uh_timewarp2event.m
%% *Description:*
% This function time-warp input data to gait event.
%% *Usages:*
%
% *Inputs:*
% Cell input contains data in each gait cycle. The number of cell is the
% number of step or gait cycle input.
% Matrix of gait cycle indexing. or timeline + time index
% *Outputs:*
% 2D matrix with row is number of step and collumn is average number of
% sample in one gait cycle
% *Options:*
% 
% *Notes:*
%
%% *Authors:*
% * *MATLAB Ver :* 9.0.0.341360 (R2016a)
% * *Date Created :* 30-Jan-2017 15:29:10
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
function varargout = uh_timewarp2event(cellinput, varargin) 
% Check if cellinput is cells of 1D data (raw eeg). or 2D data (spectrogram)
[rowcheck colcheck] = size(cellinput{1});
% indexmat: row: number of steps, column: number of gait event
indexinput = get_varargin(varargin,'index',[]);
timeline = get_varargin(varargin,'timeline',[]);
timeindex = get_varargin(varargin,'timeindex',[]);
if isempty(indexinput)
    if isempty(timeline)
        uh_fprintf('Missing Input Argument: Warp all gait cycle');
        for i = 1 : length(cellinput)
            thisgait = cellinput{i};
            indexmat(i,:) = [1 size(thisgait,2)];
        end
    else
        for i = 1 : size(timeindex,1)
            % Convert time index to sample index
            indexmat(i,:) = uh_getmarkerpos(timeindex(i,:),timeline);
        end
    end
else
    indexmat = indexinput;    
end
% normalize index matrix to its first column or the first gait event
indexmat = indexmat - repmat(indexmat(:,1),1,size(indexmat,2))+1;
% Mean value
avgindex = round(mean(indexmat,1));
% Loop throgh each step and timewarp
outputdata = [];
for i = 1 : length(cellinput)
    thisstep = cellinput{i};
    thisstepoutput = [];    
    for j = 1 : length(avgindex)-1
        phaseidx = indexmat(i,j:j+1);
        phasedata = thisstep(:,phaseidx(1):phaseidx(2));
        % Timewarp phasedata;
        phasedata = uh_timewarp(phasedata,'newsize',avgindex(j+1)-avgindex(j)+1,'torow',0); 
        thisstepoutput = [thisstepoutput, phasedata]; % Concatinate each phase data to one gait cycle
    end
    if rowcheck == 1
        outputdata = cat(1,outputdata,thisstepoutput);
    else
        outputdata = cat(3,outputdata,thisstepoutput);
    end
end
if nargout == 1
    varargout{1} = outputdata;
elseif nargout == 2
    varargout{1} = outputdata;
    varargout{2} = avgindex;
else
end


