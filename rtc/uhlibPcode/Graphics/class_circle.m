classdef class_circle < class_shape    
    properties (SetObservable)
        r;
    end    
    methods
        %Contructor
        function this = class_circle(center,r,varargin)
            if nargin == 0
                this.center = class_point;
                this.r = 1;            
            else           
                this.center = center;
                this.r = r;
                this.linestyle=get_varargin(varargin,'linestyle','-');
                this.linewidth=get_varargin(varargin,'linewidth',0.75);
                this.edgecolor=get_varargin(varargin,'edgecolor','k');
                this.facecolor=get_varargin(varargin,'facecolor','w');
                this.facealpha=get_varargin(varargin,'facealpha',0);
                this.marker=get_varargin(varargin,'marker','o');
                this.markersize=get_varargin(varargin,'markersize',4);
                this.markeredgecolor=get_varargin(varargin,'markeredgecolor','k');
                this.markerfacecolor=get_varargin(varargin,'markerfacecolor','w');  
                this.draw=get_varargin(varargin,'draw',0);  
            end
            obsgroup={'r','center'};
            for i=1:length(obsgroup)
                addlistener(this,obsgroup{i},'PostSet',@this.listener_Callback);
            end
            getvertex(this); 
            getArea(this);
            if this.draw ==1
                this.drawshape;
            end
        end
        % Specify Abstract method defined in superclass
        function getArea(this)
            this.area=pi*this.r^2;
        end     
        function drawshape(this)
            theta=linspace(0,2*pi,200);
            x=this.center.xdata+this.r*cos(theta);
            y=this.center.ydata+this.r*sin(theta);
            patchhdl=patch(x,y,this.facecolor);
            set(patchhdl,'linestyle',this.linestyle,'linewidth',this.linewidth,'edgecolor',this.edgecolor);   
            set(this.center,'marker',this.marker,'markersize',this.markersize,...
                'markerfacecolor',this.markerfacecolor,'markeredgecolor',this.markeredgecolor);
        end
        function getvertex(this)
            this.east.xdata = this.center.xdata+this.r;
            this.east.ydata = this.center.ydata;
            this.north.xdata = this.center.xdata;
            this.north.ydata = this.center.ydata+this.r;
            this.west.xdata = this.center.xdata-this.r;
            this.west.ydata = this.center.ydata;
            this.south.xdata = this.center.xdata;
            this.south.ydata = this.center.ydata-this.r;
        end
    end
    methods(Access=private)
        function listener_Callback(this,src,event)
            this.east = this.center + class_point(this.r,0);
            this.north = this.center + class_point(0, this.r);
            this.west = this.center + class_point(-this.r,0);
            this.south = this.center + class_point(0,-this.r);           
        end
    end
    methods(Static) %static method doesn't require obj      
    end
end