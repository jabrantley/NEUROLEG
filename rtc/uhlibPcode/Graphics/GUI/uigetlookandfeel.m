function uigetlookandfeel
lafs=javax.swing.UIManager.getInstalledLookAndFeels;
for i=1:length(lafs)
    disp(lafs(i));
end
