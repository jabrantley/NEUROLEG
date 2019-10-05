function layout_axes(this)
rows=this.gridsize(1);
cols=this.gridsize(2);
if length(this.gridsize) == 3
    layers = this.gridsize(3);
else
    layers = 1;
end
if numel(this.gapw)==1 && cols>1
    this.gapw=this.gapw.*ones(1,cols-1);
end
if numel(this.gaph)==1 && rows>1
    this.gaph=this.gaph.*ones(1,rows-1);
end
if this.wratio==1; axw(1:cols)=(this.position(3)-sum(this.gapw))/cols;
else
    for i=1:cols
        axw(i)=(this.position(3)-sum(this.gapw))*this.wratio(i);
    end
end
if this.hratio==1; axh(1:rows)=(this.position(4)-sum(this.gaph))/rows;
else
    for i=1:rows
        axh(i)=(this.position(4)-sum(this.gaph))*this.hratio(i);
    end
end
this.myax=zeros(this.gridsize);
if layers == 1
    ypos=this.position(2)+this.position(4)-axh(1);       %first axes pos, top left corner
    for i=1:rows
        xpos=this.position(1);
        for j=1:cols
            this.myax(i,j)=axes('color','none','box','off','unit','norm',...
                'fontsize',this.fontsize, 'fontname',this.fontname,...
                'yaxislocation',this.yaxislocation,...
                'NextPlot','replacechildren',...
                'position',[xpos ypos axw(j) axh(i)]); %This property prevents plot and plot3 funcs reset axes's properties
            if this.daspectval~=0
                daspect(gca,this.daspectval);
            end
            if j~=cols
                xpos=xpos+axw(j)+this.gapw(j);
            end
        end
        if i~=rows
            ypos=ypos-axh(i+1)-this.gaph(i);
        end
    end
else
    for k = 1:layers
        ypos=this.position(2)+this.position(4)-axh(1);       %first axes pos, top left corner
        for i=1:rows
            xpos=this.position(1);
            for j=1:cols
                this.myax(i,j,k)=axes('color','none','box','off','unit','norm',...
                    'fontsize',this.fontsize, 'fontname',this.fontname,...
                    'yaxislocation',this.yaxislocation,...
                    'NextPlot','replacechildren',...
                    'position',[xpos ypos axw(j) axh(i)]); %This property prevents plot and plot3 funcs reset axes's properties
                if this.daspectval~=0
                    daspect(gca,this.daspectval);
                end
                if j~=cols
                    xpos=xpos+axw(j)+this.gapw(j);
                end
            end
            if i~=rows
                ypos=ypos-axh(i+1)-this.gaph(i);
            end
        end
    end
end
end