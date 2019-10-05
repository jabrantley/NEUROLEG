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
classdef gscholar < handle & hgsetget
    properties        
        timeobj;
        outputfiles;        
        jsoupfetcher;
        pdfdownloader;
        jsouppath;
        topauthors;
        articles;
        gquerier;
    end
    methods
        %Contructor
        function this = gscholar(varargin)            
            % Define constant variables
            this.timeobj.thisyear = year(datetime('now'));
            this.timeobj.today = datestr(now,'yyyy-mm-dd');
            this.timeobj.now = datestr(now,'yyyy-mm-dd-HH-MM');            
            % Input options;
            % Initialize objects;
            this.gquerier = class_gscholarpage('pythonpath','C:\Phat Luu\MatlabCode\uhlib\Utilitites\gscholar');
            this.jsouppath = get_varargin(varargin,'jsouppath','C:\Phat Luu\MatlabCode\uhlib\Utilitites\gscholar\jsoup-1.10.1.jar');
            this.gquerier.options.start = get_varargin(varargin,'start',0);
            this.gquerier.options.author = get_varargin(varargin,'author','');
            this.gquerier.options.usewords = get_varargin(varargin,'usewords','');
            this.gquerier.options.excludewords = get_varargin(varargin,'excludewords','');
            this.gquerier.options.phrase = get_varargin(varargin,'phrase','');                                    
            this.gquerier.options.publisher = get_varargin(varargin,'publisher','');
            this.gquerier.options.to = get_varargin(varargin,'to',this.timeobj.thisyear);
            this.gquerier.options.from = get_varargin(varargin,'from',this.timeobj.thisyear-10);
            this.gquerier.options.perpage = get_varargin(varargin,'perpage',20);    
            this.gquerier.options.numpapers = get_varargin(varargin,'numpapers',30);   
            
            this.jsoupfetcher = class_jsoupfetcher('jsouppath',this.jsouppath);            
            % Output files            
            this.outputfiles.txt_citation.dir = get_varargin(varargin,'txtdir',pwd);            
            this.outputfiles.pdf_article.dir = get_varargin(varargin,'pdfdir',pwd);
            this.outputfiles.enw_article.dir = get_varargin(varargin,'enwdir',pwd);
            this.outputfiles.mat_author.dir = get_varargin(varargin,'matdir',pwd);
            this.outputfiles.mat_articles.dir = this.outputfiles.mat_author.dir;
            this.outputfiles.mat_author.filename = [this.timeobj.now, '-gscholar-authors.mat'];
            this.outputfiles.mat_articles.filename = [this.timeobj.now, '-gscholar-articles.mat'];
            this.outputfiles.txt_citation.fullfilename = fullfile(this.outputfiles.txt_citation.dir,[this.timeobj.now, '-citation.txt']);
            this.outputfiles.mat_author.fullfilename = fullfile(this.outputfiles.mat_author.dir,this.outputfiles.mat_author.filename);                                                            
            this.outputfiles.mat_articles.fullfilename = fullfile(this.outputfiles.mat_articles.dir,this.outputfiles.mat_articles.filename);            
        end        
        
        function export_citation(this)
            % Write all the citation information to a text file
            fid = fopen(this.outputfiles.txt_citation.fullfilename,'w');            
            fprintf(fid,sprintf('%s. \n\n',this.gquerier.url));
            for k = 1 : length(this.jsoupfetcher.articles)
                article_info = this.jsoupfetcher.articles{k};
                field = fieldnames(article_info);
                fprintf(fid,sprintf('[%04d]',k));
                for i = 1 : length(field)
                    fprintf(fid,[article_info.(field{i}).name, ': ']);
                    fprintf(fid,[article_info.(field{i}).value, '\n']);
                end
                websave(this.outputfiles.enw_article.fullfilename,article_info.enwlink);
                fprintf(fid,'\n');
            end
            fclose(fid);
        end
        
        function export_endnote(this,varargin)
            % Export pdf files
            if nargin == 1; articlesinput = this.articles;
            else, articlesinput = varargin{1}; end
            for i = 1 : length(articlesinput) 
                thisarticle = articlesinput(i);
                if ~isempty(thisarticle.enwlink)
                    pause(8);                    
                    enwfilename = makeValidFilename(thisarticle.title);
                    fprintf('Endnote file: %s.\n',enwfilename);                    
                    websave(fullfile(this.outputfiles.enw_article.dir,enwfilename),thisarticle.enwlink);
                end
            end
        end
        
        function export_author(this)
            numpaper = this.gquerier.options.numpapers;
            if numpaper < 40; numpaper = 40; end;                
            perpage = this.gquerier.options.perpage;
            startnum = ceil(numpaper/perpage);     
            authors = [];
            for i = 1 : startnum  
                pause(5);
                this.gquerier.options.start = (i-1)*perpage;
                this.gquerier.queryurl;
                this.jsoupfetcher.url = this.gquerier.url;
                fprintf('Start=%d.\n',i);
                fprintf('url:%s.\n',urlstr(this.gquerier.url));
                this.jsoupfetcher.fetch_topauthor;
                if isempty(authors); authors = this.jsoupfetcher.authors;
                else authors = [authors, this.jsoupfetcher.authors]; end;
            end            
            allurl = {};
            for i = 1 : length(authors)                
                allurl{i} = authors(i).url;
            end
            [~,uniqueid] = unique(allurl);
            authors = authors(uniqueid);                        
            sorttype = 'h_index';
            [~, ID] = sort([authors.(sorttype)],'descend');
            authors = authors(ID);
            this.topauthors = authors;            
            save(this.outputfiles.mat_author.fullfilename,'authors','-v7.3');
        end
        
        function export_articles(this)
            numpaper = this.gquerier.options.numpapers;            
            perpage = this.gquerier.options.perpage;
            startnum = ceil(numpaper/perpage);                 
            allarticles = [];
            for i = 1 : startnum  
                pause(5);
                this.gquerier.options.start = (i-1)*perpage;
                this.gquerier.queryurl;
                this.jsoupfetcher.url = this.gquerier.url;
                fprintf('Start=%d.\n',i);
                fprintf('url:%s.\n',urlstr(this.gquerier.url));
                this.jsoupfetcher.fetch_articles;
                if isempty(allarticles); allarticles = this.jsoupfetcher.articles;
                else allarticles = [allarticles, this.jsoupfetcher.articles];end
            end    
            gscholar_url = this.gquerier.url;
            this.articles = allarticles;
            assignin('base','allarticles',allarticles);        
            save(this.outputfiles.mat_articles.fullfilename,'allarticles','gscholar_url','-v7.3');
        end
        
        function plot_topauthors(this)    
            authors = this.topauthors;
            url = this.jsoupfetcher.url;            
            check = {};
            for i = 1 : length(authors)                
                check{i} = authors(i).url;
            end
            [~,uniqueid] = unique(check);
            newauthors = authors(uniqueid);
            dupauthors = authors(setdiff(1:length(authors),uniqueid));            
            
            sorttype = 'h_index';
            [~, ID] = sort([newauthors.(sorttype)],'descend');
            sortauthors = newauthors(ID(1:min(30,length(newauthors))));
            assignin('base','sortauthors',sortauthors);
            
            paper = [0 0 6 4];
            myfig=figure('unit','inches','position',[0 0 paper(3) paper(4)],'color','w');
            axclass = class_axes('gridsize',[1 1 1],'position',[0.08 0.06 0.9 0.85],'gapw',0,'gaph',0,'show',1);
            
            barhdl = bar([sortauthors.(sorttype)],'barwidth',0.6);
            xdata = get(barhdl,'xdata');
            for i = 1 : length(xdata)
                texthdl = text(xdata(i),sortauthors(i).(sorttype),sprintf('%s-%d',sortauthors(i).name,sortauthors(i).Citations));
                set(texthdl,'horizontalalignment','left','verticalalignment','bottom','rotation',20,'fontsize',5);
            end
            limx = [xdata([1,end])]+[-1 2];
            limy = get(gca,'ylim');
            set(gca,'xlim',limx);
            ylabel(sprintf('%s',sorttype));
            set(gca,'xtick',xdata(1):10:xdata(end));
            box off;
            myprinter = class_export_fig('filename',this.outputfiles.mat_author.filename,...
                'format','jpg','resolution',800,'paper',paper,'handles',gcf);
            myprinter.export;            
        end
        
        function export_pdf(this,varargin)
            % Export pdf files
            if nargin == 1; articlesinput = this.articles;
            else, articlesinput = varargin{1}; end
            for i = 1 : length(articlesinput) 
                pause(3);
                fprintf('URL link %03d- ',i);
                thisarticle = articlesinput(i);
                this.pdfdownloader = class_pdfdownloader('savedir',this.outputfiles.pdf_article.dir,...
                    'article',thisarticle);
                this.pdfdownloader.download_article;
            end
        end                
    end  
end