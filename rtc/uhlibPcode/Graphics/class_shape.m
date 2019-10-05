classdef class_shape < handle & hgsetget
    properties (SetAccess = public, GetAccess = public)
        area;
        north;
        east;
        south;
        west;       
        tag = 'class_shape';
    end
    properties (SetObservable)
        center;
        position;
        xdata;
        ydata;
    end
    properties
        % Marker properties
        marker ='x';
        markersize = 4;
        markeredgecolor ='k';
        markerfacecolor ='w';
        % Line propertis
        linecolor = 'k';
        linewidth = 0.75;
        linestyle = '-';
        edgecolor = 'k';
        edgestyle = '-';
        edgewidth = 0.75;
        % Color properties
        facecolor = 'w';
        facealpha = 1;
        cdata;
        clipping = 'off';
        % text properties
        textobj;
%         string = '';
%         textpoint = class_text;
%         textgap = [0 0];
%         fontname = 'Times New Roman';
%         fontsize = 8;
%         fontweight = 'normal';
%         textcolor = 'k';
%         backgroundcolor = 'none';
%         horizontalalignment = 'center';
%         verticalalignment = 'middle';
%         rotation = 0;
%         interpreter = 'tex';
        % Option to draw the shape;
        draw = 0;
    end
    methods (Abstract)  %Use Abstract attribute to implement polymorphism
        drawshape(obj) % Draw objects, could be in any shapes defined in subclasses
        getArea(obj) % Calculate area
    end
    methods
        function newobj=copyobj(this)
            newobj=feval(class(this));
            props=properties(this);
            for i=1:length(props)
                newobj.(props{i})=this.(props{i});
            end
        end
        function newobj = circopy(this,copycenter,numobj) %copy n objects in circular direction
            linehdl = class_line(copycenter,this.center);
            copyr=getlength(linehdl);
            theta0 = getangle(linehdl);
            for i=1:numobj
                newobj(i) = copyobj(this);
            end
            for i=2:numobj
                dtheta=(i-1)*2*pi/(numobj);
                newobj(i).center.xdata = copycenter.xdata + copyr*cos(theta0+dtheta);
                newobj(i).center.ydata = copycenter.ydata + copyr*sin(theta0+dtheta);
                newobj(i).drawshape;
            end
        end
        function newobj = dircopy(this,distance,direction,numobj) %copy n objects in horizontal or vertical direction
            % direction is a 2d vector;
            for i=1:numobj
                newobj(i) = copyobj(this);
            end
            for i=2:numobj
                dlen=(i-1)*distance/(numobj-1);
                newobj(i).center=class_point(this.center.xdata + dlen * direction(1),...
                    this.center.ydata + dlen * direction(2));
%                 newobj(i).drawshape;
            end
        end
        function setproperties(this,varargin)
            if length(varargin)>=2
                for i=1:2:length(varargin)
                    param=varargin{i};
                    val=varargin{i+1};
                    this.(param)=val;
                end
            end
            this.drawshape;
        end
        
        function addtext(this)     
            this.textobj.showtext;
%             this.textobj=text(this.textpoint.xdata+this.textgap(1),this.textpoint.ydata+this.textgap(2),this.string,...
%                 'fontname',this.fontname,'fontsize',this.fontsize,'fontweight',this.fontweight,...
%                 'horizontalalignment',this.horizontalalignment,'verticalalignment',this.verticalalignment,'rotation',this.rotation,...
%                 'color',this.textcolor,'backgroundcolor',this.backgroundcolor,...
%                 'interpreter',this.interpreter);
        end
        function align(this,varargin)
            caxes = get_varargin(varargin,'axes',gca);
            refobj = get_varargin(varargin,'ref',gcf); %reference object
            align = get_varargin(varargin,'align','east');
            scale = get_varargin(varargin,'scale',[1, 1]);
            gap = get_varargin(varargin,'gap',[0, 0]);
            if refobj == gcf; refpos = [0 0 1 1];
            else refpos = get(refobj,'position'); end;
            %-------
            limx = get(gca,'xlim');limy = get(gca,'ylim');
            axwidth = diff(limx); axheight = diff(limy);
            marginleft = -1; marginright = -1;
            marginbottom = -1; margintop = -1;
            switch align
                case 'east'
                    marginleft = refpos(1) + refpos(3);
                    marginbottom = refpos(2);
                case 'west'
                    marginright = refpos(1);
                    marginbottom = refpos(2);
                case 'north'
                    marginleft = refpos(1);
                    marginbottom = refpos(2) + refpos(4);
                case 'south'
                    marginleft = refpos(1);
                    margintop = refpos(2);
                case 'northeast'
                    marginleft = refpos(1) + refpos(3);
                    marginbottom = refpos(2) + refpos(4);
                case 'southeast'
                    marginleft = refpos(1) + refpos(3);
                    margintop = refpos(2);
                case 'northwest'
                    marginright = refpos(1);
                    marginbottom = refpos(2) + refpos(4);
                case 'southwest'
                    marginright = refpos(1);
                    margintop = refpos(2);
                otherwise
            end
            width=refpos(3)*scale(1);height=refpos(4)*scale(2);
            if marginright~=-1; marginleft = marginright-width;end;
            if margintop~=-1; marginbottom = margintop - height;end;
            marginleft=marginleft+gap(1);marginbottom=marginbottom+gap(2);
            set(this,'position',[marginleft marginbottom width height]);
        end
    end
end

