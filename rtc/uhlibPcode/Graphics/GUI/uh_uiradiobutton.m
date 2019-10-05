function varargout = uh_uiradiobutton(varargin)
title= get_varargin(varargin,'title','Untitled');
objnames= get_varargin(varargin,'string',{'radio1','radio2'});
position= get_varargin(varargin,'position',[0 0 0.3 0.2]);
marginleft = position(1); marginbottom = position(2);
width = position(3); height = position(4);
gap = get_varargin(varargin,'gap',[0 0.1]);
bwidth= get_varargin(varargin,'buttonwidth',1 - marginleft);
fontsize = get_varargin(varargin,'fontsize',6);
% Create buttongroup
buttongroup=uibuttongroup('units','norm','background','w',...
    'Position',position,... 
    'title',title,'fontsize',fontsize,...
    'visible','off');
%button
bheight=(1-(length(objnames)+1)*gap(2))/length(objnames);
for i=1:length(objnames)
    object{i}=uicontrol('style','radiobutton','parent',buttongroup,...
                        'string',objnames{i},...
                        'units','norm',...
                        'backgroundcolor','w',...
                        'position',[marginleft 1-i*(bheight+gap(2)) bwidth bheight]);
end
set(buttongroup,'visible','on');
radioobj.group=buttongroup;
radioobj.items=object;
% Output object handles
switch nargout
    case 0
    case 1
        varargout{1}=radioobj;
    otherwise
end
