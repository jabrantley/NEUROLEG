%% template_draft.m
%% *Description:*
%% *Usages:*
%
% *Inputs:*
%
% *Outputs:*
%
% *Options:*
%
% *Notes:*
%
%% *Authors:*
% * *MATLAB Ver :* 9.0.0.341360 (R2016a)
% * *Date Created :* 03-Dec-2016 18:40:25
% * *Author:* Phat Luu. ptluu2@central.uh.edu
%
% _Laboratory for Noninvasive Brain Machine Interface Systems._
%
% _University of Houston_
%

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%%
function varargout = template_draft(varargin)
mfullfilename = mfilename('fullpath');
[mfiledir thismfilename] = fileparts(mfullfilename);
texfile = class_FileIO('filedir',mfiledir,'filename',thismfilename,'ext','.tex');
fid = fopen(texfile.fullfilename,'w');
pdfopt = get_varargin(varargin,'pdf',0);
%========DEFINES
global myfig;
article_title = 'Brain Machine Interface';
authors = {'Trieu Phat Luu','Sho Nakagame','Yongtian He', 'Jose L Contreras-Vidal'};
affilnote = {'1','1','1','1, 2'};
myaffil{1} = ['Noninvasive Brain-Machine Interface System Laboratory, ',...
    'Department of Electrical and Computer Engineering, ',...
    'University of Houston, Houston, TX 77004, USA'];
myaffil{2} = 'Tecnologico de Monterry, Escuela de Ingenieria y Ciencias, Mexico';
% Figure;
figpath = {...
           'figures/'};
myfig{1} = class_texfig('filename','test','ext','.jpg',...
    'caption','Test figure caption',...
    'label','fig_test');
%========
texprint(fid,'%');
texprint(fid,'% Simple template for generating drafts of papers and articles');
texprint(fid,'%');
texprint(fid,'\documentclass[10pt,]{article}');
texprint(fid,'\usepackage{authblk}');
texprint(fid,'\usepackage{fullpage}');
texprint(fid,'\usepackage{amssymb,amsmath}');
texprint(fid,'\usepackage[utf8x]{inputenc}');
texprint(fid,'\usepackage[T1]{fontenc}');
texprint(fid,'\usepackage{siunitx}');
texprint(fid,'\usepackage[version=3]{mhchem}');
texprint(fid,'');
texprint(fid,'\usepackage{natbib}');
texprint(fid,'\bibliographystyle{ametsoc2014}');
texprint(fid,'');
texprint(fid,'\usepackage[left]{lineno}');
texprint(fid,'\linenumbers');
texprint(fid,'');
texprint(fid,'\usepackage{setspace}');
texprint(fid,'\doublespacing');
texprint(fid,'');
texprint(fid,'\usepackage[unicode=true]{hyperref}');
texprint(fid,'\hypersetup{breaklinks=true,');
texprint(fid,'bookmarks=true,');
texprint(fid,'colorlinks=false,');
texprint(fid,'pdfborder={0 0 0}}');
texprint(fid,'\urlstyle{same} % don''t use a different (monospace) font for urls');
texprint(fid,'');
texprint(fid,'\setcounter{secnumdepth}{5}');
texprint(fid,'');
texprint(fid,'\usepackage{graphicx}');
% Add figure path
texfigpath = '';
for i = 1 : length(figpath)
    texfigpath = strcat(texfigpath,sprintf('{%s}',figpath{i}));
end
texprint(fid,sprintf('\\graphicspath{%s}',texfigpath));
texprint(fid,'');
texprint(fid,'\makeatletter');
texprint(fid,'\def\ScaleWidthIfNeeded{%');
texprint(fid,'\ifdim\Gin@nat@width>\linewidth');
texprint(fid,'\linewidth');
texprint(fid,'\else');
texprint(fid,'\Gin@nat@width');
texprint(fid,'\fi');
texprint(fid,'}');
texprint(fid,'\def\ScaleHeightIfNeeded{%');
texprint(fid,'\ifdim\Gin@nat@height>0.9\textheight');
texprint(fid,'0.9\textheight');
texprint(fid,'\else');
texprint(fid,'\Gin@nat@width');
texprint(fid,'\fi');
texprint(fid,'}');
texprint(fid,'\makeatother');
texprint(fid,'\setkeys{Gin}{width=\ScaleWidthIfNeeded,height=\ScaleHeightIfNeeded,keepaspectratio}%');
texprint(fid,'');
texprint(fid,'% ======================TITLE PAGE=========================');
texprint(fid,'');
texprint(fid,sprintf('\\title{%s}',article_title));
for i = 1 : length(authors)
    texprint(fid,sprintf('\\author[%s]{%s}',affilnote{i},authors{i}));
end
for i = 1 : length(myaffil)
    texprint(fid,sprintf('\\affil[%d]{%s}',i,myaffil{i}));
end
texprint(fid,'');
texprint(fid,'\date{\today}');
texprint(fid,'');
texprint(fid,'% ======================CONTENTS===========================');
texprint(fid,'');
texprint(fid,'\begin{document}');
texprint(fid,'');
texprint(fid,'\maketitle');
texprint(fid,'');
texprint(fid,'');
texprint(fid,'\newpage');
texprint(fid,'\section*{Abstract}');
texprint(fid, insert_Abstract);
texprint(fid,'\newpage');
texprint(fid,'');
texprint(fid,'% ======================INTRODUCTION=======================');
texprint(fid,'\section{Introduction}');
texprint(fid, insert_Introduction);
texprint(fid,'');
texprint(fid,'% ======================METHODS============================');
texprint(fid,'\section{Materials and Methods}');
texprint(fid, insert_Methods);
texprint(fid,'');
texprint(fid,'% ======================RESULTS============================');
texprint(fid,'\section{Results}');
texprint(fid, insert_Results);
texprint(fid,'% ======================DISCUSSIONS========================');
texprint(fid,'\section{Discussions}');
texprint(fid, insert_Discussions);
texprint(fid,'% ======================REFERENCES=========================');
texprint(fid,'\newpage\clearpage');
texprint(fid,'');
texprint(fid,'\renewcommand\refname{References}');
texprint(fid,'\bibliography{xampl.bib}');
texprint(fid,'\newpage');
texprint(fid,'');
texprint(fid,'\end{document}');
texprint(fid,'');
texprint(fid,'% ======================END================================');
%
winopen(texfile.fullfilename);
if pdfopt == 1
    strcmd = sprintf('pdflatex %s',texfullfilename);
    status = system(strcmd,'-echo');
end
fclose(fid);

function output = insert_Abstract(varargin)
output = [...
    'Write your abstract here.',...
    ];

function output = insert_Introduction(varargin)
output = [...
    'Paragraph 1. thetahip BCI-ctrl deltaband alphamuband',...
    texbreak,...
    'Paragraph 2.'];

function output = insert_Methods(varargin)
global myfig;
output = [...
    subsection('Experimental setup and procedure'),...
    'Figure \ref{fig:fig_test} shows an example figure.',...
    myfig{1}.insert,...
    'Paragraph 2.',...
    texbreak,...
    subsection('Data collection and signal processing for real-time BCI operations'),...
    'Paragraph 1.',...
    ];


function output = insert_Results(varargin)
output = [...
    subsection('Result 1'),...
    'Paragraph 1.',...
    texbreak,...
    'Paragraph 2.',...
    texbreak,...
    subsection('Result 2'),...
    'Paragraph 1.',...
    ];

function output = insert_Discussions(varargin)
output = [...
    'Paragraph 1.',...
    texbreak,...
    'Paragraph 2.'];

function output = subsection(str)
output = sprintf('\\subsection{%s}\n',str);

function output = texbreak
output = sprintf('\n\n');

