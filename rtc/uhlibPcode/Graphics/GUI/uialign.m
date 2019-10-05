function uialign(thisobj,refobj,varargin)
gvar = def_gvar;
marginleft=-1;marginright=-1;
margintop=-1;marginbottom=-1;
if refobj==gcf;
    refpos=[gvar.margin.l, gvar.margin.b,...
        1-gvar.margin.l-gvar.margin.r, 1-gvar.margin.t-gvar.margin.b];
else
    refpos=get(refobj,'position');
end
marginleft_ref=refpos(1);
marginright_ref=1-refpos(1)-refpos(3);
marginbottom_ref=refpos(2);
margintop_ref=1-refpos(2)-refpos(4);
align = get_varargin(varargin,'align','southwest');
scale = get_varargin(varargin,'scale',[1, 1]);
gap = get_varargin(varargin,'gap',[0, 0]);
switch align
    case 'east'
        marginleft=1-marginright_ref;
        margintop=1-margintop_ref;
    case 'west'
        marginright=1-marginleft_ref;
        marginbottom=marginbottom_ref;
    case 'northeast'
        marginright=marginright_ref;
        marginbottom=margintop_ref;
    case 'northwest'
        marginleft=1-marginleft_ref;
        marginbottom=margintop_ref;
    case 'southeast'
        marginright=marginright_ref;
        margintop=marginbottom_ref;
    case 'eastsouth'
        marginleft=1-marginright_ref;
        marginbottom=marginbottom_ref;
    case 'southwest'
        marginleft=marginleft_ref;
        margintop=marginbottom_ref;
    otherwise
end
width=refpos(3)*scale(1);height=refpos(4)*scale(2);
if marginright~=-1; marginleft=1-marginright-width;end;
if margintop~=-1; marginbottom=margintop-height;end;
marginleft=marginleft+gap(1);marginbottom=marginbottom+gap(2);
set(thisobj,'position',[marginleft marginbottom width height]);
