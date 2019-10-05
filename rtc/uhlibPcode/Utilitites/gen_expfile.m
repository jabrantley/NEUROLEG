function varargout = gen_expfile(varargin)
% INPUT: Optional
% 'dir': dirname;
% 'filename';
% 'ext'
% This function will generate a list of text file in inputdir.
% Format yyyy-mm-dd-filename-xxx
% xxx will be increased by one if filename is available.
%========
inputdir = get_varargin(varargin,'dir','.\');
inputfilename = get_varargin(varargin,'filename','samplefilename');
fileext = get_varargin(varargin,'ext','.txt');
fopenOption = get_varargin(varargin,'fopen',1);
diritems = dir(inputdir);
currfileidx = 0;
for i = 1:length(diritems)
    if diritems(i).isdir
    else
        thisavaifilename = diritems(i).name
        mark = strfind(thisavaifilename,'-')
        if ~isempty(mark)
            thisavai = thisavaifilename(1:mark(end)-1) % extract filetype name to compare with inputfilename
        else thisavai = thisavaifilename;
        end
%         thisavai = thisavaifilename;
        if strcmpi(thisavai,inputfilename) 
            % Find maximum file idx available, 
            markidx = strfind(thisavaifilename,'-');
            lastidx = markidx(end); %file index from the last '-' char
            thisfilenum = thisavaifilename(lastidx+1:lastidx+3); % fileidx is 3 digits
            currfileidx = max(currfileidx,str2double(thisfilenum));
        end
    end
end
currfileidx = currfileidx + 1;
if rem(currfileidx,100) == 0
    fileidxstr = ['-' num2str(currfileidx)];
elseif rem(currfileidx,10) == 0
    fileidxstr = ['-0' num2str(currfileidx)];
else
    fileidxstr = strrep(num2str(currfileidx/1000),'0.','-');
end
filegen = fullfile(inputdir,[inputfilename,fileidxstr,fileext]);
if fopenOption == 1
    outputfile_hdl = fopen(filegen,'w');
end
if nargout == 1
    varargout{1} = filegen;
elseif nargout == 2
    varargout{1} = filegen;
    varargout{2} = outputfile_hdl;
end
