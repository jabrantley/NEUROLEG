classdef boxplot < class_plot
    properties
        patchobj = class_patch;
        highwhisker = class_ruler;
        lowwhisker = class_ruler;
        medianline = class_line;
        outliersplot = class_pointscloud;
        barwidth;
        numbar; % number of bar
        tail;   % Whisker size
        notch; % control the notch size, relative to bar width.
        %
        statval; % statistic value [min 25% median 75% max]
        outliers;
        whisker; % Control the outliers of box plot, see matlab help boxplot for more info. Default val: 1.5
        jitter; % distribute outliers so they are more visible.
        % Plot options, select which part of the box plot to be shown
        % Label properties
        groupnames;  % label for each column
        plotopt = struct;
    end
    methods
        %Contructor
        function this = boxplot(xdata,ydata,varargin)
            this.xdata = uh_tocolumn(xdata);
            this.ydata = uh_tocolumn(ydata);
            % For patch object properties
            this.notch = get_varargin(varargin,'notch',0.1);
            this.whisker = get_varargin(varargin,'whisker',1.5);
            this.jitter = get_varargin(varargin, 'jitter',1); %sparse outliers around box width
            % axes properties
            this.groupnames = get_varargin(varargin,'xlabel','');
            this.facecolor = get_varargin(varargin,'facecolor',this.facecolor);
            this.facealpha = get_varargin(varargin,'facealpha',this.facealpha);
            this.edgecolor = get_varargin(varargin,'edgecolor',this.edgecolor);
            this.edgestyle = get_varargin(varargin,'edgestyle',this.edgestyle);
            this.edgewidth = get_varargin(varargin,'edgewidth',this.edgewidth);
            this.barwidth = get_varargin(varargin,'barwidth',0.5);
            % For ruler properties
            this.linestyle = get_varargin(varargin,'linestyle',this.linestyle);
            this.linewidth = get_varargin(varargin,'linewidth',this.linewidth);
            this.linecolor = get_varargin(varargin,'linecolor',this.linecolor);
            % for oulier properties
            this.marker = get_varargin(varargin,'marker',this.marker);
            this.markersize = get_varargin(varargin,'markersize',this.markersize);
            this.markerfacecolor = get_varargin(varargin,'markerfacecolor',this.markerfacecolor);
            this.markeredgecolor = get_varargin(varargin,'markeredgecolor',this.markeredgecolor);
            this.string = get_varargin(varargin,'string','');
            this.textgap = get_varargin(varargin,'textgap',this.textgap);
            this.tail = get_varargin(varargin,'tail',0.1);
            % Show plot option
            this.show = get_varargin(varargin,'show',0);
            this.plotopt.medline = 1;
            this.plotopt.center = 1;
            this.plotopt.whisker = 1;
            this.plotopt.outliers = 1;
            this.plotopt.xlabel = 1;
            this.plotopt.ylabel = 0;
            % Get statistic value
            this.get_statistic;
            % Get plot properties
            this.get_plotproperties;
            % Plot
            if this.show == 1
                this.showplot;
            end
        end
        function showplot(this)
            for i = 1 : length(this.xdata)
                % Draw shape;
                this.patchobj(i).drawshape;
                if this.plotopt.medline == 1; this.medianline(i).drawshape; end;
                if this.plotopt.center == 1; this.medianline(i).center.drawshape; end;
                if this.plotopt.whisker == 1;
                    this.highwhisker(i).drawshape;
                    this.lowwhisker(i).drawshape;
                end
                if this.plotopt.outliers == 1; this.outliersplot(i).drawshape; end;
                if this.plotopt.xlabel == 1; 
                    this.xlabel(i).showtext; 
                end;                
            end
        end
        function get_plotproperties(this)
            if length(this.xdata) == 1
                recwidth = this.barwidth;
            else
                recwidth = (this.xdata(end) - this.xdata(1))/(length(this.xdata)-1)*this.barwidth;
            end
            w = recwidth /2;
            for i = 1 : length(this.xdata)
                x = this.notch * w; %notch size;                
                % patch object or main body.
                c = this.xdata(i);
                s = this.statval(:,i);
                ynotch = (s(4) - s(2))/w*x;
                if s(3) - x < s(2); x = 0; end;
                this.patchobj(i).xdata = [c-w, c-w, c-w+x, c-w, c-w,...
                    c+w, c+w, c+w-x, c+w, c+w];                
                this.patchobj(i).ydata = [s(2), s(3)-ynotch, s(3), s(3)+ynotch, s(4),...
                    s(4), s(3)+ynotch, s(3), s(3)-ynotch, s(2)];
                
                this.patchobj(i).cdata = zeros(1,length(this.patchobj(i).xdata));
                % Median line;
                this.medianline(i).xdata = [c-w+x, c+w-x];
                this.medianline(i).ydata = [s(3), s(3)];
                % Whisker line;
                this.highwhisker(i).xdata = [c, c];
                this.highwhisker(i).ydata = [s(4), s(5)];
                this.lowwhisker(i).xdata = [c, c];
                this.lowwhisker(i).ydata = [s(2), s(1)];
                % Outliers
                this.outliersplot(i).ydata = this.outliers{i};
                xdata = c - this.jitter*(w - 2*w.*rand(length(this.outliers{i}),1));
                this.outliersplot(i).xdata = xdata;
                % Label text
                this.xlabel(i).position = [c, this.medianline(i).ydata];
                if ~isempty(this.groupnames)
                    this.xlabel(i).string = this.groupnames{i};
                end
                %                 this.outliersplot(i).xdata = repmat(c,1,length(this.outliers{i}));
                % Patch properties
                set(this.patchobj(i),'linestyle',this.edgestyle,'edgecolor',this.edgecolor,...
                    'linewidth',this.edgewidth,'facecolor',this.facecolor,'facealpha',this.facealpha);
                % Median line and center properties
                set(this.medianline(i),'linestyle',this.edgestyle,'linecolor',this.linecolor,'linewidth',this.linewidth);
                set(this.medianline(i).center,'marker',this.marker,'markersize',this.markersize,...
                    'markerfacecolor',this.markerfacecolor,'markeredgecolor',this.markeredgecolor);
                % Whisker lines properties
                set(this.highwhisker(i),'linestyle',this.linestyle,'linecolor',this.linecolor,'linewidth',this.linewidth,'tail',this.tail);
                set(this.lowwhisker(i),'linestyle',this.linestyle,'linecolor',this.linecolor,'linewidth',this.linewidth,'tail',this.tail);
                % Outliers properties
                set(this.outliersplot(i),'marker',this.marker,'markersize',this.markersize,...
                    'markerfacecolor',this.markerfacecolor,'markeredgecolor',this.markeredgecolor);
            end
            
        end
        function get_statistic(this)
            for i = 1 : size(this.ydata,2)
                thiscol = this.ydata(:,i);
                thisquantile = quantile(thiscol,[0.25 0.5 0.75]);
                interquartilerange = thisquantile(3) - thisquantile(1);
                minval = thisquantile(1) - this.whisker*interquartilerange;
                maxval = thisquantile(3) + this.whisker*interquartilerange;
                outlierval = thiscol(find( thiscol < minval | thiscol > maxval));
                newcol = setdiff(thiscol,outlierval);
                this.statval(:,i) = [min(newcol) quantile(newcol,[0.25 0.5 0.75]) max(newcol)];
                this.outliers{i} = outlierval;
            end
        end
    end
    methods(Access=private)
    end
    methods(Static) %static method doesn't require obj
    end
end