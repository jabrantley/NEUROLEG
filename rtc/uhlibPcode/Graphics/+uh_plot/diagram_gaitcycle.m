function diagram_gaitcycle(varargin)
% Input:
gcevent = get_varargin(varargin,'event',[0 15 45 60 100 115]);
axin = get_varargin(varargin,'axin',[]);
rectheight = get_varargin(varargin,'height',5);
ypos = get_varargin(varargin,'ypos',0)
vgap = get_varargin(varargin,'gap',1.2*rectheight);

%
note.rstand = 'R. Stance phase';
note.lstand = 'L. Stance phase';
note.rswing = 'R. Swing phase';
note.lswing = 'L. Swing phase';
note.rsingle = 'R. Single support';
note.double = 'Double support';
note.lsingle = 'L. Single support';
%
event.double = [gcevent(1) gcevent(2);,...
                gcevent(3) gcevent(4);,...
                gcevent(5) gcevent(6)];
event.rstand = [gcevent(1) gcevent(4)];
event.rswing = [gcevent(4) gcevent(5)];
event.lstand = [gcevent(3) gcevent(6)];
event.lswing = [gcevent(2) gcevent(3)];
event.rsingle = [gcevent(2) gcevent(3)];
event.lsingle = [gcevent(4) gcevent(5)];
%
color.stand = [154 197 241]./256;
color.swing = [154 154 154]./256;
if isempty(axin)
    paper = [0 0 3.5 2];
    myfig=figure('unit','inches','position',[0 0 paper(3) paper(4)],'color','w');
    axclass = class_axes('gridsize',[1 1 1],'position',[0.12 0.01 0.88 0.95],'gapw',0,'gaph',0,'show',1);
    axes(axclass.myax);
end

% Plot rectangle for right and left stance and swing phases
rect.rstand = class_rectangle('center',class_point('xdata',gcevent(1) + mean(event.rstand),'ydata',ypos),'width', diff(event.rstand),'height',rectheight,...
    'facecolor',color.stand,'string',note.rstand,'draw',1);
rect.rswing = class_rectangle('center',class_point('xdata',gcevent(1) + mean(event.rswing),'ydata',ypos),'width', diff(event.rswing),'height',rectheight,...
    'facecolor',color.swing,'string',note.rswing,'draw',1);
rect.lstand = class_rectangle('center',class_point('xdata',gcevent(2) + mean(event.lstand),'ydata',ypos-vgap),'width', diff(event.lstand),'height',rectheight,...
    'facecolor',color.stand,'string',note.lstand,'draw',1);
rect.lswing = class_rectangle('center',class_point('xdata',gcevent(2) + mean(event.lswing),'ydata',ypos-vgap),'width', diff(event.lswing),'height',rectheight,...
    'facecolor',color.swing,'string',note.lswing,'draw',1);
% Vertical line
for i = 1 : length(gcevent)
    line('xdata',gcevent(i).*[1 1],'ydata',get(gca,'ylim'),'linestyle','--');
end
% if i == 1
%     rect{rows,i} = class_rectangle('center',class_point('xdata',0.07,'ydata',ylocs),'width', unitw,'height',unith);
% else
%     rect{rows,i} = class_rectangle;
%     rect{rows,i}.align('ref',rect{rows,i-1},'align','east','scale',[mins(i)/mins(i-1) 1],'gap',[unitgap 0]);
% end
% set(rect{rows,i},'facecolor',rectcolor{i});
% set(rect{rows,i}.textobj,'string',rectstring{i},'color',textcolor{i},'fontweight','bold');
% rect{rows,i}.drawshape;
% set(rect{rows,i}.south,'marker','none');
% set(rect{rows,i}.south.textobj,'string',[mat2str(mins(i)) ' mins'],'verticalalignment','top');
% rect{rows,i}.south.drawshape;