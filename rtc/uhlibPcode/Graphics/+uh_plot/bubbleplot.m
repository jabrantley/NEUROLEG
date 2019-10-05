classdef bubbleplot < class_plot
    properties                        
       bubble = class_circle;
    end
    methods
        %Contructor
        function this = bubbleplot(xdata,ydata,zdata,varargin)
            this.xdata = tocolumn(xdata);
            this.ydata = tocolumn(ydata);            
            this.zdata = tocolumn(zdata);
            
            this.linestyle=get_varargin(varargin,'linestyle',this.linestyle);
            this.linewidth=get_varargin(varargin,'linewidth',this.linewidth);
            this.edgecolor=get_varargin(varargin,'edgecolor','r');
            this.facecolor=get_varargin(varargin,'facecolor',this.facecolor);
            this.facealpha=get_varargin(varargin,'facealpha',0.5);
            this.marker=get_varargin(varargin,'marker',this.marker);
            this.markersize=get_varargin(varargin,'markersize',this.markersize);
            this.markeredgecolor=get_varargin(varargin,'markeredgecolor',this.markeredgecolor);
            this.markerfacecolor=get_varargin(varargin,'markerfacecolor',this.markerfacecolor);
            
            this.showplot;
        end
        function showplot(this)
            for i=1:length(this.xdata)
                this.bubble(i) = class_circle(class_point(this.xdata(i),this.ydata(i)),this.zdata(i),...
                    'linestyle',this.linestyle,'edgecolor',this.edgecolor,'linewidth',this.linewidth,...
                    'facecolor',this.facecolor,'draw',1); hold on;
                setproperties(this.bubble(i).center,'marker',this.marker,'markersize',this.markersize,...
                    'markerfacecolor',this.markerfacecolor,'markeredgecolor',this.markeredgecolor);
                alpha(this.facealpha);
            end
        end
    end  
    methods(Access=private)       
    end
    methods(Static) %static method doesn't require obj      
    end
end