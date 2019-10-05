classdef class_pdfdownloader < handle & hgsetget
    properties
        article;
        pdflink;
        pdflinklist;
        pdffilename;
        savedir;
        status = 0;
        url;
    end
    methods
        %Contructor
        function this = class_pdfdownloader(varargin)
            this.article = get_varargin(varargin,'article','');
            this.pdflink = get_varargin(varargin,'pdflink','');
            this.savedir = get_varargin(varargin,'savedir',pwd);
            this.url = get_varargin(varargin,'url','');            
            this.pdffilename = get_varargin(varargin,'filename','untitled.pdf');
            if ~isempty(this.article)
                this.set_pdffilename;
                this.redirect;
%                 this.get_pdflink;
            end                        
        end             
        
        function download_article(this)        
            if isempty(this.url)
                fprintf('Article: Not available \n');
                return;
            end
            fprintf('Article: %s.\n',urlstr(this.url));            
%             % ---Modify url for arxiv open source
            if ~isempty(strfind(this.url,'.pdf')) %% Attempt to download in case fulltext if available
                this.pdflink = this.url;
                if this.download_pdflink;
                    return;
                end
            end            
            this.get_pdflink;
            for j = 1 : length(this.pdflinklist)
                this.pdflink = this.pdflinklist{j};
                if this.download_pdflink;
                    break;
                end
                if j == length(this.pdflinklist); fprintf(2, 'DOWNLOAD FAILED. \n'); end;
            end
        end
        
        function status = download_pdflink(this)
            webopt = weboptions('Timeout',20);            
            try
                fprintf('PDF link: %s. ',urlstr(this.pdflink));
                fullfile(this.savedir,this.pdffilename)
                outputfilename = websave(fullfile(this.savedir,this.pdffilename),this.pdflink,webopt);
                [~,~,fileext] = fileparts(outputfilename);
                if strcmpi(fileext,'.pdf')
                    fprintf('DOWNLOAD OK. \n\n');
                    status = 1;
                else
                    fprintf('Not pdf. Discard.\n');
                    delete(outputfilename);
                    pause(0.5);
                    status = 0;
                end
            catch
                fprintf('---RETRY---> \n');
                status = 0;
            end
        end
        
        function redirect(this)   
            if isempty(this.article.url)
                fprintf('url is empty.\n');
                return;
            end
            this.url = this.article.url;
            publisher = this.get_publisher(this.url);
            if isempty(strfind(this.url,'scholar.google'))
            else
                this.url = strrep(this.url,publisher,'');
                publisher = this.get_publisher(this.url);
            end
            if ~isempty(strfind(this.url,'ieeexplore')) % IEEE EXPLORE Format
                argnumber = regexp(this.url,'(?<=arnumber=)[^arnumber=]\w*','match');
                if isempty(argnumber)
                    argnumber{1} = this.url(strfind(this.url,'document/')+length('document/'):end-1);
                end
                try this.url = [publisher 'stamp/stamp.jsp?arnumber=' argnumber{1}];
                catch; end;
            end
        end
        
        function get_pdflink(this)   
            thisurl = this.url;
            publisher = this.get_publisher(thisurl);
            webopt = weboptions('Timeout',10);
            try
            htmlstr = webread(thisurl,webopt);            
            catch
                fprintf(2,'Webread FAILED.\n');                
                this.pdflinklist = '';
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
                this.pdflinklist = [shortlinklist; fulllinklist];
            else
                fprintf(2, 'LINK FAILED.\n');
                this.pdflinklist = '';
            end
        end
        
        function set_pdffilename(this)
            if ~isempty(this.article.title); title = this.article.title; else; title = 'untitled'; end;
            if ~isempty(this.article.citations); citations = this.article.citations; else; citations = 0; end;
            if ~isempty(this.article.author); author = this.article.author; else; author = 'nan'; end;
            author = capitalize(author);
            if ~isempty(this.article.year); yearinfo = this.article.year; else; yearinfo = 0; end;            
            filename = sprintf('%04d-%04d-%s-%s',yearinfo,citations,author,title);
            this.pdffilename = makeValidFilename(filename);
        end                        
        
    end
    methods(Static)
        function publisher = get_publisher(url)
            slash = strfind(url,'/');
            publisher = url(1:slash(3));                        
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