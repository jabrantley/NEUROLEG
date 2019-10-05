classdef class_patch < class_shape    
    properties (SetAccess = public, GetAccess = public)
        Faces;
        Vertices;
    end
    methods
        %Contructor
        function this = class_patch(varargin)            
            % line properties            
            this.edgestyle = get_varargin(varargin,'edgestyle','-');
            this.edgewidth = get_varargin(varargin,'edgewidth',0.75);
            this.edgecolor = get_varargin(varargin,'edgecolor','k');            
            this.Vertices = get_varargin(varargin,'Vertices',[0 1;1 1;0 0]);
            this.Faces = get_varargin(varargin,'Faces',[1 2 3]); % How to connect the vertices
            this.facecolor = get_varargin(varargin,'facecolor','k');
            this.facealpha = get_varargin(varargin,'facealpha',1);
            this.cdata = get_varargin(varargin,'cdata',[0 0 0 0]);
            this.draw = get_varargin(varargin,'draw',0);
            this.getxydata;            
            if this.draw == 1
                this.drawshape;
            end
        end
        function getArea(this)
            this.area=0;
        end
        function drawshape(this)          
            patchhdl = patch(this.xdata,this.ydata,this.cdata);
            set(patchhdl,'linestyle',this.edgestyle,'edgecolor',this.edgecolor,'linewidth',this.edgewidth,...
                'facecolor',this.facecolor,'facealpha',this.facealpha,'clipping',this.clipping);
        end       
        function getxydata(this)
            for i = 1 : size(this.Vertices,1)
                this.xdata(i) = this.Vertices(this.Faces(i),1);
                this.ydata(i) = this.Vertices(this.Faces(i),2);
            end
        end
    end
    methods(Access=private)
    end
    methods(Static) %static method doesn't require obj
    end
end