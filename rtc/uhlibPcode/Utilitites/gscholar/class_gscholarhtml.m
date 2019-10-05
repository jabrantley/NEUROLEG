%% class_scholar.m
%% *Description:*
% This matlab script send request to google scholar, read article
% information, go to article pubisher and request to download pdf files.
%% *Usages:*
% gscholar = class_gscholar('author','jl contreras vidal','usewords','brain','from',2010,'pdfdir','.\')
% gscholar.fetch;
% gscholar.export_citation; % write citation into textfile, optional
% gscholar.open_citation;
% gscholar.export_pdf;
%
% *Inputs options:*
%   'author' : string format. default ''
%   'phrase' : search for this exact phrase. string format. default. ''
%   'usewords' : list of strings. e.g. 'usewords','eeg,brain' . default. ''
%   'excludewords' : exclude these words in the search.
%   'numpapers' : number of papers to search. format: integer. default: 30;
%   'from' : search for papers from this year. e.g. 2000. defaults.  10 years ago.
%   'to' : search for papers up to this year. default: this current year.
%   'publisher' : search for papers from this publisher.
% *Output Options:*
%   'txtfilename' : save citation info. default: citation.txt
%   'txtdir'    : directory to save the .txt filename. default. '.\'
%   'pdfdir'    : directory to save .pdf output files. default. '.\'
% *Notes:*
% Requirement:
% Python 3.4 or 3.5.
%   https://www.python.org/downloads/windows/
% BeautifulSoup4 for python. Instruction to download BeautifulSoup.
%   http://stackoverflow.com/questions/19957194/install-beautiful-soup-using-pip
% This srcipt modified scholar.py from https://github.com/ckreibich/scholar.py
% This current version cant request to read url and download papers from Nature and ncbi
%% *Authors:*
% * *MATLAB Ver :* 9.0.0.341360 (R2016a)
% * *Date Created :* 26-Oct-2016 14:36:21
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
classdef class_gscholarhtml < handle & hgsetget
    properties
        options; % input option from user input;
        articles; % articles objects
        pyquery; % python query object from scholar.py
        pyQuerier; % python querier object
        pysettings; % python settings object
        timeobj;    % handles time information;
        textfile; % text file for citation.
        pdffile;
        options_info;   % Display options information.
    end
    methods
        %Contructor
        function this = class_gscholarhtml(varargin)
            if count(py.sys.path,'') == 0 % Add the current working folder to python path.
                insert(py.sys.path,int32(0),'');
            end
            % Define constant variables
            this.timeobj.thisyear = year(datetime('now'));
            this.timeobj.today = datestr(now,'yyyy-mm-dd');
            % Parse options from user's input;
            this.options.author = get_varargin(varargin,'author','');
            this.options.phrase = get_varargin(varargin,'phrase','');
            this.options.usewords = get_varargin(varargin,'usewords','');
            this.options.excludewords = get_varargin(varargin,'excludewords','');
            this.options.numpapers = get_varargin(varargin,'numpapers',30);
            this.options.perpage = get_varargin(varargin,'perpage',20);
            this.options.before = get_varargin(varargin,'to',this.timeobj.thisyear);
            this.options.after = get_varargin(varargin,'from',this.timeobj.thisyear-10);
            this.options.citestyle = get_varargin(varargin,'citation','endnote');
            this.options.publisher = get_varargin(varargin,'publisher','');
            % Output files
            this.textfile.filename = get_varargin(varargin,'txtfilename','citation.txt');
            this.textfile.dir = get_varargin(varargin,'txtdir',pwd);
            this.textfile.fullfilename = fullfile(this.textfile.dir,this.textfile.filename)
            this.pdffile.dir = get_varargin(varargin,'pdfdir',pwd);
            %
            this.articles = get_varargin(varargin,'articles',{});
            % Number of page to search;
            this.get_citationindex; % Convert to number value for endnote,bibtex, etc options
            % Initialize python scholar
            % query object
            this.pyquery = py.scholar.SearchScholarQuery;
            this.pyquery.set_num_page_results(this.options.numpapers);
            this.pyquery.set_phrase(this.options.phrase);
            this.pyquery.set_timeframe(this.options.after, this.options.before)
            this.pyquery.set_pub(this.options.publisher);
            this.pyquery.set_author(this.options.author);
            this.pyquery.set_words_some(this.options.usewords);
            this.pyquery.set_words_none(this.options.excludewords);
            this.pyquery.set_start(int32(0));
            % Set Querier object.
            this.pyQuerier = py.scholar.ScholarQuerier;
            this.pysettings = py.scholar.ScholarSettings;
            this.pysettings.set_citation_format(this.options.citeidx);
            this.pysettings.set_per_page_results(this.options.perpage);
            % Initialize Querier object
            this.pyQuerier.apply_settings(this.pysettings);
            this.pyquery.get_url
%             this.pyQuerier._get_http_response(this.pyquery.get_url)
        end
        function fetch(this)
            % Send request to Google scholar with option inputs
            count = ceil(this.options.numpapers/this.options.perpage);
            for i = 1 : count
                fprintf('Fetching google scholar- Author: %s; Page: %02d/%02d.\n',this.options.author,i,count);
                startval = (i-1)*this.options.perpage;
                this.pyquery.set_start(int32(startval));
                this.pyQuerier.send_query(this.pyquery);
                pylist_articles = this.pyQuerier.articles; % python list type;
                this.articles = [this.articles cell(pylist_articles)];
            end
        end
        
        function export_citation(this)
            % Write all the citation information to a text file
            fid = fopen(this.textfile.fullfilename,'w');
            this.get_options_info;
            fprintf(fid,sprintf('%s. \n\n',this.options_info));
            for k = 1 : length(this.articles)
                article_info = this.get_article_info(this.articles{k});
                field = fieldnames(article_info);
                fprintf(fid,sprintf('[%04d]',k));
                for i = 1 : length(field)
                    fprintf(fid,[article_info.(field{i}).name, ': ']);
                    fprintf(fid,[article_info.(field{i}).value, '\n']);
                end
                fprintf(fid,'\n');
            end
            fclose(fid);
        end
        function open_citation(this)
            % Open citation textfile
            winopen(this.textfile.fullfilename);
        end
        
        function get_options_info(this)
            % Concatinate input options to a string.
            optionsfield = fieldnames(this.options);
            this.options_info = '';
            for i = 1 : length(optionsfield)
                thisfieldval = this.options.(optionsfield{i});
                if ~isempty(thisfieldval)
                    if ischar(thisfieldval)
                        this.options_info = strcat(this.options_info,...
                            sprintf(' %s: %s; ',this.capitalize(optionsfield{i}),strrep(thisfieldval,'\','/')));
                    else
                        this.options_info = strcat(this.options_info,...
                            sprintf(' %s: %d; ',this.capitalize(optionsfield{i}),thisfieldval));
                    end
                end
            end
        end
        
        function export_pdf(this,varargin)
            % Export pdf files
            if nargin == 1; articlesinput = this.articles;
            else, articlesinput = varargin{1}; end
            for i = 1 : length(articlesinput)                
                fprintf('URL link %03d- ',i);
                thisarticle = articlesinput{i};
                this.download_article(thisarticle);
            end
        end
        
        function download_article(this,article)
            % Download an article
            article_info = this.get_article_info(article);
            article_info.author = regexprep(this.options.author,'(\<[a-z])','${upper($1)}');
            article_info.title.value = this.validate_title(article_info.title.value);
            if isfield(article_info,'url')
                slash = strfind(article_info.url.value,'/');
                article_info.publisher = article_info.url.value(1:slash(3));
                if isempty(strfind(article_info.url.value,'scholar.google.com'))
                else
                    article_info.url.value = strrep(article_info.url.value,article_info.publisher,'');
                end
                slash = strfind(article_info.url.value,'/');
                article_info.publisher = article_info.url.value(1:slash(3));
                if ~isfield(article_info,'year'); article_info.year.value = '0000'; end
            else
                fprintf('Article: Not available \n');
                return;
            end
            % ----
            fprintf('Article: %s.\n',urlstr(article_info.url.value));
            this.pdffile.filename = sprintf('%s-%04d-%s-%s.pdf',...
                article_info.year.value,str2num(article_info.num_citations.value),article_info.author,article_info.title.value);
            this.pdffile.fullfilename = fullfile(this.pdffile.dir,this.pdffile.filename);
%             % ---Modify url for arxiv open source
            if ~isempty(strfind(article_info.url.value,'.pdf')) %% Attempt to download in case fulltext if available
                if this.download_pdflink(this.pdffile.fullfilename,article_info.url.value);
                    return;
                end
            end
            if ~isempty(strfind(article_info.url.value,'ieeexplore')) % IEEE EXPLORE Format
                argnumber = regexp(article_info.url.value,'(?<=arnumber=)[^arnumber=]\w*','match');
                if isempty(argnumber)
                    argnumber{1} = article_info.url.value(strfind(article_info.url.value,'document/')+length('document/'):end-1);                                        
                end 
                try article_info.url.value = [article_info.publisher 'stamp/stamp.jsp?arnumber=' argnumber{1}];
                catch; end;
            end
            article_info.pdflinklist = this.get_pdflink(article_info.url.value,article_info.publisher);
            for j = 1 : length(article_info.pdflinklist)
                pdflink = article_info.pdflinklist{j};
                if this.download_pdflink(this.pdffile.fullfilename,pdflink);
                    break;
                end
                if j == length(article_info.pdflinklist); fprintf(2, 'DOWNLOAD FAILED. \n'); end;
            end
        end
    end
    methods(Access=private)
        function get_citationindex(this)
            xin = this.options.citestyle;
            if isempty(xin)
                this.options.citeidx = 0;
            elseif any(strcmpi(xin,{'refworks','ref','refwork'}))
                this.options.citeidx = 1;
            elseif any(strcmpi(xin,{'refman'}))
                this.options.citeidx = 2;
            elseif any(strcmpi(xin,{'endnote','en'}))
                this.options.citeidx = 3;
            elseif any(strcmpi(xin,{'bibtex','bib','tex'}))
                this.options.citeidx = 4;
            else
            end
        end
    end
    methods(Static) %static method doesn't require obj
        function xout = capitalize(xin)
            xout = regexprep(xin,'(\<[a-z])','${upper($1)}');
        end
        function article_info = get_article_info(article)
            % Article is in structure format, each fieldname contains a python list.
            attrs = struct(article.attrs);
            attrskeys = fieldnames(attrs);
            for i = 1 : length(attrskeys)
                thiskey = attrskeys{i};
                thisattrs = cell(attrs.(thiskey));
                if strcmpi(class(thisattrs{1}),'py.NoneType');
                else
                    article_info.(char(thiskey)).value = char(thisattrs{1});
                    article_info.(char(thiskey)).name = char(thisattrs{2});
                end
            end
        end
        
        function title = validate_title(title)
            avoidchar = {'#','<','$','+','%','>','(',')','!','`','&','*','|','{','?','"','=','}','/',':','\','@','.',','};
            for i = 1 : length(avoidchar)
                title = strrep(title,avoidchar{i},'-');
            end
        end
        
        function status = download_pdflink(filename,pdflink)
            webopt = weboptions('Timeout',20);
            try
                fprintf('PDF link: %s. ',urlstr(pdflink));
                outputfilename = websave(filename,pdflink,webopt);
                [~,~,fileext] = fileparts(outputfilename);
                if strcmpi(fileext,'.pdf')
                    fprintf('DOWNLOAD OK. \n\n');
                    status = 1;
                elseif strcmpi(fileext,'.html')
                    fprintf('I dont want HTML.\n');
                    delete(outputfilename);
                    pause(0.5);
                    status = 0;
                end
            catch
                fprintf('---RETRY---> \n');
                status = 0;
            end
        end
        
        function pdflinklist = get_pdflink(thisurl,publisher)           
            webopt = weboptions('Timeout',10);
            try
            htmlstr = webread(thisurl,webopt);            
            catch
                fprintf(2,'Webread FAILED.\n');                
                pdflinklist = '';
                return;
            end
            pdfkey = {'.pdf','/pdf'};
            quotepos = strfind(htmlstr,'"');
            pdfpos = [];
            for i = 1 : length(pdfkey)
                thiskey = pdfkey{i};
                pdfpos = [pdfpos strfind(lower(htmlstr),thiskey)];
            end
            finalquote = [];
            k = 1;
            for i = 1 : length(pdfpos)
                thispos = pdfpos(i);
                startquote = quotepos(find(quotepos < thispos,1,'last'));
                endquote = quotepos(find(quotepos > thispos,1,'first'));
                if ~isempty(startquote) && ~isempty(endquote)
                    finalquote(k,:) = [startquote+1, endquote-1];
                    k = k + 1;
                end
            end            
            shortlinklist = {};
            for i = 1 : size(finalquote,1)
                shortlinklist{i,1} = htmlstr(finalquote(i,1):finalquote(i,2));
            end            
            if ~isempty(shortlinklist)
                shortlinklist(~cellfun('isempty',shortlinklist));
                copyshortlinklist = removechar(shortlinklist,'/');
                fulllinklist = strcat(publisher,copyshortlinklist);
                pdflinklist = [shortlinklist; fulllinklist];
            else
                fprintf(2, 'LINK FAILED.\n');
                pdflinklist = '';
            end
        end
    end
end

function yout = removechar(x,charin)
% Remove the first char of x if it matches with charin input;
if iscell(x)
    for i = 1 : length(x)
        thisx = x{i};
        if strcmpi(thisx(1),charin) == 1; thisx(1) = ''; end
        yout{i,1} = thisx;
    end
else
    if strcmpi(x(1),charin) == 1; x(1) = ''; end
    yout = x;
end
end

function yout = urlstr(url)
yout = sprintf('<a href="%s">%s</a>',url,url);
end