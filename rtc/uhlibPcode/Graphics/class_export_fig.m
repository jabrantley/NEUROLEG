%% class_export_fig.m
% * *Description:*
% * *Usages:*
%
%       Inputs:
%
%       Outputs:
%
%       Options:
%
%       Notes:
%
% * *MATLAB Ver* : 9.0.0.341360 (R2016a)
% * *Date Created* : 28-Sep-2016 04:37:07
% * *Author:* Phat Luu. ptluu2@central.uh.edu
%
% _Laboratory for Noninvasive Brain Machine Interface Systems. University of Houston_
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
% -----

classdef class_export_fig < hgsetget;
    properties (SetAccess = public, GetAccess = public)
        filename; % full file name of figure to be created.
        figfile; % File object created from class_FileIO;
        format; % figure format. 'pdf','eps','png','tif','jpg', and 'bmp'
        iscrop; % crop or not.
        transparent; % option for figure background. only for png,pdf,tif and eps;
        res; % resolution. default 800
        renderer; % 'painters', 'opengl', or ;zbuffer';
        colorspace; % 'rgb', 'cmyk' or 'gray'. default 'rgb'. cmyk is only for pdf, eps, and tif.
        nofontswap; % avoid font swapping.
        handles; % figure handles;        
        paper; % paper size;   
        open; % Open after figure is available;
    end
    methods (Access = public) %Constructor
        function this = class_export_fig(varargin)
            this.filename = get_varargin(varargin,'filename','Untitled');
            this.format = get_varargin(varargin,'format','jpg');
            this.iscrop = get_varargin(varargin,'iscrop',0);
            this.transparent = get_varargin(varargin,'transparent',1);
            this.res = get_varargin(varargin,'resolution',800);
            this.renderer = get_varargin(varargin,'renderer','opengl');
            this.colorspace = get_varargin(varargin,'colorspace','jpg');
            this.nofontswap = get_varargin(varargin,'fontswap',1);
            this.handles = get_varargin(varargin,'handles',gcf);
            this.paper = get_varargin(varargin,'paper',[0 0 6.5 4]);   
            this.open = get_varargin(varargin,'open',1);            
            [filedir,~,~] = fileparts(this.filename);
            if ~isempty(filedir)
                this.figfile = class_FileIO('fullfilename',[this.filename '.' this.format]);
            else this.figfile = class_FileIO('filedir',cd,'filename',[this.filename '.' this.format]);
            end
        end
        function export(this)
            if ~isempty(this.handles)
                % Adjust properties
                if ~any(strcmpi({'png','pdf','tif','eps'},this.format))
                    this.transparent = 0;
                end
                if any(strcmpi({'pdf','eps'},this.format))
                    this.renderer = 'painters';  % works best for vector format;
                else
                    this.renderer = 'opengl';
                end
                set(this.handles,'unit','inches','PaperUnits','inches','PaperPosition',this.paper);
                strcmd = sprintf('export_fig(');
                strcmd = [strcmd, sprintf('''%s'', ',this.filename)];
                strcmd = [strcmd, sprintf('''-%s'', ',this.format)];
                if this.iscrop == 0, strcmd = [strcmd, sprintf('''-nocrop'', ')]; end;
                if this.transparent == 1, strcmd = [strcmd, sprintf('''-transparent'', ')]; end;
                strcmd = [strcmd, sprintf('''-r%d'', ',this.res)];
                strcmd = [strcmd, sprintf('''-%s'', ',this.renderer)];
                strcmd = [strcmd, sprintf('''-%s'', ',this.colorspace)];
                if this.nofontswap == 1, strcmd = [strcmd, sprintf('''-nofontswap'', ')]; end;                
                strcmd = [strcmd, sprintf('this.handles);')];          
                assignin('base','Printer',this);
                eval(strcmd);                                
                if this.open, winopen(this.figfile.fullfilename); end;
            else
                uh_fprintf('No Figure is available. Exit.\n');                
            end
        end
    end    
    methods (Static)
    end
    methods (Access = private) %Destructor
        function delete(this) % Delete obj.
        end
    end
end
