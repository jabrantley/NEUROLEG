%% class_texfig.m
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
% * *Date Created :* 03-Dec-2016 22:32:03
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
classdef class_texfig < hgsetget;
    properties (SetAccess = public, GetAccess = public)
        filename;
        filedir;
        ext;
        label;
        caption;
        location; % graphicx package, h: here, t: top, b: bottom, p: page of float
    end
    methods (Access = public) %Constructor
        function this = class_texfig(varargin)
            this.filename = get_varargin(varargin,'filename','untitled');
            this.filedir = get_varargin(varargin,'filedir',cd);
            this.ext = get_varargin(varargin,'ext','.eps');
            this.label = get_varargin(varargin,'label','fig_label');            
            this.location = get_varargin(varargin,'location','h');
            this.caption = get_varargin(varargin,'caption','Figure caption');
        end
        function texout = insert(this)
            texout = [...
                sprintf('\n\n'),...
                sprintf('%%==Insert Figure: %s%s.\n',this.filename,this.ext),...
                sprintf('\\begin{figure}[%s]\n',this.location),...
                sprintf('\\noindent\n'),...
                sprintf('\\includegraphics[width=\\textwidth]{%s}\n',[this.filename this.ext]),...
                sprintf('\\caption{%s}\n',this.caption),...
                sprintf('\\label{fig:%s}\n',this.label),...
                sprintf('\\end{figure}\n'),...
                sprintf('%%--'),...
                sprintf('\n\n'),...
                ];
        end
    end
    methods (Static)
    end
    methods (Access = private) %Destructor
        function delete(this) % Delete obj.
        end
    end
end
