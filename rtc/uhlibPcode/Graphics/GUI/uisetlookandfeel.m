function uisetlookandfeel(type)
% type: 'metal', 'nimbus', 'motif', 'window';
if strcmpi(type,'metal')
    % metal
    javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.metal.MetalLookAndFeel');
elseif strcmpi(type,'nimbus')
    % Nimbus
    javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.nimbus.NimbusLookAndFeel');
elseif strcmpi(type,'motif')
    % Motif
    javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.motif.MotifLookAndFeel');
elseif strcmpi(type,'window')
    % window
    javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsLookAndFeel');
else
    % classic window
    javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsClassicLookAndFeel');
end
