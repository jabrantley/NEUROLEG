function varargout=uigridcomp(uitype,varargin)
% Use methodsview javax.swing.xxx to view method of java comps
warning('off','MATLAB:uigridcontainer:MigratingFunction');
iconlist=getmatlabicons;
compnum=length(uitype); %number of ui components;
for i=1:compnum
    uistring{i}=icontext(iconlist.uh,'Label');
end
gridsize = get_varargin(varargin,'gridsize',[1 compnum]); % numbers of row and col
gridmargin = get_varargin(varargin,'gridmargin',5);
uistring = get_varargin(varargin,'uistring',uistring);
position = get_varargin(varargin,'position',[0.01,0.05,0.3,0.05]);
marginleft = position(1);marginbottom = position(2);
width = position(3); height = position(4);
hweight = get_varargin(varargin,'hweight',1);
vweight = get_varargin(varargin,'vweight',1);
fontsize = get_varargin(varargin,'fontsize',14);
slidermin = get_varargin(varargin,'slidermin',0);
slidermax = get_varargin(varargin,'slidermax',1);
max = get_varargin(varargin,'max',1);
gap = get_varargin(varargin,'gap',[0 0.1]); % for radio button
textalign = get_varargin(varargin,'textalign','center');
% Create container
container=uigridcontainer('units','norm','background','w',...
    'Position',[marginleft marginbottom width height],...
    'GridSize',gridsize,...
    'HorizontalWeight',hweight,...
    'VerticalWeight',vweight,...
    'margin',gridmargin,...
    'EliminateEmptySpace','off');
% Create Components
for i=1:compnum
    thisuitype=uitype{i};
    if strcmpi(thisuitype,'label')
        thisui = javaObjectEDT('javax.swing.JLabel',uistring{i});
        thisui.setBackground(java.awt.Color.white);
        thisui = handle(thisui,'CallbackProperties');
        javacomponent(thisui,[1 1 1 1],container);
    elseif strcmpi (thisuitype, 'edit')
        thisui= uicontrol('style','edit','background','w','Parent',container);
    elseif strcmpi (thisuitype,'jeditorpane')
        thisui=javaObjectEDT('javax.swing.JEditorPane');
        pane=javax.swing.JScrollPane(thisui);
        set(pane,'VerticalScrollBarPolicy',javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS,...
            'HorizontalScrollBarPolicy',javax.swing.ScrollPaneConstants.HORIZONTAL_SCROLLBAR_AS_NEEDED);
        javacomponent(pane,[1 1 1 1],container);
        thisui=handle(thisui,'CallbackProperties');
        %         get(thisui);
    elseif strcmpi (thisuitype,'mlist') % use listbox from matlab
        thisui= uicontrol('style','list','string',uistring{i},'background','w','Parent',container);
    elseif strcmpi (thisuitype, 'list')
        model=javaObjectEDT('javax.swing.DefaultListModel');
        for j=1:length(uistring{i}),model.addElement(uistring{i}{j}); end;
        thisui=javaObjectEDT('javax.swing.JList',model);
        pane=javax.swing.JScrollPane(thisui);
        set(pane,'VerticalScrollBarPolicy',javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_AS_NEEDED,...
            'HorizontalScrollBarPolicy',javax.swing.ScrollPaneConstants.HORIZONTAL_SCROLLBAR_AS_NEEDED);
        javacomponent(pane,[1 1 1 1],container);
        set(thisui,'FixedCellHeight',20);
        thisui=handle(thisui,'CallbackProperties');
    elseif strcmpi(thisuitype,'uitable')
        thisui = uitable(container);
        thisui.ColumnEditable = true;
        thisui.ColumnName = uistring{i};
        thisui.Units = 'Normalized';
        thisui.Position = [0 0 1 1];
        thisui.FontSize = 10;
    elseif strcmpi(thisuitype,'axes')
        thisui = axes(container);
    elseif strcmpi (thisuitype,'pushbutton')
        thisui= uicontrol('style','pushbutton','string',uistring{i},'background','w','Parent',container);
%     elseif strcmpi (thisuitype,'axes') % axes is not a uicontrol object.
%         thisui= uicontrol('style','axes','string',uistring{i},'background','w','Parent',container);
    elseif strcmpi (thisuitype, 'checkbox')
        thisui= uicontrol('style','checkbox','string',uistring{i},'background','w','Parent',container);
    elseif strcmpi(thisuitype,'radio')
        % Create buttongroup
        inputstr = uistring{i};
        buttongroup=uibuttongroup('units','norm','background','w',...
            'Position',[marginleft marginbottom width height],...
            'title',inputstr{1},'fontsize',fontsize,...
            'visible','off','parent',container);
        %button
        objnames = inputstr(2:end);
        bheight=(1-(length(objnames)+1)*gap(2))/length(objnames);
        for k=1:length(objnames)
            object{k}=uicontrol('style','radiobutton','parent',buttongroup,...
                'string',objnames{k},...
                'units','norm',...
                'backgroundcolor','w',...
                'position',[marginleft 1-k*(bheight+gap(2)) width bheight]);
        end
        set(buttongroup,'visible','on');
        thisui.group=buttongroup;
        thisui.items=object;
    elseif strcmpi (thisuitype, 'combobox')
        %         model = javax.swing.DefaultComboBoxModel(uistring{i});
        thisui=javaObjectEDT('javax.swing.JComboBox');
        thisui.setEditable(true);
        for j=1:length(uistring{i}), thisui.insertItemAt(uistring{i}{j},j-1);end
        javacomponent(thisui,[1 1 1 1], container);
        thisui = handle(thisui,'CallbackProperties');
        %         get(thisui)
    elseif strcmpi (thisuitype, 'popupmenu')
        thisui= uicontrol('style','popupmenu','string',uistring{i},'background','w','Parent',container);
    elseif strcmpi (thisuitype, 'slider')
        thisui=uicontrol('style','slider','Parent',container);
        set(thisui,'backgroundcolor','w')
    elseif strcmpi (thisuitype, 'dualslider')
        thisui = com.jidesoft.swing.RangeSlider(0,100,20,70);  % min,max,low,high %Range Slider
        javacomponent(thisui, [0,0,200,80], container);
        thisui=handle(thisui,'CallbackProperties');
        set(thisui,'PaintTicks',true,'PaintLabels',true,'Background',java.awt.Color.white);            %initialize
    elseif strcmpi (thisuitype,'syntaxtext')
        thisui=com.mathworks.widgets.SyntaxTextPane;
        thisui.setContentType(thisui.M_MIME_TYPE);  %Matlab syntax
        thisui.setCaretColor(java.awt.Color.white);
        thisui.setForeground(java.awt.Color.white);
        thisui.setBackground(java.awt.Color.black);
        thisui.setFont(thisui.getFont.deriveFont(1,6));
        
        % Add line number
        %         glyph = org.netbeans.editor.GlyphGutter(thisui.getEditorUI);
        %         glyph.setSize(java.awt.Dimension(2, thisui.getHeight));
        %         jPanel1 = javax.swing.JPanel; jPanel1.getLayout.setHgap(0);jPanel1.getLayout.setVgap(0);
        %         jPanel1.add(glyph);
        %         jPanel2 = javax.swing.JPanel(jPanel1.getLayout);
        %         jPanel2.add(jPanel1); jPanel2.add(thisui);
        %         pane=javax.swing.JScrollPane(jPanel2);
        pane=javax.swing.JScrollPane(thisui);
        set(pane,'VerticalScrollBarPolicy',javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS,...
            'HorizontalScrollBarPolicy',javax.swing.ScrollPaneConstants.HORIZONTAL_SCROLLBAR_AS_NEEDED);
        javacomponent(pane,[1 1 1 1],container);
        thisui=handle(thisui,'CallbackProperties');
    elseif strcmpi (thisuitype,'spinner')
    end
    uicomps{i}=thisui;
end
% Output object handles
switch nargout
    case 0
    case 1
        varargout{1}=container;
    otherwise
        varargout{1}=container;
        for i=1:length(uicomps)
            varargout{i+1}=uicomps{i};
        end
end
