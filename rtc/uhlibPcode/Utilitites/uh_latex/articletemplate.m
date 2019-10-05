function articletemplate(varargin)
filedir = get_varargin(varargin,'filedir',cd);
filename = get_varargin(varargin,'filename','Untitled_tex');
pdfopt = get_varargin(varargin,'pdf',1);
texfile = class_FileIO('filedir',filedir,'filename',[filename '.tex']);
fid = fopen(texfile.fullfilename,'w');
%=========================================================================
% DEFINES
%=========================================================================


fprintf(fid,'\\title{Article Title}\n');
fprintf(fid,'\\author[1]{Trieu Phat Luu}\n');
fprintf(fid,'\\author[1]{Sho Nakagame}\n');
fprintf(fid,'\\author[1]{Yongtian He}\n');
fprintf(fid,'\\author[1,2]{Jose L Contreras-Vidal}\n');

% fprintf(fid,['\\affil[1]{Noninvasive Brain-Machine Interface System Laboratory, ',...
%             'Department of Electrical and Computer Engineering, ',...
%             'University of Houston, Houston, TX 77004, USA}\n']);
% fprintf(fid,'\\affil[2]{Tecnologico de Monterry, Escuela de Ingenieria y Ciencias, Mexico}\n');
%


fprintf(fid,'\\end{document}\n');
fclose(fid);
if pdfopt == 1
%     winopen(texfile.fullfilename);
    strcmd = sprintf('pdflatex %s',texfile.fullfilename);
    status = system('taskkill /IM foxitreader.exe','-echo');
    pause(1);
    status = system(strcmd,'-echo')
    winopen(strrep(texfile.fullfilename,'.tex','.pdf'));
end

function output = writeabstract(varargin)
output = ['Write your abstract here.\n\n',...
    ''];

function output = writeintroduction(varargin)
output = ['Paragraph 1.\n\n',...
    'Paragraph 2.\n\n'];

function output = writemethod(varargin)
output = ['\\subsection{Experimental setup and procedure}\n',...
    'Paragraph 1.\n\n',...
    'Paragraph 2.\n\n',...
    '\\subsection{Data collection}\n',...
    'Paragraph 1.\n\n',...
    'Paragraph 2.\n\n',...
    ];

function output = writeresults(varargin)
output = ['\\subsection{Result subsction 1.}\n',...
    'Paragraph 1.\n\n',...
    'Paragraph 2.\n\n',...    
    ];