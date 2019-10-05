classdef class_pointscloud < class_shape
    properties                     
    end
    methods
        %Contructor
        function this = class_pointscloud(varargin)
            this.xdata = get_varargin(varargin,'xdata', [0 0]);
            this.ydata = get_varargin(varargin,'ydata', [1 1]);            
            % Marker properties
            this.marker = get_varargin(varargin,'marker',this.marker);         
            this.markersize = get_varargin(varargin,'markersize',this.markersize);
            this.markerfacecolor = get_varargin(varargin,'markerfacecolor',this.markerfacecolor);
            this.markeredgecolor = get_varargin(varargin,'markeredgecolor',this.markeredgecolor);            
            % draw option
            this.draw = get_varargin(varargin,'show',0);            
            if this.draw == 1
                this.drawshape;
            end
        end
        function getArea(this)
            this.area=0;
        end
        function drawshape(this)
            line('xdata',this.xdata,'ydata',this.ydata,...
                'linestyle','none',...
                'marker',this.marker,'markersize',this.markersize,...
                'markerfacecolor',this.markerfacecolor,'markeredgecolor',this.markeredgecolor);
        end            
    end
    methods(Access=private)
    end
    methods(Static) %static method doesn't require obj
    end
end