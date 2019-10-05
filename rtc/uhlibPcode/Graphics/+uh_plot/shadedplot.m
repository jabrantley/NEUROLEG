classdef shadedplot < class_plot
    properties        
        meanline;
        highdata;
        lowdata;
        shaded = class_patch;
        devdata;
    end
    methods
        %Contructor
        function this = shadedplot(xdata,ydata,varargin)
            this.xdata = uh_tocolumn(xdata);
            this.ydata = uh_tocolumn(ydata);
            this.devdata = get_varargin(varargin,'std',0);
            this.highdata = get_varargin(varargin,'highdata',this.ydata);
            this.lowdata = get_varargin(varargin,'lowdata',this.ydata);            
            if this.devdata ~=0
                this.getlowhighdata;
            end
            this.highdata = uh_tocolumn(this.highdata);
            this.lowdata = uh_tocolumn(this.lowdata);                 
            % Patch style;
            this.facecolor = get_varargin(varargin,'facecolor',this.facecolor);
            this.facealpha = get_varargin(varargin,'facealpha',this.facealpha);
            this.edgecolor = get_varargin(varargin,'edgecolor','none');
            this.edgestyle = get_varargin(varargin,'edgestyle','none');
            this.edgewidth = get_varargin(varargin,'edgewidth',this.edgewidth);           
            % For line properties
            this.linestyle = get_varargin(varargin,'linestyle',this.linestyle);
            this.linewidth = get_varargin(varargin,'linewidth',this.linewidth);
            this.linecolor = get_varargin(varargin,'linecolor',this.linecolor);
            this.marker = get_varargin(varargin,'marker',this.marker);         
            this.markersize = get_varargin(varargin,'markersize',this.markersize);
            this.markerfacecolor = get_varargin(varargin,'markerfacecolor',this.markerfacecolor);
            this.markeredgecolor = get_varargin(varargin,'markeredgecolor',this.markeredgecolor);
            % Show plot option
            this.show = get_varargin(varargin,'show',0);
            this.get_plotproperties;
            % Plot
            if this.show == 1
                this.showplot;
            end            
        end
        function getlowhighdata(this)
            this.highdata = this.ydata + this.devdata;
            this.lowdata = this.ydata - this.devdata;
        end
        function get_plotproperties(this)
            this.shaded.xdata = [this.xdata; flipud(this.xdata)];
            this.shaded.ydata = [this.highdata; flipud(this.lowdata)];
            this.shaded.cdata = zeros(1,length(this.shaded.xdata));            
            set(this.shaded,'facecolor',this.facecolor,'facealpha',this.facealpha,...
                'linestyle',this.edgestyle,'edgecolor',this.edgecolor,'linewidth',this.edgewidth);                         
        end
        function showplot(this)
            this.shaded.drawshape; hold on;
             % Mean line properties
            this.meanline = line('xdata',this.xdata,'ydata',this.ydata);
            set(this.meanline,'linestyle',this.linestyle,'linewidth',this.linewidth,'color',this.linecolor,...
                'marker',this.marker,'markersize',this.markersize,...
                'markerfacecolor',this.markerfacecolor,'markeredgecolor',this.markeredgecolor);
        end
    end  
    methods(Access=private)       
    end
    methods(Static) %static method doesn't require obj      
    end
end