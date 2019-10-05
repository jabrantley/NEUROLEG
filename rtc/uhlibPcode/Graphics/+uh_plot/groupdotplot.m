classdef groupdotplot < class_plot
    properties                        
        numbar; %number of bar
        groupdot;
        meanline;
    end
    methods
        %Contructor
        function this = groupdotplot(xdata,ydata,varargin)
            this.xdata = uh_torow(xdata);
            this.ydata = uh_tocolumn(ydata);            
            this.numbar = length(xdata); 
            this.xdata = repmat(this.xdata,size(this.ydata,1),1);
            
            % Marker properties
            this.markerfacecolor = get_varargin(varargin,'markerfacecolor',this.markerfacecolor);
            this.markeredgecolor = get_varargin(varargin,'markeredgecolor',this.markeredgecolor);  
            this.marker = get_varargin(varargin,'marker',this.marker);  
            this.markersize = get_varargin(varargin,'markersize',this.markersize);  
            
            % Mean line properties
            this.linestyle = get_varargin(varargin,'linestyle','none');
            this.linewidth = get_varargin(varargin,'linewidth',this.linewidth);
            this.linecolor = get_varargin(varargin,'linecolor',this.linecolor);            
                       
            this.showplot;
        end
        function showplot(this)
            this.groupdot =  line(this.xdata,this.ydata);
            set(this.groupdot,'linestyle','none','marker',this.marker,...
                'markersize',this.markersize,'markerfacecolor',this.markerfacecolor,...
                'markeredgecolor',this.markeredgecolor);            
            this.meanline = line(this.xdata(1,[1,end]),mean(mean(this.ydata)).*[1,1]);
            set(this.meanline,'linestyle',this.linestyle,'linewidth',this.linewidth,...
                'color',this.linecolor);
        end
    end  
    methods(Access=private)       
    end
    methods(Static) %static method doesn't require obj      
    end
end