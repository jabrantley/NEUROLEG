function transform(this)
% This function perform linear transformation of an object.
% Transformation includes  move and scale.
pos = this.position;
xymove = this.move;
xyscale = this.scale;
scalepoint = this.scalepoint;
% xymove = get_varargin(varargin,'move',[0 0]);
% xyscale = get_varargin(varargin,'scale',[1 1]);
% scalepoint = get_varargin(varargin,'scalepoint','southwest');

if length(xymove)==1
   xymove = xymove.*[1 1];
end
if length(xyscale)==1
    xyscale = xyscale.*[1 1];
end

pos1= move(pos,xymove);
pos2= scale(pos1, xyscale);

xdiff = pos1(3) - pos2(3);
ydiff = pos1(4) - pos2(4); 

if strcmpi(scalepoint, 'northwest')
    newpos = move(pos2, [0 ydiff]);
elseif strcmpi(scalepoint, 'northeast')    
    newpos = move(pos2, [xdiff ydiff]);
elseif strcmpi(scalepoint, 'southeast')
    newpos = move(pos2, [xdiff 0]);
else
    newpos = pos2;
end
this.position = newpos;
layout_axes(this);

function newpos = move(pos,val);
x=val(1);y=val(2);
newpos = pos;
newpos(1)= pos(1) + x;
newpos(2)= pos(2) + y;

function newpos = scale(pos,val);
scalex=val(1);
scaley=val(2);
newpos = pos;
newpos(3) = pos(3)*scalex;
newpos(4) = pos(4)*scaley;

