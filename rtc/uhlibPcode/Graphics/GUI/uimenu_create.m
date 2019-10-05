function varargout = uimenu_create(jMenuBar,handles,varargin)
import javax.swing.*
import java.awt.*
import java.awt.event.*
% ==
icon = [matlabroot '\toolbox\shared\controllib\general\resources\toolstrip_icons\MATLAB_16'];
mainmenu = get_varargin(varargin,'mainmenu','Main Menu');
menulist = get_varargin(varargin,'listmenu',{'Menu1','Menu2'});
menuicon = get_varargin(varargin,'icons',repmat({icon},1,length(menulist)));
callbackfcn = get_varargin(varargin,'callback',{'Menu1Fcn_Callback','Menu2Fcn_Callback'});
jMainMenu=JMenu(mainmenu);
jMenuBar.add(jMainMenu);
for i = 1: length(menulist)
    jMenuItem=JMenuItem(menulist{i},ImageIcon(menuicon{i}));
%     hjMenuItem = handle(jMenuItem,'CallbackProperties');
%     thisCallback = callbackfcn{i};
%     if ~isempty(thisCallback)
%         cmdstr = sprintf('set(hjMenuItem,''ActionPerformedCallback'',{@%s,handles});',thisCallback);
%         eval(cmdstr);
%     end    
    jMainMenu.add(jMenuItem);    
    AlljMenuItem{i} = jMenuItem;
end
if nargout == 1
    varargout{1} = jMainMenu;
elseif nargout == 2
    varargout{1} = jMainMenu;
    varargout{2} = AlljMenuItem;
else
end
