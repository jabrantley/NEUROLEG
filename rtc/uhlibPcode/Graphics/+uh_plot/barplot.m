classdef barplot < class_plot
    properties                
        highdata;
        lowdata;
        devdata; % deviation;
        errorbar = class_ruler;
        barobj = class_rectangle;
        barwidth;
        numbar; % number of bar
        tail;   % Whisker size
        groupnames;
    end
    methods
        %Contructor
        function this = barplot(xdata,ydata,varargin)
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
            this.numbar = length(xdata);     
            % For bar properties
            this.groupnames = get_varargin(varargin,'xlabel','');
            this.facecolor = get_varargin(varargin,'facecolor',[0 0 1]);
            this.facealpha = get_varargin(varargin,'facealpha',this.facealpha);
            this.edgecolor = get_varargin(varargin,'edgecolor',this.edgecolor);
            this.edgestyle = get_varargin(varargin,'edgestyle',this.edgestyle);
            this.edgewidth = get_varargin(varargin,'edgewidth',this.edgewidth);
            this.barwidth = get_varargin(varargin,'barwidth',0.5);
            
            % For ruler properties
            this.linestyle = get_varargin(varargin,'linestyle',this.linestyle);
            this.linewidth = get_varargin(varargin,'linewidth',this.linewidth);
            this.linecolor = get_varargin(varargin,'linecolor',this.linecolor);            
            this.marker = get_varargin(varargin,'marker',this.marker);         
            this.markersize = get_varargin(varargin,'markersize',this.markersize);
            this.markerfacecolor = get_varargin(varargin,'markerfacecolor',this.markerfacecolor);
            this.markeredgecolor = get_varargin(varargin,'markeredgecolor',this.markeredgecolor);
            this.string = get_varargin(varargin,'string','');
            this.textgap = get_varargin(varargin,'textgap',[0 0]);
            this.tail = get_varargin(varargin,'tail',0.1);
             % Show plot option
            this.show = get_varargin(varargin,'show',0);
            this.get_plotproperties;
            % Plot
            if this.show == 1
                this.showplot;
            end
        end
        function showplot(this)            
            for i=1:length(this.xdata)    
                this.barobj(i).drawshape;
                this.errorbar(i).drawshape;
                if ~isempty(this.groupnames)
                    this.xlabel(i).string = this.groupnames{i};
                    this.xlabel(i).showtext;
                end
            end
        end    
        function getlowhighdata(this)
            for i = 1 : length(this.ydata)
                if this.ydata(i) > 0
                    this.highdata(i) = this.ydata(i) + this.devdata(i);
                    this.lowdata(i) = this.ydata(i);
                else
                    this.highdata(i) = this.ydata(i);
                    this.lowdata(i) = this.ydata(i) - this.devdata(i);
                end
            end
        end
        function get_plotproperties(this)
            if length(this.xdata) == 1, recwidth = this.barwidth;
            else, recwidth = (this.xdata(end) - this.xdata(1))/(length(this.xdata)-1)*this.barwidth;
            end
            for i = 1 : length(this.xdata)
                % Position
                thiscenter = class_point('xdata',this.xdata(i),'ydata', this.ydata(i)/2);
                this.barobj(i) = class_rectangle('center',thiscenter,'width',recwidth,'height',this.ydata(i));
                % Error bar
                this.errorbar(i).xdata = [this.xdata(i), this.xdata(i)];
                this.errorbar(i).ydata = [this.lowdata(i), this.highdata(i)];                
                % Label text
                this.xlabel(i).position = [thiscenter.xdata, 0];                
                % Objects properties
                % bar object properties
                set(this.barobj(i),'linestyle',this.edgestyle,'edgecolor',this.edgecolor,...
                    'linewidth',this.edgewidth,'facecolor',this.facecolor,'facealpha',this.facealpha);
                % Error bar properties
                set(this.errorbar(i),'linewidth',this.linewidth,'linecolor',this.linecolor,'tail',this.tail);
                set(this.errorbar(i).endpoint.textobj,'string',this.string,'textgap',this.textgap);
            end
            
        end
    end
    methods(Access=private)
    end
    methods(Static) %static method doesn't require obj
    end
end