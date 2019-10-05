classdef histplot < class_plot
    properties                
        scatterdata;        
        barobj;
        barwidth;        
        location;
        nbins;
        xbins;
    end
    methods
        %Contructor
        function this = histplot(inputdata,varargin)            
            this.scatterdata = uh_tocolumn(inputdata);            
            % For bar properties
            this.nbins = get_varargin(varargin,'nbins',10);
            this.xbins = get_varargin(varargin,'xbins',[]);
            this.facecolor = get_varargin(varargin,'facecolor',this.facecolor);
            this.facealpha = get_varargin(varargin,'facealpha',this.facealpha);
            this.edgecolor = get_varargin(varargin,'edgecolor',this.edgecolor);
            this.barwidth = get_varargin(varargin,'barwidth',0.5);
            this.location = get_varargin(varargin,'location','southup');
            % For ruler properties                        
            this.showplot;
        end
        function showplot(this)
            if isempty(this.xbins)
                [ydata, xdata] = hist(this.scatterdata,this.nbins); % counts in one bin and number of bins.
            else
                [ydata, xdata] = hist(this.scatterdata,this.xbins); % counts in one bin and number of bins.
            end
            if strcmpi(this.location,'southup')
%                 recwidth = (xdata(end) - xdata(1))/(length(xdata)-1)*this.barwidth;
                recwidth = this.barwidth;
                for i = 1 : length(xdata)
                    thiscenter = class_point('xdata',xdata(i),'ydata', ydata(i)/2);
                    thisrec = class_rectangle('center',thiscenter,'width',recwidth,'height',ydata(i));
                    setproperties(thisrec,'facecolor',this.facecolor,'edgecolor',this.edgecolor,'linewidth',this.linewidth);
                    thisrec.drawshape;
                end
            elseif strcmpi(this.location,'southdown')
%                 recwidth = (xdata(end) - xdata(1))/(length(xdata)-1)*this.barwidth;
                recwidth = this.barwidth;
                for i = 1 : length(xdata)
                    thiscenter = class_point('xdata',xdata(i),'ydata', -ydata(i)/2);
                    thisrec = class_rectangle('center',thiscenter,'width',recwidth,'height',ydata(i));
                    setproperties(thisrec,'facecolor',this.facecolor,'edgecolor',this.edgecolor,'linewidth',this.linewidth);
                    thisrec.drawshape;
                end
            elseif strcmpi(this.location,'westright')
%                 recheight = (xdata(end) - xdata(1))/(length(xdata)-1)*this.barwidth;
                recheight = this.barwidth;
                for i = 1 : length(xdata)
                    thiscenter = class_point('xdata',ydata(i)/2,'ydata', xdata(i));
                    thisrec = class_rectangle('center',thiscenter,'width',ydata(i),'height',recheight);
                    setproperties(thisrec,'facecolor',this.facecolor,'edgecolor',this.edgecolor,'linewidth',this.linewidth);
                    thisrec.drawshape;
                end
            end
        end
    end  
    methods(Access=private)       
    end
    methods(Static) %static method doesn't require obj      
    end
end