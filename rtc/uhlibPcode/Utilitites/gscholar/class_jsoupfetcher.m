classdef class_jsoupfetcher < handle & hgsetget
    properties
        url;
        jsouppath;
        authors;
        articles;
        mainpage = 'https://scholar.google.com';
    end

    methods
        %Contructor
        function this = class_jsoupfetcher(varargin)
            this.jsouppath = get_varargin(varargin,'jsouppath','.\jsoup-1.10.1.jar');
            this.url = get_varargin(varargin,'url','');
            javaaddpath(this.jsouppath);            
        end
        function fetch_topauthor(this)
            import org.jsoup.*;
            import org.jsoup.nodes.*;
            import org.jsoup.parsers.*;
            import org.jsoup.helper.*;
            import org.jsoup.select.*;
            html = webread(this.url);
%             html = evalin('base','html')
            jsoupdoc = Jsoup.parse(html);
            gusers = jsoupdoc.select('[href^=/citations?user]');
            cellauthors = cell(gusers.toArray);
            assignin('base','cellauthors',cellauthors);
            k = 1;
            for i = 1 : length(cellauthors)
                pause(0.5);
                authorname = char(cellauthors{i}.text());
                this.authors(k).name = authorname;
                href = cellauthors{i}.attr('href');
                abshref = [this.mainpage char(href)];
                this.authors(k).url = abshref;
%                 HttpConnection = Jsoup.connect(href) ;  % Jsoup.connect(url) returns helper class;
%                 HttpConnection.userAgent(userAgent);
%                 doc = HttpConnection.get();
                html = webread([this.mainpage char(href)]);
%                 assignin('base','jsoupdoc',jsoupdoc)
%                 html = evalin('base','jsoupdoc');
                jsoupdoc = Jsoup.parse(html);
                temp = jsoupdoc.select('td.gsc_rsb_sc1').text(); % Fieldnames Citations, h-index, i10-index
                fieldnames = strsplit(char(temp));
                temp = jsoupdoc.select('td.gsc_rsb_std').text(); % Values of Citaitons, h-index, i10-index;
                values = strsplit(char(temp));
                for j = 1 : length(fieldnames)
                    this.authors(k).(matlab.lang.makeValidName(fieldnames{j})) = str2num(values{j*2-1});
                end
                k = k + 1;
            end
            assignin('base','authors',this.authors)
        end
        function fetch_articles(this)
            import org.jsoup.*;
            import org.jsoup.nodes.*;
            import org.jsoup.parsers.*;
            import org.jsoup.helper.*;
            import org.jsoup.select.*;
%             html = webread(this.url);
            html = this.get_html(this.url);       
            jsoupdoc = Jsoup.parse(html);
            temp = jsoupdoc.select('div.gs_ri');
            paperlist = cell(temp.toArray);            
            for i = 1 : length(paperlist)
                pause(3);
                thishtml = paperlist{i};
                this.articles(i).title = char(thishtml.select('h3.gs_rt').text());
                this.articles(i).url = char(thishtml.select('h3.gs_rt').select('[href]').attr('abs:href'));
                fprintf('Article No:%02d-%s.\n',i,urlstr(this.articles(i).url));
                try
                    this.articles(i).year = str2num(char(regexp(char(thishtml.select('div.gs_a').text()),'\d{4}','match')));
                catch
                    this.articles(i).year = 0000;
                end
                temp = char(thishtml.select('div.gs_a').text());
                cellstr = strsplit(temp, ',');
                this.articles(i).author = cellstr{1};
                this.articles(i).citations = str2num(char(regexp(char(thishtml.select('div.gs_fl').select('[href^=/scholar?cites]').text()),'\d\w*','match')));
                temp = regexp(char(thishtml.select('[href^=/scholar?q]').attr('href')),'\:','split');
                try
                    id = temp{2};
                    endnoteurl = sprintf('https://scholar.google.com/scholar?q=related:%s:scholar.google.com/&output=cite',id);
%                     html = webread(endnoteurl);                    
%                     html = this.get_html(endnoteurl);
%                     enwdoc = Jsoup.parse(html);
%                     this.articles(i).enwlink = char(enwdoc.select('[href*=scholar.enw]').attr('abs:href'));
%                     this.articles(i).enwlink = endnoteurl;
                    this.articles(i).citelink = endnoteurl;
                catch
                    this.articles(i).enwlink = '';
                end
            end
        end        
    end
    methods(Static)
        function htmlout = get_html(url)
            USER_AGENT = 'Mozilla/5.0 (X11; Linux x86_64; rv:27.0) Gecko/20100101 Firefox/27.0';
            pyQuerier = py.scholar.ScholarQuerier;
            req = py.scholar.Request(url);
            req.headers = py.dict(pyargs('User-Agent',USER_AGENT));
            hdl = pyQuerier.opener.open(req);
            htmlout = char(hdl.read());
        end
    end
end