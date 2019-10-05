%% dictmap.m
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
% * *Date Created :* 03-Dec-2016 17:56:01
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
function varargout = dictmap(input,varargin) 
keynames = {'thetahip'};
valnames = repmat({''},size(keynames));
% Initialize and extend the key map
keymap = containers.Map(keynames,valnames);
keymap('thetahip') = '$\theta_{h}$';
keymap('thetaknee') = '$\theta_{k}$';
keymap('thetaankle') = '$\theta_{a}$';
keymap('BCI-ctrl') = '\textit{BCI-ctrl}';
keymap('Gonio-ctrl') = '\textit{Gonio-ctrl}';
keymap('gonio-ctrl') = '\textit{Gonio-ctrl}';
keymap('deltaband') = '$\Delta$ (0.1-3 Hz)';
keymap('thetataband') = '$\theta$ (4-7 Hz)';
keymap('alphaband') = '$\alpha$ (8-13 Hz)';
keymap('alphamuband') = '$\alpha$/$\mu$ (8-13 Hz)';
keymap('betaband') = '$\beta$ (14-30 Hz)';
keymap('gammaband') = '$\gamma$ (30-49 Hz)';
%--------
keymap('can''t') = 'cannot';
%--------
output = input;
for i = 1 : keymap.Count
    keynames = keys(keymap);
    if ~isempty(strfind(input,keynames{i}))
        output = strrep(output,keynames{i},keymap(keynames{i}));
    end
end
varargout{1} = output;