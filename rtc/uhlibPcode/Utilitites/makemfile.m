function makemfile(varargin)
author = get_varargin(varargin,'author','Phat Luu');
email = get_varargin(varargin,'email','ptluu2@central.uh.edu');
filename = get_varargin(varargin,'filename','Untitled');
filedir = get_varargin(varargin,'filedir',cd);
templateFilename = get_varargin(varargin,'template','Untitled.m');
outputFiletype = get_varargin(varargin,'ext','.m');
[~,~,templateFiletype] = fileparts(templateFilename);
if isempty(templateFiletype)
    templateFiletype = '.m';
end
if outputFiletype(1) ~= '.'
    outputFiletype = ['.', outputFiletype];
end
% Locate to tempate file mdir
mfilepath = mfilename('fullpath');
[mdir, ~, ~] = fileparts(mfilepath);
template_mfile = class_FileIO('filedir',mdir,'filename',templateFilename,'ext',templateFiletype);
outputFile = class_FileIO('filedir',filedir,'filename',filename,'ext', outputFiletype);
if strcmpi(outputFiletype, '.m')
    headerType = 'matlab';
elseif any(strcmpi({'.ino','.cpp','.h','.c'},outputFiletype))
    headerType = 'c';
else
end

% Start
ex = exist(fullfile(filedir,[filename,'.m'])); % does M-file already exist ? Loop statement
newfcnname = filename;
k = 1;
while ex == 2         % rechecking existence
    fprintf('Filename Exist: %s .\n',newfcnname);
    newfcnname = sprintf('%s-%03d',filename,k);
    k = k + 1;
    ex = exist(fullfile(filedir,[newfcnname,'.m']));   
end
filename = [newfcnname outputFiletype]; % Create .m file name;
fprintf('Filename Created:%s.\n',filename);
%-----
headerlines = create_headerinfo(filename,author,email,...
    'header', headerType);
fid = fopen(outputFile.fullfilename,'w'); % Open file for writing;
for j=1:length(headerlines)
    fprintf(fid,'%s\n', headerlines{j});
end
% Add the template file
texlines = template_mfile.uh_textscan;
checkcond = 0;
for i = 1 : length(texlines)    
    thisline = texlines{i};
    if strfind(thisline,'function') == 1 & checkcond == 0
        fprintf(fid,'function varargout = %s(varargin)\n',outputFile.filename);
        checkcond = 1;
    elseif strfind(thisline,'classdef') == 1 & checkcond == 0
        fprintf(fid,'classdef %s < hgsetget;\n',outputFile.filename);
        checkcond = 1;
    else
        fprintf(fid,'%s \n',texlines{i});
    end    
end
fclose(fid);
edit(outputFile.fullfilename);