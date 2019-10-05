function align_axes(this,varargin)
% This function align an axes class object to a reference object
align = get_varargin(varargin,'align','southright');
scale = get_varargin(varargin,'scale',[1, 1]);
gap = get_varargin(varargin,'gap',[0, 0]);
refobj = get_varargin(varargin,'reference',gca);
try
    refpos = refobj.position;
catch
    refpos = refobj.Position;
end
if length(scale)==1
    scale = repmat(scale,1,2);
end
marginleft_ref=refpos(1);
marginright_ref = refpos(1)+refpos(3);
marginbottom_ref = refpos(2);
margintop_ref = refpos(2)+refpos(4);
marginleft=-1;marginright=-1;
margintop=-1;marginbottom=-1;

switch align
    case 'northeastinside'
        margintop = margintop_ref; % 
        marginright = marginright_ref;
    case 'northwestinside'
        margintop = margintop_ref; 
        marginleft = marginleft_ref;
    case 'southleft'
        margintop = marginbottom_ref; % Go to south;
        marginleft = marginleft_ref; % Go to left;
    case 'southright'
        margintop = marginbottom_ref; % go to south
        marginleft = marginright_ref; % go to right;
    case 'eastdown'
        marginleft = marginright_ref; % go to east
        marginbottom = marginbottom_ref;
    case 'eastup'
        marginleft = marginright_ref;
        margintop = margintop_ref;        
    otherwise
end
width=refpos(3)*scale(1);
height=refpos(4)*scale(2);
if marginright~=-1; marginleft=marginright-width;end;
if margintop~=-1; marginbottom=margintop-height;end;
marginleft=marginleft+gap(1);
marginbottom=marginbottom+gap(2);
this.position = [marginleft marginbottom width height];

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
for k = 1:layers
    ypos=this.position(2)+this.position(4)-axh(1);       %first axes pos, top left corner
    for i=1:rows
        xpos=this.position(1);
        for j=1:cols
            set(this.myax(i,j,k),'Position',[xpos ypos axw(j) axh(i)]);
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



% layout_axes(this);

