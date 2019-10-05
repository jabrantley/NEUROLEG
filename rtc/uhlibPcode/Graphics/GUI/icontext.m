function icontext=icontext(useicon,text,varargin)
fontcolor = get_varargin(varargin,'fontcolor','black');
fontsize = get_varargin(varargin,'fontsize',4);
iconh = get_varargin(varargin,'iconh',16);
iconw = get_varargin(varargin,'iconw',12);
fontcolor='black';
iconTxt=sprintf('<html><img src="file:/%s" height=%d width=%d/>',useicon,iconh,iconw);
msgTxt = ['&nbsp;<font color=',fontcolor,'>',text,'</font>'];
icontext = [iconTxt,msgTxt];