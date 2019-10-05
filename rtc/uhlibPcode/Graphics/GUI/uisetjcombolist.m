function uisetjcombolist(jcombohdl,list)
jcombohdl.removeAllItems;
for i=length(list):-1:1
    jcombohdl.insertItemAt(list{i},0);
end
jcombohdl.setSelectedIndex(0);