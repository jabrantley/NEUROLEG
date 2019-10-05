function [checkval,varargout] = uh_isfileExist(folder,filename,varargin)
type = get_varargin(varargin,'type','file'); % check for 'file' or 'folder'
ext = get_varargin(varargin,'ext','');
filelist = dir(folder); % List of files and folder inside input folder
checkval = 0;
thisfilename = '';
for i=1:length(filelist)
    [~, thisfilename, thisext] = fileparts(filelist(i).name);
    if strcmpi(type,'file') && filelist(i).isdir == 0
        if ~isempty(strfind(lower(thisfilename),lower(filename))) 
            if isempty(ext), checkval = 1; break;
            else % If check for file extension;
                if strcmpi(ext,thisext), checkval = 1; break; end
            end
        end
    elseif strcmpi(type,'folder') && filelist(i).isdir == 1
        if ~isempty(strfind(lower(thisfilename),lower(filename)))
            checkval=1; break;
        end
    end
end
if nargout == 2
    varargout{1} = thisfilename;
end