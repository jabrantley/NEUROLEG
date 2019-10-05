function uisetjlistbox(jlistbox,items)
model=get(jlistbox,'Model'); 
model.removeAllElements;
set(jlistbox,'Model',model);
for i=1:length(items)
    model.addElement(items{i});
end