function varargout=uigetjlistbox(jlistbox,varargin)
% This function get List of all items or selected Item in JListbox
% If item string in html, it will be converted to string.
%Outputs from this function,...
%Change output1, output2, etc to your output variables
selopt = get_varargin(varargin,'select','selected'); %selopt: selected for selected items or 'all'
htmlselitems={};
if strcmpi(selopt,'selected')
    selitems=char(jlistbox.getSelectedValues);
    for i=1:size(selitems,1)
        htmlselitems{i}=selitems(i,:);
    end
else
    model=jlistbox.getModel;
    for i=1:model.getSize
        htmlselitems{i}=model.getElementAt(i-1);
    end
end
strselitems = {};
if ~isempty(htmlselitems)
    for i = 1:length(htmlselitems)
        if ~isempty(strfind(htmlselitems{i},'html'))
            strselitems{i}=html2item(htmlselitems{i}); %If html string
        else
            strselitems{i}=htmlselitems{i};
        end
    end
end
switch nargout
    case 0
    case 1
        varargout{1}=strselitems;
    case 2
        varargout{1}=output1;
        varargout{2}=output2;
    otherwise
end