%% tex_loadbibfile.m
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
% * *Date Created :* 04-Dec-2016 23:48:22
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
function varargout = tex_loadbibfile(varargin) 
filename = get_varargin(varargin,'filename','untited');
getopt = get_varargin(varargin,'getopt',{'key','title'});
% For Debugging
filename = 'P:\Dropbox\LTP_Publication\D-2016-Latex\Draft\mybib.bib';
bibinfo = bibload(filename);
fieldnames(bibinfo)
bibkey = bibinfo.cKey;
bibdata = bibinfo.cBib;
bibcell = cell(size(bibkey));
for i = 1 : length(bibkey)
    thisbib = bibdata{i};
    comps = strsplit(thisbib,'\n');    
    for j = 1 : length(comps)
        thiscomp = comps{j};
        if strfind(thiscomp,'author')==1 & strfind(thiscomp,'=')
            startbracket = strfind(thiscomp,'{');startbracket = startbracket(1);
            endbracket = strfind(thiscomp,'}'); endbracket = endbracket(end);           
            comma = strfind(thiscomp,','); 
            if ~isempty(comma),firstcomma = comma(1); 
            else firstcomma = endbracket; 
            end;
            thisauthor = thiscomp(startbracket+1:firstcomma-1);
        elseif strfind(thiscomp,'year') == 1 & strfind(thiscomp,'=')
            startbracket = strfind(thiscomp,'{'); startbracket = startbracket(1);
            endbracket = strfind(thiscomp,'}'); endbracket = endbracket(end);
            thisyear = thiscomp(startbracket+1:endbracket-1);
        elseif strfind(thiscomp,'title')==1 & strfind(thiscomp,'=')
            startbracket = strfind(thiscomp,'{');startbracket = startbracket(1);
            endbracket = strfind(thiscomp,'}'); endbracket = endbracket(end);
            thistitle = thiscomp(startbracket+1:endbracket-1);            
        end        
    end
    bibcell{i} = strcat(bibkey{i},'|',thisyear,'|',thistitle);
end
varargout{1} = bibcell;
