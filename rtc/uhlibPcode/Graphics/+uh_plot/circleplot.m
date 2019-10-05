classdef circleplot < class_plot
    properties                        
       rlim = class_circle;
       rtick = class_circle;
       majortick = class_line;
       minortick = class_line;
       majortickval;
       minortickval;
       rtickval;
       rlimval;
    end
    methods
        %Contructor
        function this = circleplot(xdata,ydata,varargin)
            this.xdata = tocolumn(xdata);
            this.ydata = tocolumn(ydata);            
            this.rlimval = get_varargin(varargin,'rlim',1);
            this.rtickval = get_varargin(varargin,'rtick',this.rlimval/2);
            this.majortickval = 0: get_varargin(varargin,'majortick',90) : 360;
            this.minortickval = 0: get_varargin(varargin,'minortick',30) : 360;
            
            this.linestyle=get_varargin(varargin,'linestyle',this.linestyle);
            this.linewidth=get_varargin(varargin,'linewidth',this.linewidth);            
            this.linecolor=get_varargin(varargin,'linecolor',this.linecolor);                       
            
            this.showplot;
        end
        function showplot(this)
            this.rlim  = class_circle(class_point,this.rlimval,'marker','none',...
                'linestyle','-','edgecolor','k','draw',1); hold on;
            for i=1:length(this.rtickval)
                this.rtick(i) = class_circle(class_point,this.rtickval(i),'marker','none',...
                    'linestyle',':','edgecolor','k','draw',1);
            end
            for i=1:length(this.majortickval)
                this.majortick(i)=class_line(class_point,genpoint(class_point,this.rlimval,this.majortickval(i)));
            end
            for i=1:length(this.minortickval)
                this.minortick(i)=class_line(class_point,genpoint(class_point,this.rlimval,this.minortickval(i)),...
                    'linestyle',':');
            end
            line(this.ydata.*cos(-degtorad(this.xdata-90)),this.ydata.*sin(-degtorad(this.xdata-90)),'linestyle',this.linestyle,'linewidth',this.linewidth,...
                'color',this.linecolor);
            alpha(0);
        end
    end
    methods(Access=private)
    end
    methods(Static) %static method doesn't require obj      
    end
end