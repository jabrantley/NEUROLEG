%% uh_normalizegcevent.m
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
% * *Date Created :* 31-Jan-2017 11:15:27
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
function varargout = uh_normalizegcevent(gcevent, varargin) 
% Substract the first column
gcevent = gcevent - repmat(gcevent(:,1),1,size(gcevent,2));
% Total size;
totaltime = gcevent(end) - gcevent(:,1);
output = 100*gcevent./repmat(totaltime,1,size(gcevent,2));
if nargout == 1
    varargout{1} = output;
else
end





