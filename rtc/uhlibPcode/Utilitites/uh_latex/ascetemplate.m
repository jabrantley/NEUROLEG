function ascetemplate(varargin)
filedir = get_varargin(varargin,'filedir',cd);
filename = get_varargin(varargin,'filename','Untitled_tex');
pdfopt = get_varargin(varargin,'pdf',1);
texfile = class_FileIO('filedir',filedir,'filename',[filename '.tex']);
fid = fopen(texfile.fullfilename,'w');

% fprintf(fid,'\\documentclass[Journal,letterpaper]{ascelike-new}\n');
fprintf(fid,'\\documentclass[10pt,]{article}\n');
%% Please choose the appropriate document class option:
% "Journal" produces double-spaced manuscripts for ASCE journals.
% "NewProceedings" produces single-spaced manuscripts for ASCE conference proceedings.
% "Proceedings" produces older-style single-spaced manuscripts for ASCE conference proceedings. 
%
%% For more details and options, please see the notes in the ascelike-new.cls file.

% Some useful packages...
fprintf(fid,'\\usepackage[utf8]{inputenc}\n');
fprintf(fid,'\\usepackage[T1]{fontenc}\n');
fprintf(fid,'\\usepackage{lmodern}\n');
fprintf(fid,'\\usepackage{graphicx}\n');
fprintf(fid,'\\usepackage[figurename=Fig.,labelfont=bf,labelsep=period]{caption}\n');
fprintf(fid,'\\usepackage{subcaption}\n');
fprintf(fid,'\\usepackage{amsmath}\n');
%\\usepackage{amsfonts}
%\\usepackage{amssymb}
%\\usepackage{amsbsy}
fprintf(fid,'\\usepackage{newtxtext,newtxmath}\n');
fprintf(fid,'\\usepackage[colorlinks=true,citecolor=red,linkcolor=black]{hyperref}\n');
%
% Please add the first author's last name here for the footer:
% fprintf(fid,'\\NameTag{AuthorOneLastName, \\today}\n');
% Note that this is not displayed if the NoPageNumbers option is used
% in the documentclass declaration.
%
fprintf(fid,'\\begin{document}\n');

% You will need to make the title all-caps
fprintf(fid,'\\title{Article Title}\n');

fprintf(fid,'\\author[1]{Trieu Phat Luu}\n');
fprintf(fid,'\\author[1]{Sho Nakagame}\n');
fprintf(fid,'\\author[1]{Yongtian He}\n');
fprintf(fid,'\\author[1,2]{Jose L Contreras-Vidal}\n');

% fprintf(fid,['\\affil[1]{Noninvasive Brain-Machine Interface System Laboratory, ',...
%             'Department of Electrical and Computer Engineering, ',...
%             'University of Houston, Houston, TX 77004, USA}\n']);
% fprintf(fid,'\\affil[2]{Tecnologico de Monterry, Escuela de Ingenieria y Ciencias, Mexico}\n');

fprintf(fid,'\\maketitle\n');

% % Please include an abstract:
fprintf(fid,'\\begin{abstract}\n');
fprintf(fid,sprintf('%s\n',writeabstract));
fprintf(fid,'\\end{abstract}\n');
% INTRODUCTION 
fprintf(fid,'\\section{Introduction}\n');
fprintf(fid,sprintf('%s\n',writeintroduction));
% METHODS
fprintf(fid,'\\section{Materials and methods}\n');
fprintf(fid,sprintf('%s\n',writemethod));
% METHODS
fprintf(fid,'\\section{Results}\n');
fprintf(fid,sprintf('%s\n',writeresults));

% fprintf(fid,'\\subsection{Experimental setup and procedure}\n');
% 
% For most ASCE journals, the maximum number of words and word-equivalents is 10,000 for technical papers, 3,500 for technical notes, and 2,000 for Discussions and Closures. The editor may waive these restrictions to encourage manuscripts on topics that cannot be treated within these limitations.
% 
% To find the current number of words in your manuscript on Overleaf, please use the \\href{https://www.overleaf.com/help/85}{Word Count} feature in the Project menu.
% 
% \\subsection{General Flow of the Paper}
% 
% Sections of the article should not be numbered and use word headings only. Article sections should appear in the following order:
% 
% \\begin{itemize}
% \\item Title page content (includes title, author byline \\& affiliation, abstract)
% \\item Introduction
% \\item Main text sections
% \\item Conclusion
% \\item Appendix(es)
% \\item Acknowledgments
% \\item Disclaimers
% \\item Notation list
% \\item Supplemental Data
% \\item References
% \\end{itemize}
% 
% \\subsection{Title}
% 
% Titles should be no longer than 100 characters including spaces. The title of a paper is the first ``description'' of a paper found via search engine. Authors should take care to ensure that the title is specific and accurately reflects the final, post-peer reviewed version of the paper. Authors should try to include relevant search terms in the title of the paper to maximize discoverability online.
% Titles should not begin with ``A,'' ``An,'' ``The,'' ``Analysis of,'' ``Theory of,'' ``On the,'' ``Toward,'' etc. 
% 
% \\subsection{Author Bylines}
% 
% Under the title of the manuscript, the full name of each author and his or her affiliation and professional designation, if applicable, must be included. The following professional designations are currently acceptable for all journals: Ph.D., P.E., S.E., D.WRE, DEE, P.Eng., C.Eng., L.S., P.L.S., Dr.Tech., Dr.Eng., D.Sc., Sc.D., G.E., P.G., P.H., AICP, J.D.
% 
% Former affiliations are permissible only if an author's affiliation has changed after a manuscript has been submitted for publication. If a coauthor has passed away, include the date of death in the affiliation line. Any manuscript submitted without a separate affiliation statement for each author will be returned to the corresponding author for correction.
% 
% \\subsection{Gender-specific Words}
% Authors should avoid ``he,'' ``she,'' ``his,'' ``her,'' and ``hers.'' Alternatively, words such as ``author,'' ``discusser,'' ``engineer,'' and ``researcher'' should be used.
% 
% \\subsection{First-person Usage}
% 
% The use of first-person pronouns (I, we, my, our) should be avoided in technical material. The use of ``the authors'' or ``this researcher'' is preferred to first-person pronouns.
% 
% For papers with a single author, ``the author'' should be used to indicate actions or opinions. Papers with multiple authors should use ``the authors'' to refer to collective actions or opinions. Authors should use first-person pronouns only if absolutely necessary to avoid awkward sentence construction.
% 
% \\subsection{Footnotes and Endnotes}
% 
% Footnotes and endnotes are not permitted in the text. Authors must incorporate any necessary information within the text of the manuscript.
% 
% \\textbf{Exception} - Endnotes are only permitted for use in the \\textit{Journal of Legal Affairs and Dispute Resolution in Engineering and Construction}.
% 
% \\subsection{SI Units}
% 
% The use of Système Internationale (SI) units as the primary units of measure is mandatory. Other units of measurement may be given in parentheses after the SI unit if the author desires. More information about SI units can be found on the \\href{http://physics.nist.gov/cuu/Units/index.html}{NIST website}.
% 
% \\subsection{Conclusions}
% 
% At the end of the manuscript text, authors must include a set of conclusions, or summary and conclusion, in which the significant implications of the information presented in the body of the text are reviewed. Authors are encouraged to explicitly state in the conclusions how the work presented contributes to the overall body of knowledge for the profession.
% 
% \\subsection{Acknowledgments}
% 
% Acknowledgments are encouraged as a way to thank those who have contributed to the research or project but did not merit being listed as an author. The Acknowledgments should indicate what each person did to contribute to the project.
% 
% Authors can include an Acknowledgments section to recognize any advisory or financial help received. This section should appear after the Conclusions and before the references. Authors are responsible for ensuring that funding declarations match what was provided in the manuscript submission system as part of the FundRef query. Discrepancies may result in delays in publication.
% 
% \\subsection{Mathematics}
% 
% All displayed equations should be numbered sequentially throughout the entire manuscript, including Appendices. Equations should be in the body of a manuscript; complex equations in tables and figures are to be avoided, and numbered equations are never permitted in figures and tables. Here is an example of a displayed equation (Eq.~\\ref{eq:Einstein}):
% \\begin{equation} \\label{eq:Einstein}
% E = m c^{2} \\;.
% \\end{equation}
% 
% Symbols should be listed alphabetically in a section called ``Notation'' at the end of the manuscript (preceding the references). See the folliowing section for more details.
% 
% \\subsection{Notation List}
% 
% Notation lists are optional; however, authors choosing to include one should follow these guidelines:
% 
% \\begin{itemize}
% \\item List all items alphabetically.
% \\item Capital letters should precede lowercase letters.
% \\item The Greek alphabet begins after the last letter of the English alphabet.
% \\item Non-alphabetical symbols follow the Greek alphabet.
% \\end{itemize}
% 
% Notation lists should always begin with the phrase, ``\\textit{The following symbols are used in this paper:}''; acronyms and abbreviations are not permitted in the Notation list except when they are used in equations as variables. Definitions should end with a semicolon. An example Notation list has been included in this template; see Appendix \\ref{app:notation}.
% 
% \\subsection{Appendices}
% 
% Appendices can be used to record details and data that are of secondary importance or are needed to support assertions in the text. The main body of the text must contain references to all Appendices. Any tables or figures in Appendices should be numbered sequentially, following the numbering of these elements in the text. Appendices must contain some text, and need to be more than just figures and/or tables. Appendices containing forms or questionnaires should be submitted as Supplemental Data instead.
% 
% 
% \\section{Sections, subsections, equations, etc.}
% 
% This section is included to explain and to test the formatting of sections, subsections, subsubsections, equations, tables, and figures. 
% 
% Section heading are automatically made uppercase; to include mathematics or symbols in a section heading, you can use the \\verb+\\lowercase{}+ around the content, e.g. \\verb+\\lowercase{\\boldmath$c^{2}$}+.
% 
% \\subsection{An Example Subsection}
% No automatic capitalization occurs with subsection headings; you will need to capitalize the first letter of each word, as in ``An Example Subsection.''
% 
% \\subsubsection{An example subsubsection}
% No automatic capitalization occurs with subsubsections; you will need to capitalize only the first letter of subsubsection headings.
% 
% \\section{Figures and Tables}
% 
% This template includes an example of a figure (Fig.~\\ref{fig:box_fig}) and a table (Table~\\ref{table:assembly}).
% 
% \\begin{figure}
% \\centering
% \\framebox[3.00in]{\\rule[0in]{0in}{1.00in}}
% \\caption{An example figure (just a box).  
% This particular figure has a caption with more information 
% than the figure itself, a very poor practice indeed.
% A reference here \\protect\\cite{Stahl:2004a}.}
% \\label{fig:box_fig}
% \\end{figure}
% 
% \\subsection{Figure Captions}
% 
% Figure captions should be short and to the point; they need not include a complete explanation of the figure.
% 
% \\subsection{Figure Files}
% 
% Figures should be uploaded as separate files in TIFF, EPS, or PDF format. If using PDF format, authors must ensure that all fonts are embedded before submission. Every figure must have a figure number and be cited sequentially in the text.
% 
% \\subsection{Color Figures}
% 
% Figures submitted in color will be published in color in the online journal at no cost. Color figures provided must be suitable for printing in black and white. Color figures that are ambiguous in black and white will be returned to the author for revision, and will delay publication. Authors wishing to have figures printed in color must indicate this in the submission questions. There is a fee for publishing color figures in print.
% 
% 
% \\section{Figure, Table and Text Permissions}
% 
% Authors are responsible for obtaining permission for each figure, photograph, table, map, material from a Web page, or significant amount of text published previously or created by someone other than the author. Permission statements must indicate permission for use online as well as in print.
% 
% ASCE will not publish a manuscript if any text, graphic, table, or photograph has unclear permission status. Authors are responsible for paying any fees associated with permission to publish any material. If the copyright holder requests a copy of the journal in which his or her figure is used, the corresponding author is responsible for obtaining a copy of the journal.
% 
% \\section{Supplemental Data}
% 
% Supplemental Data is considered to be data too large to be submitted comfortably for print publication (e.g., movie files, audio files, animated .gifs, 3D rendering files) as well as color figures, data tables, and text (e.g., Appendixes) that serve to enhance the article, but are not considered vital to support the science presented in the article. A complete understanding of the article does not depend upon viewing or hearing the Supplemental Data.
% 
% Supplemental Data must be submitted for inclusion in the online version of any ASCE journal via Editorial Manager at the time of submission.
% 
% Decisions about whether to include Supplemental Data will be made by the relevant journal editor as part of the article acceptance process. Supplemental Data files will be posted online as supplied. They will not be checked for accuracy, copyedited, typeset, or proofread. The responsibility for scientific accuracy and file functionality remains with the authors. A disclaimer will be displayed to this effect with any supplemental materials published online. ASCE does not provide technical support for the creation of supplemental materials.
% 
% ASCE will only publish Supplemental Data subject to full copyright clearance. This means that if the content of the file is not original to the author, then the author will be responsible for clearing all permissions prior to publication. The author will be required to provide written copies of permissions and details of the correct copyright acknowledgment. If the content of the file is original to the author, then it will be covered by the same Copyright Transfer Agreement as the rest of the article.
% 
% Supplemental Data must be briefly described in the manuscript with direct reference to each item, such as Figure S1, Table S1, Protocol S1, Audio S1, and Video S1 (numbering should always start at 1, since these elements will be numbered independently from those that will appear in the printed version of the article). Text within the supplemental materials must follow journal style. Links to websites other than a permanent public repository are not an acceptable alternative because they are not permanent archives.
% 
% When an author submits supplemental materials along with a manuscript, the author must include a section entitled ``Supplemental Data'' within the manuscript. This section should be placed immediately before the References section. This section should only contain a direct list of what is included in the supplemental materials, and where those materials can be found online. Descriptions of the supplemental materials should not be included here. An example of appropriate text for this section is ``Figs. S1–S22 are available online in the ASCE Library (\\href{http://ascelibrary.org/}{ascelibrary.org}).''
% 
% \\section{References, Citations and bibliographic entries}
% 
% ASCE uses the author-date method for in-text references, whereby the source reads as the last names of the authors, then the year (e.g., Smith 2004 or Smith and Jones 2004). A References section must be included that lists all references alphabetically by last name of the first author. 
% 
% When used together, \\texttt{ascelike-new.cls} and \\texttt{ascelike-new.bst} produce citations and the References section in the correct format automatically.
% 
% References must be published works only. Exceptions to this rule are theses, dissertations, and ``in press'' articles, all of which are allowed in the References list. References cited in text that are not found in the reference list will be deleted but queried by the copyeditor. Likewise, all references included in the References section must be cited in the text.
% 
% 
% The following citation options are available:
% \\begin{itemize}
% \\item
% \\verb+\\cite{key}+ produces citations with full author 
% list and year \\cite{Ireland:1954a}.
% \\item
% \\verb+\\citeNP{key}+ produces citations with full author list and year, 
% but without enclosing parentheses: e.g. \\citeNP{Ireland:1954a}.
% \\item
% \\verb+\\citeA{key}+ produces citations with only the full 
% author list: e.g. \\citeA{Ireland:1954a}
% \\item
% \\verb+\\citeN{key}+ produces citations with the full author list and year, but
% which can be used as nouns in a sentence; no parentheses appear around
% the author names, but only around the year: e.g. \\citeN{Ireland:1954a}
% states that \\ldots
% \\item
% \\verb+\\citeyear{key}+ produces the year information only, within parentheses,
% as in \\citeyear{Ireland:1954a}.
% \\item
% \\verb+\\citeyearNP{key}+ produces the year information only,
% as in \\citeyearNP{Ireland:1954a}.
% \\end{itemize}
% %
% \\par
% The bibliographic data base \\texttt{ascexmpl-new.bib}
% gives examples of bibliographic entries for different document types.
% These entries are from the canonical set in the
% ASCE web document ``Instructions For Preparation Of Electronic Manuscripts''
% and from the ASCE web-site.
% The References section of this document has been automatically created with
% the \\texttt{ascelike-new.bst} style for the following entries:
% \\begin{itemize}
% \\item a book \\cite{Goossens:1994a},
% \\item an anonymous book \\cite{Moody:1988a}, 
% \\item an anonymous report using \\texttt{@MANUAL} \\cite{FHWA:1991a}, 
% %\\item an anonymous newspaper story ("Educators" 1993), 
% \\item a journal article \\cite{Stahl:2004a,Pennoni:1992a}, 
% \\item a journal article in press \\cite{Dasgupta:2008a},
% \\item an article in an edited book using \\texttt{@INCOLLECTION} \\cite{Zadeh:1981a}, 
% \\item a building code using \\texttt{@MANUAL} \\cite{ICBO:1988a}, 
% \\item a discussion of an \\texttt{@ARTICLE} \\cite{Vesilind:1992a}, 
% \\item a masters thesis using \\texttt{@MASTERSTHESIS} \\cite{Sotiropulos:1991a},
% \\item a doctoral thesis using \\texttt{@PHDTHESIS} \\cite{Chang:1987a}, 
% \\item a paper in a foreign journal \\cite{Ireland:1954a}, 
% \\item a paper in a proceedings using \\texttt{@INPROCEEDINGS} 
%       \\cite{Eshenaur:1991a,Garrett:2003a}, 
% \\item a standard using \\texttt{@INCOLLECTION} \\cite{ASTM:1991a}, 
% \\item a translated book \\cite{Melan:1913a}, 
% \\item a two-part paper \\cite{Frater:1992a,Frater:1992b}, 
% \\item a university report using \\texttt{@TECHREPORT} \\cite{Duan:1990a}, 
% \\item an untitled item in the Federal Register using 
%       \\texttt{@MANUAL} \\cite{FR:1968a}, 
% \\item works in a foreign language \\cite{Duvant:1972a,Reiffenstuhl:1982a},
% \\item software using \\texttt{@MANUAL} \\cite{Lotus:1985a},
% \\item two works by the same author in the same year
%       \\cite{Gaspar:2001b,Gaspar:2001a}, and
% \\item two works by three authors in the same year that only share
%       the first two authors \\cite{Huang2009a,Huang2009b}.
% \\end{itemize}
% %
% \\par
% ASCE has added two types of bibliographic entries:
% web-pages and CD-ROMs.  A web-page can be formated using the
% \\texttt{@MISC} entry category, as with the item \\cite{Burka:1993a} produced
% with the following \\texttt{*.bib} entry:
% \\begin{verbatim}
%     @MISC{Burka:1993a,
%       author = {Burka, L. P.},
%       title = {A hypertext history of multi-user dimensions},
%       journal = {MUD history},
%       year = {1993},
%       month = {Dec. 5, 1994},
%       url = {http://www.ccs.neu.edu}
%     }
% \\end{verbatim}
% Notice the use of the ``\\texttt{month}'' field to give the date that material
% was downloaded and the use of a new ``\\texttt{url}'' field.
% The ``\\texttt{url}'' and \\texttt{month}'' 
% fields can also be used with other entry types
% (i.e., \\texttt{@BOOK}, \\texttt{@INPROCEEDINGS}, \\texttt{@MANUAL},
% \\texttt{@MASTERSTHESIS}, \\texttt{@PHDTHESIS}, and \\texttt{@TECHREPORT}):
% for example, in the entry type \\texttt{@PHDTHESIS} for \\cite{Wichtmann:2005a}.
% %
% \\par
% A CD-ROM can be referenced when using the \\texttt{@BOOK}, \\texttt{@INBOOK},
% \\texttt{@INCOLLECTION}, or \\texttt{@INPROCEEDINGS} categories, 
% as in the entry \\cite{Liggett:1998a}.
% The field ``\\texttt{howpublished}'' is used to designate the medium
% in the \\texttt{.bib} file:
% \\begin{verbatim}
%     howpublished = {CD-ROM},
% \\end{verbatim}
% %
% \\pagebreak
% %
% % Now we start the appendices, with the new section name, "Appendix", and a 
% %  new counter, "I", "II", etc.
% \\appendix
% %
% % And now for some pretty impressive notation.  In this example, I have used
% %   the tabular environment to line up the columns in ASCE style.
% %   Note that this and all appendices (except the references) start with 
% %   the \\section command
% %
% \\section{Notation}
% \\label{app:notation}
% \\emph{The following symbols are used in this paper:}%\\par\\vspace{0.10in}
% \\nopagebreak
% \\par
% \\begin{tabular}{r  @{\\hspace{1em}=\\hspace{1em}}  l}
% $D$                    & pile diameter (m); \\\\
% $R$                    & distance (m);      and\\\\
% $C_{\\mathrm{Oh\\;no!}}$ & fudge factor.
% \\end{tabular}
% 
% \\section{LaTeX Template Options}
% \\label{app:options}
% 
% The document class \\texttt{ascelike-new.cls} provides several options given below.
% The \\verb+Proceedings|+\\-\\verb+Journal|+\\-\\verb+NewProceedings+ option is the most important; the other options are largely incidental.
% 
% \\begin{enumerate}
% \\item
% Options
% \\verb+Journal|+\\verb+Proceedings|+\\verb+NewProceedings+ specify the overall format of the output man\\-u\\-script.  
% 
% \\texttt{Journal} produces double-spaced manuscripts for ASCE journals.
% As default settings, it places tables and figures at the end of the manuscript and produces lists of tables and figures.  
% It places line numbers within the left margin.
% 
% \\texttt{Proceedings} produces older-style camera-ready single-spaced 
% manu\\-scripts for ASCE conference proceedings.  
% The newer ASCE style is enacted with the \\verb+NewProceedings+ option.
% 
% \\texttt{NewProceedings} produces newer-style single-spaced 
% manu\\-scripts for ASCE conference proceedings, as shown on the 
% ASCE website (\\emph{ca.} 2013).  
% As default settings, \\verb+NewProceedings+ places figures and tables within the text. It does not place line numbers within the left margin.
% 
% If desired, the bottom right corner can be ``tagged'' with
% the author's name (this can be done by inserting the command
% \\verb+\\NameTag{<+\\emph{your name}\\verb+>}+ within the preamble of your
% document).
% All of the default settings can be altered with the options that are
% described below.
% 
% %
% \\item
% Options \\verb+BackFigs|InsideFigs+ can be used to override 
% the default placement of tables
% and figures in the \\texttt{Journal}, \\texttt{Proceedings}, and
% \\texttt{NewProceed\\-ings} formats.
% \\item
% Options \\verb+SingleSpace|DoubleSpace+ can be used to override 
% the default text spacing in the 
% \\texttt{Journal}, \\texttt{Proceedings}, and
% \\texttt{NewProceedings} formats.
% \\item
% Options \\verb+10pt|11pt|12pt+ can be used to override the 
% default text size (12pt).
% \\item
% The option \\texttt{NoLists} suppresses inclusion of lists of tables
% and figures that would normally be included in the \\texttt{Journal}
% format.
% \\item
% The option \\texttt{NoPageNumbers} suppresses the printing of page numbers.
% \\item
% The option \\texttt{SectionNumbers} produces an automatic numbering of sections.
% Without the \\texttt{SectionNumbers} option, sections will \\emph{not} be
% numbered, as this seems to be the usual formatting in ASCE journals 
% (note that the appendices will, however, be automatically
% ``numbered'' with Roman numerals).  
% With the \\texttt{SectionNumbers} option, sections and
% subsections are numbered with Arabic numerals (e.g. 2, 2.1, etc.), but
% subsubsection headings will not be numbered.  
% \\item
% The options \\verb+NoLineNumbers|LineNumbers+ can be used to override
% the default use (or absence) of line numbers in the \\texttt{Journal},
% \\texttt{Proceedings}, and
% \\texttt{NewProceedings} formats.
% \\end{enumerate}
% 
% %
% % Here's the list of references:
% %
% % \\label{section:references}
% \\bibliography{ascexmpl-new}
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