classdef class_rectangle_mat < class_shape   
    properties (SetAccess = public, GetAccess = public)                
        rect;
        rows;
        cols;
        width;
        height;
        gap;        
    end    
    methods
        %Contructor
        function this = class_rectangle_mat(varargin)
            this.rows = get_varargin(varargin,'rows',2);
            this.cols = get_varargin(varargin,'cols',3);
            this.position = get_varargin(varargin,'position',[0 0 1 1]);
            this.draw = get_varargin(varargin,'draw',0);
            this.gap = get_varargin(varargin,'gap',[0 0]);            
            this.getobj;
            % Set observation;
            addlistener(this,'center','PostSet',@this.listener_center_Callback);
            addlistener(this,'position','PostSet',@this.listener_position_Callback);            
            if this.draw==1
                this.drawshape;
            end
        end
    end
    methods
        function getobj(this)
            this.width = this.position(3);
            this.height = this.position(4);
            recwidth = (this.width - (this.cols-1)*this.gap(1))/this.cols;
            recheight = (this.height - (this.rows-1)*this.gap(2))/this.rows;
            for i = 1 : this.rows
                for j = 1: this.cols
                    xcenter = recwidth/2 + (j-1)*(this.gap(1)+recwidth);
                    ycenter = recheight/2 + (i-1)*(this.gap(2)+recheight);
                    this.rect{i,j} = class_rectangle('center',class_point('xdata',xcenter,'ydata',ycenter),...
                        'width',recwidth,'height',recheight,'draw',0);
                end
            end
            temp = this.rect;
            this.rect = flipud(temp);
        end
        function getArea(this)
            this.area=this.width*this.height;
        end     
        function drawshape(this)   
            for i = 1 : this.rows
                for j = 1 : this.cols                    
                    this.rect{i,j}.drawshape;
                end
            end
        end
        function getvertex(this)
            xfactor = [-1 -1 1 1];
            yfactor = [-1 1 1 -1];
            this.vertex1 = class_point;
            this.vertex2 = class_point;
            this.vertex3 = class_point;
            this.vertex4 = class_point;
            this.east = class_point;
            this.north = class_point;
            this.west = class_point;
            this.south = class_point;
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
        function getxdata(this)
            xfactor = [-1 -1 1 1];
            this.xdata=[this.center.xdata + xfactor(1)*this.width/2,...
                        this.center.xdata + xfactor(2)*this.width/2,...
                        this.center.xdata + xfactor(3)*this.width/2,...
                        this.center.xdata + xfactor(4)*this.width/2];
        end
        function getydata(this)
            yfactor = [-1 1 1 -1];
            this.ydata=[this.center.ydata + yfactor(1)*this.height/2,...
                        this.center.ydata + yfactor(2)*this.height/2,...
                        this.center.ydata + yfactor(3)*this.height/2,...
                        this.center.ydata + yfactor(4)*this.height/2];
        end
        function getcenter(this)
            this.center=class_point;
            this.center.xdata = mean([this.vertex1.xdata,this.vertex4.xdata]);
            this.center.ydata = mean([this.vertex1.ydata,this.vertex2.ydata]);
            this.width = this.vertex4.xdata-this.vertex1.xdata;
            this.height = this.vertex2.ydata-this.vertex1.ydata;
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
            this.width = this.position(3);
            this.height = this.position(4);
            check = this.position;
            this.center.xdata = this.position(1) + this.width/2;
            this.center.ydata = this.position(2) + this.height/2;
            xdata = this.center.xdata;
            ydata = this.center.ydata;
            getxdata(this);
            getydata(this);
            getArea(this);
            this.textpoint=this.center;
        end
    end
end