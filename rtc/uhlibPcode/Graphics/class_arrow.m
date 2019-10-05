classdef class_arrow < class_line & class_shape
    properties
        theta1 = 30;
        theta2 = 60;
        ratio = 0.1;
        startanchor = class_patch;
        endanchor = class_patch;
        type; % start, end, both: control the arrow anchor;
    end
    properties (SetAccess = private, GetAccess = public)
    end
    methods
        %Contructor
        function this = class_arrow(varargin)
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
            this.xdata = get_varargin(varargin,'xdata',[0 0]);
            this.ydata = get_varargin(varargin,'ydata',[1 1]);
             % Check type of input;
            if this.ispoints == 1; this.getxydata;
            else this.getpoints;
            end            
            this.getcenter;
            % arrow properties
            this.type = get_varargin(varargin,'type','end');
            this.len = get_varargin(varargin,'length',0);
            this.angle = get_varargin(varargin,'angle',0);
            this.linestyle = get_varargin(varargin,'linestyle','-');
            this.linewidth = get_varargin(varargin,'linewidth',0.75);
            this.linecolor = get_varargin(varargin,'linecolor','k'); 
            this.clipping = get_varargin(varargin,'clipping','off');
            % arrow properties. Patch object
            this.theta1 = get_varargin(varargin,'theta1',30);
            this.theta2 = get_varargin(varargin,'theta2',60);
            this.ratio = get_varargin(varargin,'ratio',0.1);
            this.cdata = get_varargin(varargin,'cdata',[0 0 0 0]);
            this.facecolor = get_varargin(varargin,'facecolor','k');
            this.facealpha = get_varargin(varargin,'facealpha',1);
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
            this.draw=get_varargin(varargin,'draw',1);
            %----Get properties.
            this.getlength;
            this.getangle;
            this.get_endanchor;
            this.get_startanchor;           
            if this.draw == 1
                this.drawshape;
            end
        end
        function getArea(this)
            this.area=0;
        end
        function drawshape(this)
            linehdl=line('xdata',this.xdata,'ydata',this.ydata);
            set(linehdl,'linestyle',this.linestyle,'color',this.linecolor,...
                'linewidth',this.linewidth,'clipping',this.clipping);
            if strcmpi(this.type,'start'), this.startanchor.drawshape;
            elseif strcmpi(this.type,'end'), this.endanchor.drawshape;
            else
                this.startanchor.drawshape;
                this.endanchor.drawshape;
            end
            addtext(this);
        end
        
        function get_endanchor(this)
            pnt3 = midpoint(this.endpoint,this.startpoint,'ratio',this.ratio);
            r1 = distance(this.endpoint,pnt3)*sin(degtorad(this.theta2))/sin(degtorad(this.theta2-this.theta1));
            pnt2 = genpoint(this.endpoint,r1, 180+(this.angle+this.theta1/2));
            pnt4 = genpoint(this.endpoint,r1, 180+(this.angle-this.theta1/2));
            this.endanchor.xdata=[this.endpoint.xdata, pnt2.xdata, pnt3.xdata, pnt4.xdata];
            this.endanchor.ydata=[this.endpoint.ydata, pnt2.ydata, pnt3.ydata, pnt4.ydata];                        
        end
        function get_startanchor(this)
            pnt3 = midpoint(this.startpoint,this.endpoint,'ratio',this.ratio);      
            r1 = distance(this.startpoint,pnt3)*sin(degtorad(this.theta2))/sin(degtorad(this.theta2-this.theta1))
            pnt2 = genpoint(this.startpoint,r1, (this.angle+this.theta1/2))
            pnt4 = genpoint(this.startpoint,r1, (this.angle-this.theta1/2));
            xdata=[this.startpoint.xdata, pnt2.xdata, pnt3.xdata, pnt4.xdata];
            ydata=[this.startpoint.ydata, pnt2.ydata, pnt3.ydata, pnt4.ydata];
            this.startanchor.xdata = xdata;
            this.startanchor.ydata = ydata;
        end
    end
    methods(Access=private)
    end
    methods(Static) %static method doesn't require obj
    end
end