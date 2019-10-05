function item=html2item(htmlitem)
% Convert list item in html format to filename
mark1=strfind(htmlitem,'>');
if ~isempty(mark1), mark1=mark1(end-1)+1; end
mark2=strfind(htmlitem,'<');
if ~isempty(mark2), mark2=mark2(end)-1; end
if ~isempty(mark1) && ~isempty(mark2)
    item=htmlitem(mark1:mark2);
else
    item = htmlitem;
end
