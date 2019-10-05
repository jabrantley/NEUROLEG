classdef class_text < hgsetget;
    % Class to manage text object.    
    % Usage:     
    %   See properties that can be set or get
    %       properties('class_text');
    %   See class methods
    %       methodsview('class_text');
    % --------
    % Phat Luu. tpluu2207@gmail.com
    % Brain Machine Interfaces Lab. Univerisity of Houston.
    
    % Design for Avatar and NeuroLeg project.
    % v.1.0. 2016/09/22.
    % --------
    % This program is free software; you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation; either version 2 of the License, or
    % (at your option) any later version.
    %
    % This program is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    % -------- 
    properties (SetAccess = public, GetAccess = public)
        % font
        string;
        fontsize;
        fontweight;
        fontname;
        fontunits;
        fontangle;
        % color;
        color;
        backgroundcolor;        
        % alignment
        horizontalalignment;
        verticalalignment;        
        rotation;
        % interpreter
        interpreter;
        % display option
        show; 
        location; % 'xlabel', 'ylabel', 'north'
    end
    properties (SetObservable = true)        
        % position
        position = [0 0];
        textgap = [0 0];
        xdata = 0;
        ydata = 0;
    end
    methods (Access = public) %Constructor
        %Constructor
        function this = class_text(varargin)
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
            this.textgap = get_varargin(varargin,'textgap',[0 0]);
             % Check type of input;
            if posin == 1; this.get_xydata;
            else this.get_position;
            end
            this.string = get_varargin(varargin,'string','');                        
            %----
            this.fontsize = get_varargin(varargin,'fontsize',8);
            this.fontweight = get_varargin(varargin,'fontweight','normal');      
            this.fontname = get_varargin(varargin,'fontname','Times New Roman');
            this.fontunits = get_varargin(varargin,'fontunits','points');
            this.fontangle = get_varargin(varargin,'fontangle','normal');
            % Color
            this.color = get_varargin(varargin,'color',[0 0 0]);
            this.backgroundcolor = get_varargin(varargin,'backgroundcolor','none');
            % Alignment
            this.horizontalalignment = get_varargin(varargin,'horizontalalignment','left');
            this.verticalalignment = get_varargin(varargin,'verticalalalignment','middle');
            this.rotation = get_varargin(varargin,'rotation',0);
            % Interpreter
            this.interpreter = get_varargin(varargin,'interpreter','tex');
            % Display option
            this.location = get_varargin(varargin,'location','');            
            this.show = get_varargin(varargin,'show',0);
             % Set observation;
            addlistener(this,'xdata','PostSet',@this.listener_xydata_Callback);
            addlistener(this,'ydata','PostSet',@this.listener_xydata_Callback);
            addlistener(this,'position','PostSet',@this.listener_position_Callback);  
            addlistener(this,'textgap','PostSet',@this.listener_textgap_Callback);  
            % Get location properties;
            this.get_locationproperties;
            if this.show == 1
                this.showtext;
            end
        end
    end    
    methods
        function showtext(this)              
            texthdl = text(this.xdata, this.ydata, this.string);                        
            set(texthdl,'fontsize',this.fontsize,'fontweight',this.fontweight,'fontname',this.fontname,...
                'fontangle',this.fontangle,'fontunits',this.fontunits,...
                'color',this.color,'backgroundcolor',this.backgroundcolor,...
                'horizontalalignment',this.horizontalalignment,'verticalalignment',this.verticalalignment,'rotation',this.rotation,...
                'interpreter',this.interpreter);                            
        end
        function get_locationproperties(this)
            limx = get(gca,'xlim');
            limy = get(gca,'ylim');
            txtgap = this.textgap;
            if strcmpi(this.location,'xlabel')                
                this.position = [mean(limx)+txtgap(1), limy(1)+txtgap(2)];                
                set(this,'horizontalalignment','center','verticalalignment','top');
            elseif strcmpi(this.location,'ylabel')
                this.position = [limx(1)+txtgap(1), mean(limy)+txtgap(2)];                
                set(this,'rotation',90,'horizontalalignment','center','verticalalignment','bottom');
            elseif strcmpi(this.location,'north')
                this.position = [mean(limx)+txtgap(1), limy(2)+txtgap(2)];                
                set(this,'horizontalalignment','center','verticalalignment','bottom');            
            elseif strcmpi(this.location,'west')                
                this.position = [limx(1)+txtgap(1), mean(limy)+txtgap(2)];
                set(this,'horizontalalignment','center','verticalalignment','middle','rotation',90);
            elseif strcmpi(this.location,'east')
                this.position = [limx(2)+txtgap(1), mean(limy)+txtgap(2)];
                set(this,'horizontalalignment','center','verticalalignment','middle','rotation',90);
            elseif strcmpi(this.location,'northwest')
                this.position = [limx(1)+txtgap(1), limy(2)+txtgap(2)];
                set(this,'horizontalalignment','right','verticalalignment','middle');
            else
                currpos = this.position;
                this.position = [currpos(1)+txtgap(1), currpos(2)+txtgap(2)];                
            end
            pos = this.position;
            this.xdata = pos(1);
            this.ydata = pos(2);
        end
        function get_xydata(this)
            pos = this.position; gap = this.textgap;
            this.xdata = pos(1) + gap(1);
            this.ydata = pos(2) + gap(2);
        end
        function get_position(this)
            this.position = [this.xdata+this.textgap(1), this.ydata + this.textgap(2)];
        end
    end
     methods(Access=private)
        function listener_xydata_Callback(this,src,event)
%             uh_fprintf('Callback');
            this.position = [this.xdata, this.ydata];           
        end
        function listener_position_Callback(this,src,event)
%             uh_fprintf('Callback'); 
            temp = this.position;
            this.xdata = temp(1);
            this.ydata = temp(2);                
        end       
        function listener_textgap_Callback(this,src,event)            
%             uh_fprintf('Callback');
            gap = this.textgap;
            this.xdata = this.xdata + gap(1);
            this.ydata = this.ydata + gap(2);
            this.position = [this.xdata, this.ydata];
        end
    end
    methods (Access = private) %Destructor
        function delete(this)
            % Delete obj.
        end
    end
end
