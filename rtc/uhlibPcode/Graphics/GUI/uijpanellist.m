function varargout=uijpanellist(varargin)
gvar=def_gvar;
marginleft=gvar.margin.l;
marginbottom=gvar.margin.b;
width=0.3;
height=0.2;
paneltitle = get_varargin(varargin,'title','Exp Panel');
bordertype = get_varargin(varargin,'border','etchedin');
fontsize = get_varargin(varargin,'fontsize',gvar.fontsize);
objects = get_varargin(varargin,'objects',{});
position = get_varargin(varargin,'position',[marginleft, marginbottom, width, height]);
marginleft = position(1);marginbottom = position(2);
width = position(3); height = position(4);
bwidth = get_varargin(varargin,'itemwidth',0);
bheight = get_varargin(varargin,'itemheight',0);
gap = get_varargin(varargin,'gap',[0, 0.1]);
% Create panel
panel = javaObjectEDT('javax.swing.JPanel');
% panel=uipanel('Title',paneltitle,'FontSize',fontsize,'Fontweight','bold',...
%     'BackgroundColor','w',...
%     'bordertype',bordertype,...
%     'Position',[marginleft marginbottom width height]);
%button
if bheight==0
    bheight=(1-(length(objects)+1)*gap(2))/length(objects)*ones(1,length(objects));
else
end
if bwidth==0
    bwidth=(1-marginleft)*ones(1,length(objects));
else
end
for i=1:length(objects)
    thisheight=bheight(i);
    if i==1
        set(objects(i),'parent',panel,...
            'position',[marginleft 1-thisheight bwidth(i) thisheight]);
    else
        prepos=get(objects(i-1),'position');preheight=prepos(2);
        set(objects(i),'parent',panel,...
            'position',[marginleft preheight-thisheight-gap(2) bwidth(i) thisheight]);
    end
end
% Output object handles
switch nargout
    case 0
    case 1
        varargout{1}=panel;
    otherwise
end
