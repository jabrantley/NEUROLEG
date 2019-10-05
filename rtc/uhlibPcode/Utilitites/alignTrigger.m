%% alignTrigger.m
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
% * *Date Created :* 13-Sep-2018 13:34:03
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
function varargout = alignTrigger(trigIn, fsIn, fsOut);
trigOut = round(trigIn*fsOut/fsIn);
if trigOut(1) == 0
    trigOut = trigOut + 1;
else
end
if nargout == 1
    varargout{1} = trigOut;
end