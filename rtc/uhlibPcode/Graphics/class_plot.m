classdef class_plot < handle & hgsetget    
    properties
        % Data properties        
        cdata;
        clipping = 'off';
        % axes propertis
        xlabel = class_text;
        ylabel = class_text;
        % marker properties
        marker ='x';
        markersize = 4;
        markeredgecolor ='k';
        markerfacecolor ='w';
        % line properties
        linecolor = 'k';
        linewidth = 0.75;
        linestyle = '-';
        % Face properties
        facecolor = 'b';
        edgecolor = 'k';
        edgestyle = '-';
        edgewidth = 0.75;
        facealpha = 1;        
        % Text properties;
        string = '';
        textobj;
        textgap = [0 0];
        fontname = 'Times New Roman';
        fontsize = 8;
        fontweight = 'normal';
        textcolor = 'k';
        backgroundcolor = 'none';
        horizontalalignment = 'center';
        verticalalignment = 'middle';
        rotation = 0;
        interpreter = 'tex';
        % Control option to show the plot
        show = 0;
    end
    properties (SetObservable)
        xdata;
        ydata;
        zdata;
    end
    methods
     function setproperties(this,varargin)
            if length(varargin)>=2
                for i=1:2:length(varargin)
                    param=varargin{i};
                    val=varargin{i+1};
                    this.(param)=val;
                end
            end
            this.showplot;
     end
    end
    methods (Abstract)  %Use Abstract attribute to implement polymorphism
        showplot(obj) % Draw objects, could be in any shapes defined in subclasses        
    end   
end
        
