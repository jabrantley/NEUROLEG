classdef class_line < class_shape
    properties
        len;
        angle;     
        ispoints = 0; % it the inputs are points format.
    end
    properties (SetObservable)
        startpoint = class_point;
        endpoint = class_point;
    end
    methods
        %Contructor
        function this = class_line(varargin)
            % position
            for i = 1 : 2 : nargin
                if strcmpi(varargin{i},'start')
                    this.ispoints = 1 ;
                    break;
                else this.ispoints = 0; 
                end
            end
            this.startpoint = get_varargin(varargin,'start',class_point);
            this.endpoint = get_varargin(varargin,'end',class_point);
            this.xdata = get_varargin(varargin,'xdata',[0 1]);
            this.ydata = get_varargin(varargin,'ydata',[0 1]);
             % Check type of input;
            if this.ispoints == 1; this.getxydata;
            else this.getpoints;
            end
            getcenter(this);
            this.linestyle = get_varargin(varargin,'linestyle','-');
            this.linewidth = get_varargin(varargin,'linewidth',0.75);
            this.linecolor = get_varargin(varargin,'linecolor','k');
            this.clipping = get_varargin(varargin,'clipping','off');
           % Text properties
            this.textobj = class_text;
            this.textobj.string = get_varargin(varargin,'string','');
            this.textobj.position = [this.center.xdata this.center.ydata];            
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
            this.draw=get_varargin(varargin,'draw',0);            
            this.getlength;
            this.getangle;
            this.getxydata;
            % Add listener to the class;
            addlistener(this,'xdata','PostSet',@this.listener_xydata_Callback);
            addlistener(this,'ydata','PostSet',@this.listener_xydata_Callback);
            addlistener(this,'startpoint','PostSet',@this.listener_updatepoint_Callback);
            addlistener(this,'endpoint','PostSet',@this.listener_updatepoint_Callback);
            if this.draw == 1
                this.drawshape;
            end
        end
        function getArea(this)
            this.area=0;
        end
        function getxydata(this)
            this.xdata=[this.startpoint.xdata this.endpoint.xdata];
            this.ydata=[this.startpoint.ydata this.endpoint.ydata];
        end
        function getpoints(this)
            xtemp = this.xdata;
            ytemp = this.ydata;
            this.startpoint.xdata = xtemp(1);
            this.startpoint.ydata = ytemp(1);
            this.endpoint.xdata = xtemp(2);
            this.endpoint.ydata = ytemp(2);
        end
        function drawshape(this)
            linehdl=line('xdata',this.xdata,'ydata',this.ydata);
            set(linehdl,'linestyle',this.linestyle,'color',this.linecolor,'linewidth',this.linewidth,...
                'clipping',this.clipping);            
            addtext(this);
        end
        function len = getlength(this)
            len=norm([this.endpoint.xdata-this.startpoint.xdata,...
                this.endpoint.ydata-this.startpoint.ydata]);
            this.len=len;
        end      
        function ang = getangle(this)
            ang=atan2(this.endpoint.ydata-this.startpoint.ydata,this.endpoint.xdata-this.startpoint.xdata);
            this.angle=radtodeg(ang);
        end
        function getcenter(this)
            this.center = midpoint(this.startpoint,this.endpoint);
        end       
    end
    methods(Access=private)
         function listener_xydata_Callback(this,src,event)
            xtemp = this.xdata;
            ytemp = this.ydata;
            this.startpoint.xdata = xtemp(1);
            this.startpoint.ydata = ytemp(1);
            this.endpoint.xdata = xtemp(2);
            this.endpoint.ydata = ytemp(2);
            this.getcenter;
            this.getlength;
            this.getangle;
        end
        function listener_updatepoint_Callback(this,src,event)
            this.getxydata;
            this.getcenter;
            this.getlength;
            this.getangle;            
        end
    end
    methods(Static) %static method doesn't require obj
    end
end