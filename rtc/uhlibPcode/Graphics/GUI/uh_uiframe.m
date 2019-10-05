function varargout=uh_uiframe(varargin)
% Get input
% Usage;
% handles.figure = uh_uiframe;
%====
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
figname = get_varargin(varargin,'figname',mfilename);
unit = get_varargin(varargin,'units','pixel');
position = get_varargin(varargin,'position',[50,50,600,400]);
toolbaropt = get_varargin(varargin,'toolbar','none'); % 'figure';
menubaropt = get_varargin(varargin,'menubar','none');
statusbaropt = get_varargin(varargin,'statusbar',0);
waitbarpos = get_varargin(varargin,'waitbarpos','West');
waitbarstrOpt = get_varargin(varargin,'waitbarstr',1);
icon = get_varargin(varargin,'icon','./includes/icons/uhlogo12.png');
logopath = get_varargin(varargin,'logo','none');
logopos = get_varargin(varargin,'logopos',[0.89,0.79,0.2,0.2]);
% Create a new figure
myfig = findall(0, '-depth',1, 'type','figure', 'Name',figname);
if isempty(myfig)
    myfig = figure('Name',figname, 'NumberTitle','off',...
        'Visible','on', 'Color','w', 'units',unit,'Position',position,...
        'Toolbar',toolbaropt, 'MenuBar',menubaropt);
else
    clf(myfig);
    hc=findall(gcf); delete(hc(3:end));  % bypass javacomponent-clf bug on R2012b-R2013a
end
drawnow;
javaFrame = get(myfig,'JavaFrame');
% Frame-Icons
javaFrame.setFigureIcon(javax.swing.ImageIcon(icon));
% Add statusbar option
if statusbaropt==1
    jframefield=fieldnames(javaFrame); %get fHG1Client. R2014. fHG1, R2015, fHG2;
    cmdstr=sprintf('jRootPane=javaFrame.%s.getWindow;',jframefield{1});
    try
        eval(cmdstr);
        jstatusbar = com.mathworks.mwswing.MJStatusBar;        
        jwaitbar = javax.swing.JProgressBar;        
        set(jwaitbar, 'Minimum',0, 'Maximum',100,...
            'Value',0,'Indeterminate',0,'stringpainted',waitbarstrOpt);
        jstatusbar.add(jwaitbar,waitbarpos);  % 'West' => left of text; 'East' => right
        jwaitbar.setLocation(java.awt.Point(50,0));
        % Beware: 'East' also works but doesn't resize automatically
        jRootPane.setStatusBar(jstatusbar);
        jstatusbarhdl=handle(jstatusbar);
        jwaitbarhdl= handle(jwaitbar);
    catch ME
        ME.message;
        jstatusbarhdl=0;
        jwaitbarhdl=0;
    end
end
% Add Logo
if ~strcmpi(logopath,'none')    
    htmlstr = ['<html><img src="file:/' logopath '">'];
    jeditorpane=javax.swing.JEditorPane('text/html',htmlstr);
    jeditorpane.setEditable(false);
    [~, container]=javacomponent(jeditorpane,[],myfig);
    set(container,'Units','norm','Pos',logopos);
end
%Outputs from this function,...
%Change output1, output2, etc to your output variables
switch nargout
    case 0
    case 1
        varargout{1}=myfig;
    case 2
        varargout{1}=myfig;
        varargout{2}=jstatusbarhdl;
    case 3
        varargout{1}=myfig;
        varargout{2}=jstatusbarhdl;
        varargout{3}=jwaitbarhdl;
    otherwise
end
