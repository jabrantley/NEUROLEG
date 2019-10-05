classdef class_dir < hgsetget;
%======================       
    properties (SetAccess = private, GetAccess = public)
        PCname;
        onedrive;
        eeglab;
        brainstorm;
        fieldtrip;
        figdir;
        datadir;
        currdir;
        root; %matlabcode;
        uhlib;
    end
   
    methods (Access = public) %Constructor
        %Constructor
        function this = class_dir(varargin);
            this.PCname = this.getPCname;
            this.onedrive = this.getonedrive(this.PCname);
            this.currdir = cd;
            this.root = get_varargin(varargin,'root',[this.onedrive, '\UH-research\Avatar Data Analysis\matlabcode']);
            this.eeglab = get_varargin(varargin,'eeglab',[this.root, '\eeglab13_5_4b']);
            % this.fieldtrip = get_varargin(varargin,'fieldtrip',[this.root, '\fieldtrip-20160315']);
            this.fieldtrip = get_varargin(varargin,'fieldtrip',[this.root, '\fieldtrip-20150224']);
            this.brainstorm = get_varargin(varargin,'brainstorm',[this.root, '\brainstorm3']);
            this.figdir = get_varargin(varargin,'figdir',[this.root, '\Report\Photos']);
            this.datadir = get_varargin(varargin,'datadir',this.root);
            thisfilename = mfilename('fullpath');   % Get uhlib path;
            [thisfolder,~,~] = fileparts(thisfilename);
            this.uhlib = this.getparent(thisfolder);
        end
    end
    methods(Static)
            function PCname=getPCname
                [~,PCname]=system('hostname');
                % last char is a space;
                PCname(isspace(PCname))=[];                
            end            
            function onedrive=getonedrive(PCname)
                if strcmpi(PCname,'PhatLuu-DellPC')
                    onedrive='C:\Users\phat\OneDrive';
                else
                    onedrive='C:\Users\ptluu2\OneDrive';
                end
            end
            function pdir=getparent(thisdir,varargin)
                if nargin==1
                    level=1;
                elseif nargin==2
                    level=varargin{1};
                else
                    level=get_varargin(varargin,'level',1);
                end
                temp=thisdir;
                for i=1:level
                    temp=fileparts(temp);
                end          
                pdir=temp;
            end
        end
end
