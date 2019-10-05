classdef errorbarplot < class_plot
    properties                
        highdata;
        lowdata;
        devdata; % deviation;
        errorbar = class_ruler;        
        tail;   % Whisker size
    end
    methods
        %Contructor
        function this = errorbarplot(xdata,ydata,varargin)
            this.xdata = uh_tocolumn(xdata);
            this.ydata = uh_tocolumn(ydata);
            this.devdata = get_varargin(varargin,'std',0);
            this.highdata = get_varargin(varargin,'highdata',this.ydata);
            this.lowdata = get_varargin(varargin,'lowdata',this.ydata);            
            if this.devdata ~=0
                this.getlowhighdata;
            end
            this.highdata = uh_tocolumn(this.highdata);
            this.lowdata = uh_tocolumn(this.lowdata);                        
            % For ruler properties
            this.linestyle = get_varargin(varargin,'linestyle',this.linestyle);
            this.linewidth = get_varargin(varargin,'linewidth',this.linewidth);
            this.linecolor = get_varargin(varargin,'linecolor',this.linecolor);            
            this.tail = get_varargin(varargin,'tail',0.1);
            this.clipping = get_varargin(varargin,'clipping','on');
            % Center point properties
            this.marker = get_varargin(varargin,'marker',this.marker);         
            this.markersize = get_varargin(varargin,'markersize',this.markersize);
            this.markerfacecolor = get_varargin(varargin,'markerfacecolor',this.markerfacecolor);
            this.markeredgecolor = get_varargin(varargin,'markeredgecolor',this.markeredgecolor);
            % Text properties
            this.textobj = class_text;
            this.textobj.string = get_varargin(varargin,'string','');
            this.textobj.position = [this.errorbar.endpoint.xdata this.errorbar.endpoint.ydata];            
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
            this.show = get_varargin(varargin,'show',0);                        
            %----Show plot
%             this.get_plotproperties;
            if this.show == 1
                this.showplot;
            end
        end
        function showplot(this)
            myxdata = this.xdata;
            myydata = this.ydata;
            mylowdata = this.lowdata;
            myhighdata = this.highdata;
            for i=1:length(myxdata)
                startpoint = class_point('xdata',myxdata(i),'ydata',mylowdata(i));
                endpoint = class_point('xdata',myxdata(i),'ydata',myhighdata(i));
                pnt1 = genpoint(startpoint,this.tail,180);
                pnt2 = genpoint(startpoint,this.tail,0);
                pnt3 = genpoint(endpoint,this.tail,180);
                pnt4 = genpoint(endpoint,this.tail,0);
                line([pnt1.xdata,pnt2.xdata],[pnt1.ydata,pnt2.ydata],'color',this.linecolor,'clipping',this.clipping);
                line([pnt3.xdata,pnt4.xdata],[pnt3.ydata,pnt4.ydata],'color',this.linecolor,'clipping',this.clipping);                
                linehdl = line('xdata',myxdata(i).*[1 1],'ydata',[mylowdata(i) myhighdata(i)]);
                set(linehdl,'linestyle',this.linestyle,'color',this.linecolor,'linewidth',this.linewidth,'clipping',this.clipping);
                % this.errorbar(i).drawshape;
%                 this.errorbar(i).center.drawshape;
%                 this.errorbar(i).endpoint.textobj.showtext;
            end
            line('xdata',myxdata,'ydata',myydata,'linestyle','none',...
                'marker',this.marker,'markersize',this.markersize,...
                'markerfacecolor',this.markerfacecolor,'markeredgecolor',this.markeredgecolor);
        end    
%         function get_plotproperties(this)
%             for i=1:length(this.xdata)
%                 this.errorbar(i).xdata = this.xdata(i).*[1 1];
%                 this.errorbar(i).ydata = [this.lowdata(i) this.highdata(i)];                          
%                 set(this.errorbar(i),'linewidth',this.linewidth,'linecolor',this.linecolor,'tail',this.tail,'clipping',this.clipping);
%                 set(this.errorbar(i).endpoint.textobj,'string',this.string,'textgap',this.textgap);                    
%                 set(this.errorbar(i).center,'marker',this.marker,'markersize',this.markersize,...
%                     'markerfacecolor',this.markerfacecolor,'markeredgecolor',this.markeredgecolor,'clipping',this.clipping);
%             end            
%         end
        function getlowhighdata(this)
            this.highdata = this.ydata + this.devdata;
            this.lowdata = this.ydata - this.devdata;
        end
    end
    methods(Access=private)
    end
    methods(Static) %static method doesn't require obj
    end
end