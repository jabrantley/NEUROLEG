classdef class_point < class_shape
    properties
    end
    methods
        %Contructor
        function this = class_point(varargin)
            % position input;
            posin = 0;
            for i = 1 : 2 : nargin
                if strcmpi(varargin{i},'position')
                    posin = 1 ;
                    break;
                end
            end
            this.xdata = get_varargin(varargin,'xdata',0);
            this.ydata = get_varargin(varargin,'ydata',0);
            this.position = get_varargin(varargin,'position',[0 0]);
             % Check type of input;
            if posin == 1; this.get_xydata;
            else this.get_position;
            end
            %-------------------------------------------------------------
            this.marker=get_varargin(varargin,'marker','o');
            this.markersize=get_varargin(varargin,'markersize',4);
            this.markeredgecolor=get_varargin(varargin,'markeredgecolor','k');
            this.markerfacecolor=get_varargin(varargin,'markerfacecolor','w');
            this.clipping = get_varargin(varargin,'clipping','off');
            % Text properties
            this.textobj = class_text;
            this.textobj.string = get_varargin(varargin,'string','');
            this.textobj.position = [this.xdata this.ydata];            
            this.textobj.fontname = get_varargin(varargin,'fontname',this.textobj.fontname);
            this.textobj.fontsize = get_varargin(varargin,'fontsize',this.textobj.fontsize);
            this.textobj.fontweight = get_varargin(varargin,'fontweight',this.textobj.fontweight);
            this.textobj.horizontalalignment = get_varargin(varargin,'horizontalalignment','center');
            this.textobj.verticalalignment = get_varargin(varargin,'verticalslignment',this.textobj.verticalalignment);
            this.textobj.rotation = get_varargin(varargin,'rotation',this.textobj.rotation);
            this.textobj.color = get_varargin(varargin,'textcolor',this.textobj.color);
            this.textobj.backgroundcolor = get_varargin(varargin,'backgroundcolor',this.textobj.backgroundcolor);
            this.textobj.textgap=get_varargin(varargin,'textgap',this.textobj.textgap);
            this.textobj.interpreter=get_varargin(varargin,'interpreter',this.textobj.interpreter);
            %--
            this.draw = get_varargin(varargin,'draw',0);
            addlistener(this,'xdata','PostSet',@this.listener_xydata_Callback);
            addlistener(this,'ydata','PostSet',@this.listener_xydata_Callback);
            addlistener(this,'position','PostSet',@this.listener_position_Callback);
            if this.draw == 1
                this.drawshape;
            end
        end
        function getArea(this)
            this.area=0;
        end
        function drawshape(this)
            linehdl=line('xdata',this.xdata,'ydata',this.ydata);
            set(linehdl,'marker',this.marker,'markersize',this.markersize,...
                'markeredgecolor',this.markeredgecolor,'markerfacecolor',this.markerfacecolor,...
                'clipping',this.clipping);
            this.addtext;
        end
        function newpoint = midpoint(point1,point2,varargin)
            ratio=get_varargin(varargin,'ratio',0.5);
            newpoint=class_point;
            newpoint.xdata = point1.xdata + (point2.xdata-point1.xdata)*ratio;
            newpoint.ydata = point1.ydata + (point2.ydata-point1.ydata)*ratio;
        end
        function newpoint = plus(point1,point2) %operator overloading
            newpoint = class_point;
            newpoint.xdata = point1.xdata+point2.xdata;
            newpoint.ydata = point1.ydata+point2.ydata;
        end
        function newpoint = minus(point1,point2) %operator overloading
            newpoint = class_point;
            newpoint.xdata = point1.xdata-point2.xdata;
            newpoint.ydata = point1.ydata-point2.ydata;
        end
        function newpoint = genpoint(point1,r,theta)
            % Generate new point from given point1, radius and angle theta
            newpoint = class_point;
            newpoint.xdata = point1.xdata + r*cos(degtorad(theta));
            newpoint.ydata = point1.ydata + r*sin(degtorad(theta));
        end
        function len = distance(point1,point2)
            len=norm([point1.xdata-point2.xdata,...
                point1.ydata-point2.ydata]);
        end
        function get_xydata(this)
            pos = this.position;
            this.xdata = pos(1);
            this.ydata = pos(2);
        end
        function get_position(this)
            this.position = [this.xdata, this.ydata];            
        end
    end
    methods(Access=private)
        function listener_xydata_Callback(this,src,event)
            this.position = [this.xdata, this.ydata];            
            this.textobj.position = this.position;
        end
        function listener_position_Callback(this,src,event)
            pos = this.position;
            this.xdata = pos(1);
            this.ydata = pos(2);
            this.textobj.position = pos;               
        end
    end
    methods(Static) %static method doesn't require obj
    end
end