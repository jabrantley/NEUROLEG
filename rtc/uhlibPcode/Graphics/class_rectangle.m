classdef class_rectangle < class_shape
    properties (SetAccess = public, GetAccess = public)
        width
        height       
        numvertex = 4; % number of vertex in rectangle.
        ispoints = 0; % If center point is accepted as input;
        vertex1;
        vertex2;
        vertex3;
        vertex4;
    end
    methods
        %Contructor
        function this=class_rectangle(varargin)                        
            % position
            for i = 1 : 2 : nargin
                if strcmpi(varargin{i},'center')
                    this.ispoints = 1 ;
                    break;
                else this.ispoints = 0; 
                end
            end
            this.center = get_varargin(varargin,'center',class_point);
            this.width = get_varargin(varargin,'width',1);
            this.height = get_varargin(varargin,'height',1);
            this.position = get_varargin(varargin,'position',[0 0 1 1]); % left corner, width, height
            this.clipping = get_varargin(varargin,'clipping','off');
            this.east = class_point;
            this.west = class_point;
            this.north = class_point;
            this.south = class_point;
            this.vertex1 = class_point;
            this.vertex2 = class_point;
            this.vertex3 = class_point;
            this.vertex4 = class_point;         % Next version: use array object
            % Check type of input;
            if this.ispoints == 1;        
                this.position = [this.center.xdata-this.width/2,this.center.ydata-this.height/2,...
                                 this.width, this.height];                                
            else this.getcenter;                
            end
            this.getvertex;
            this.getxydata;
            % color
            this.cdata = get_varargin(varargin,'cdata',[0 0 0 0]);
            this.facecolor = get_varargin(varargin,'facecolor',this.facecolor);
            this.facealpha = get_varargin(varargin,'facealpha',this.facealpha);
            % Style
            this.edgestyle = get_varargin(varargin,'edgestyle',this.edgestyle);
            this.edgecolor = get_varargin(varargin,'edgecolor',this.edgecolor);
            this.edgewidth = get_varargin(varargin,'edgewidth',this.edgewidth);
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
            getArea(this);
            % Set observation;
            addlistener(this,'center','PostSet',@this.listener_center_Callback);
            addlistener(this,'position','PostSet',@this.listener_position_Callback);
            if this.draw==1
                this.drawshape;
            end
        end
    end
    methods
        function getArea(this)
            this.area=this.width*this.height;
        end
        function drawshape(this)
            patchhdl=patch(this.xdata,this.ydata,this.cdata);
            set(patchhdl,'linestyle',this.edgestyle,'edgecolor',this.edgecolor,...
                'facecolor',this.facecolor,'facealpha',this.facealpha,'cdata',this.cdata,'clipping',this.clipping);
            this.addtext;
        end
        function getvertex(this)
            xfactor = [-1 -1 1 1];
            yfactor = [-1 1 1 -1];                 
            this.vertex1.xdata = this.center.xdata + xfactor(1)*this.width/2;
            this.vertex1.ydata = this.center.ydata + yfactor(1)*this.height/2;
            this.vertex2.xdata = this.center.xdata + xfactor(2)*this.width/2;
            this.vertex2.ydata = this.center.ydata + yfactor(2)*this.height/2;
            this.vertex3.xdata = this.center.xdata + xfactor(3)*this.width/2;
            this.vertex3.ydata = this.center.ydata + yfactor(3)*this.height/2;
            this.vertex4.xdata = this.center.xdata + xfactor(4)*this.width/2;
            this.vertex4.ydata = this.center.ydata + yfactor(4)*this.height/2;           
            this.east.xdata = this.center.xdata+this.width/2;
            this.east.ydata = this.center.ydata;
            this.north.xdata = this.center.xdata;
            this.north.ydata = this.center.ydata+this.height/2;
            this.west.xdata = this.center.xdata-this.width/2;
            this.west.ydata = this.center.ydata;
            this.south.xdata = this.center.xdata;
            this.south.ydata = this.center.ydata-this.height/2;
        end
        function getxydata(this)
            xfactor = [-1 -1 1 1];
            this.xdata=[this.center.xdata + xfactor(1)*this.width/2,...
                this.center.xdata + xfactor(2)*this.width/2,...
                this.center.xdata + xfactor(3)*this.width/2,...
                this.center.xdata + xfactor(4)*this.width/2];
            yfactor = [-1 1 1 -1];
            this.ydata=[this.center.ydata + yfactor(1)*this.height/2,...
                this.center.ydata + yfactor(2)*this.height/2,...
                this.center.ydata + yfactor(3)*this.height/2,...
                this.center.ydata + yfactor(4)*this.height/2];
        end        
        function getcenter(this)
            pos = this.position;
            this.center.xdata = pos(1) + pos(3)/2;
            this.center.ydata = pos(2) + pos(4)/2;
            this.width = pos(3);
            this.height = pos(4);
        end
    end
    methods(Static) %static method doesn't require obj
    end
    methods(Access=private)
        function listener_center_Callback(this,src,event)
            getxdata(this);
            getydata(this);
            getArea(this);
            this.textpoint=this.center;
        end
        function listener_position_Callback(this,src,event)
            this.getcenter;         
            this.getvertex;
            this.getxydata;
            this.getArea;
            this.textobj.position = [this.center.xdata, this.center.ydata];            
        end
    end
end