function logMessage(text,jEditbox,varargin)
% Parse the severity and prepare the HTML message segment
useicon = get_varargin(varargin,'useicon','');
fontcolor = get_varargin(varargin,'fontcolor','black');
% Ensure we have an HTML-ready editbox
HTMLclassname = 'javax.swing.text.html.HTMLEditorKit';
if ~isa(jEditbox.getEditorKit,HTMLclassname)
    jEditbox.setContentType('text/html');
end
msgTxt = ['&nbsp;<font color=',fontcolor,'>',datestr(now,'HH:MM:SS'),'&nbsp;',text,'</font>'];
msgTxt = strrep(msgTxt,'\','/');
if ~isempty(useicon)
    iconTxt =['<img src="file:///',useicon,'" height=16 width=16>'];
    newText = [iconTxt,msgTxt];
else
    newText=msgTxt;
end
endPosition = jEditbox.getDocument.getLength;
if endPosition>0
    newText=['<br/>' newText];  
end
% Place the HTML message segment at the bottom of the editbox
currentHTML = char(jEditbox.getText);
jEditbox.setText(strrep(currentHTML,'</body>',newText));
endPosition = jEditbox.getDocument.getLength;
jEditbox.setCaretPosition(endPosition); % end of content