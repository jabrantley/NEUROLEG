classdef class_ruler < class_line
    properties                
        ratio = 0.1; % ratio controls the size of whisker.
        tail; % tail control absolute size of whisker;        
    end
    properties (SetAccess = private, GetAccess = public)
    end
    methods
        %Contructor
        function this = class_ruler(varargin)            
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
            % properties
            this.linestyle = get_varargin(varargin,'linestyle','-');
            this.linewidth = get_varargin(varargin,'linewidth',0.75);
            this.linecolor = get_varargin(varargin,'linecolor','k');
            this.facecolor = get_varargin(varargin,'facecolor','k');
            this.clipping = get_varargin(varargin,'clipping','off');
            getlength(this);
            getangle(this);
            getcenter(this);
            this.ratio = get_varargin(varargin,'ratio',0.1);
            this.tail = get_varargin(varargin,'tail',0);
             % Text properties
            this.textobj = class_text;
            this.textobj.string = get_varargin(varargin,'string','');
            this.textobj.position = get_varargin(varargin,'textpos',[this.center.xdata, this.center.ydata]);             
            this.textobj.fontname = get_varargin(varargin,'fontname',this.textobj.fontname);
            this.textobj.fontsize = get_varargin(varargin,'fontsize',this.textobj.fontsize);
            this.textobj.fontweight = get_varargin(varargin,'fontweight',this.textobj.fontweight);
            this.textobj.horizontalalignment = get_varargin(varargin,'horizontalalignment','center');
            this.textobj.verticalalignment = get_varargin(varargin,'verticalalignment','bottom');
            this.textobj.rotation = get_varargin(varargin,'rotation',this.textobj.rotation);
            this.textobj.color = get_varargin(varargin,'textcolor',this.textobj.color);
            this.textobj.backgroundcolor = get_varargin(varargin,'backgroundcolor',this.textobj.backgroundcolor);
            this.textobj.textgap=get_varargin(varargin,'textgap',[0 0]);
            this.textobj.interpreter=get_varargin(varargin,'interpreter',this.textobj.interpreter);
            %--
            this.draw=get_varargin(varargin,'draw',0);           
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
        function drawshape(this)            
            linehdl=line('xdata',this.xdata,'ydata',this.ydata);
            set(linehdl,'linestyle',this.linestyle,'color',this.linecolor,'linewidth',this.linewidth,'clipping',this.clipping);            
            if this.tail == 0
                this.tail = this.len * this.ratio/2;
            end
            %----
            pnt1 = genpoint(this.startpoint,this.tail,this.angle+90);
            pnt2 = genpoint(this.startpoint,this.tail,this.angle-90);
            pnt3 = genpoint(this.endpoint,this.tail,this.angle+90);
            pnt4 = genpoint(this.endpoint,this.tail,this.angle-90);
            line([pnt1.xdata,pnt2.xdata],[pnt1.ydata,pnt2.ydata],'color',this.linecolor,'clipping',this.clipping);
            line([pnt3.xdata,pnt4.xdata],[pnt3.ydata,pnt4.ydata],'color',this.linecolor,'clipping',this.clipping);
            addtext(this);
        end                
    end  
    methods(Access=private)
         function listener_xydata_Callback(this,src,event)
            this.startpoint.xdata = this.xdata(1);
            this.startpoint.ydata = this.ydata(1);
            this.endpoint.xdata = this.xdata(2);
            this.endpoint.ydata = this.ydata(2);
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