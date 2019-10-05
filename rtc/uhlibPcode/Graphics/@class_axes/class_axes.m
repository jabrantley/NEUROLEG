classdef class_axes < handle & hgsetget    
    properties
        fontname;
        fontsize;
        gridsize;
        gapw;
        gaph;
        wratio;
        hratio;
        width;
        height;        
        yaxislocation;
        daspectval;
        myax;        
        show;
        move; % for transformation;
        scale;
        scalepoint;
    end
    properties (SetObservable)
        position;    
    end
    methods (Access = public) %Constructor
        %Constructor
        function this = class_axes(varargin);
            this.fontname = get_varargin(varargin,'fontname','Times New Roman');
            this.fontsize = get_varargin(varargin,'fontsize',8);
            this.gridsize = get_varargin(varargin,'gridsize',[1 1 1]);              
            this.position = get_varargin(varargin,'position',[0.02, 0.02, 0.95, 0.95]);     
            this.gapw = get_varargin(varargin,'gapw',this.position(1));
            this.gaph = get_varargin(varargin,'gaph',this.position(2));
            this.wratio = get_varargin(varargin,'widthratio',1);
            this.hratio = get_varargin(varargin,'heightratio',1);    
            this.yaxislocation = get_varargin(varargin,'yaxislocation','left');
            this.daspectval = get_varargin(varargin,'daspect',0);
            this.show = get_varargin(varargin,'show',0);
            this.move = get_varargin(varargin,'move',[0 0]);
            this.scale = get_varargin(varargin,'scale',[1 1]);
            this.scalepoint = get_varargin(varargin,'scalepoint','northeast');
            % Add listener to the class;
            addlistener(this,'position','PostSet',@this.listener_position_Callback);
            if this.show == 1
                this.layout_axes;
            end
        end         
        % Methods are defined in @class_axes folder.        
       layout_axes(this);
       copyobj(this);
       transform(this);
       align_axes(this,varargin);
    end
    methods(Access=private)
        function listener_position_Callback(this,src,event)
            this.layout_axes;
        end
    end
end
        
