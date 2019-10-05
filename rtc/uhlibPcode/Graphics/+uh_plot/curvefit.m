classdef curvefit < class_plot
    properties                
        type;
        orgfitopt; % Original fit options depending on fit model;
        fitopt; % structure data of Lower, Upper, and StartPoint
        fitmodel;
        fitobj;
        gof; % goodness of fit structure; sse, rsquare, rmse
    end
    methods
        %Contructor
        function this = curvefit(xdata,ydata,varargin)
            this.xdata = uh_tocolumn(xdata);
            this.ydata = uh_tocolumn(ydata);
            this.type = get_varargin(varargin,'fittype','sigmoid');
            this.fitopt = get_varargin(varargin,'fitopt',[]);
            % For ruler properties
            this.linestyle = get_varargin(varargin,'linestyle',this.linestyle);
            this.linewidth = get_varargin(varargin,'linewidth',this.linewidth);
            this.linecolor = get_varargin(varargin,'linecolor',this.linecolor);        
            this.getfitmodel;
            x = this.xdata; y = this.ydata;
            if ~isempty(this.fitopt)
                this.getfitoptions;
                [this.fitobj, this.gof] = fit(x,y,this.fitmodel,this.orgfitopt);
            else
                [this.fitobj, this.gof] = fit(x,y,this.fitmodel);
            end
            this.showplot;
        end
        function showplot(this)
            fitlinehdl=plot(this.fitobj,this.xdata,this.ydata);
            set(fitlinehdl(2),'linestyle',this.linestyle,'linewidth',this.linewidth,'color',this.linecolor);
            set(fitlinehdl(1),'marker','none');
            legend off; xlabel(''), ylabel('');
        end
        function getfitmodel(this)
            if strcmpi(this.type,'sigmoid')
                this.fitmodel = fittype('c/(1+exp(-k*x))+x0',...
                    'dependent','y','independent','x');                
            elseif any(strcmpi(this.type,{'poly1','poly2','linearinterp','cubicinterp','smoothingspline'}))
                this.fitmodel = this.type;            
            else
            end                           
        end
        function getfitoptions(this)
            this.orgfitopt = fitoptions(this.fitmodel);
            optlist = fieldnames(this.fitopt);
            for i = 1: length(optlist)
                strcmd = sprintf('this.orgfitopt.%s = this.fitopt.%s;',optlist{i},optlist{i});
                eval(strcmd);
            end
        end
    end
    methods(Access=private)
    end
    methods(Static) %static method doesn't require obj
    end
end