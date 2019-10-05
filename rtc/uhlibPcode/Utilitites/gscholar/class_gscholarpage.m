classdef class_gscholarpage < handle & hgsetget
    properties
        scholar_site = 'https://scholar.google.com';        
        url;
        pythonpath;
        pyquery;
        thisyear = year(datetime('now'));               
    end
    properties (SetObservable)
        options;
    end
    methods
        %Contructor
        function this = class_gscholarpage(varargin)
            this.pythonpath = get_varargin(varargin,'pythonpath','');
            if count(py.sys.path,this.pythonpath) == 0 % Add the current working folder to python path.
                insert(py.sys.path,int32(0),this.pythonpath);
            end
            this.options.start = get_varargin(varargin,'start',0);
            this.options.author = get_varargin(varargin,'author','');
            this.options.usewords = get_varargin(varargin,'usewords','');
            this.options.excludewords = get_varargin(varargin,'excludewords','');
            this.options.phrase = get_varargin(varargin,'phrase','');                                    
            this.options.publisher = get_varargin(varargin,'publisher','');
            this.options.to = get_varargin(varargin,'to',this.thisyear);
            this.options.from = get_varargin(varargin,'from',this.thisyear-10);
            this.options.perpage = get_varargin(varargin,'perpage',20);    
            this.options.numpapers = get_varargin(varargin,'numpapers',30);   
            this.options.start = get_varargin(varargin,'start',0);
%             if ~ischar(this.options.start); this.options.start = num2str(this.options.start);end
%             if ~ischar(this.options.to); this.options.to = num2str(this.options.to);end
%             if ~ischar(this.options.from); this.options.from = num2str(this.options.from);end
%             if ~ischar(this.options.perpage); this.options.perpage = num2str(this.options.perpage);end            
            % query object
            this.pyquery = py.scholar.SearchScholarQuery;                        
            this.queryurl;
            % Set observation;
%             addlistener(this,'options','PostSet',@this.listener_options_Callback);
        end
        function queryurl(this)
            this.pyquery.set_num_page_results(this.options.numpapers);
            this.pyquery.set_phrase(this.options.phrase);
            this.pyquery.set_timeframe(this.options.from, this.options.to)
            this.pyquery.set_pub(this.options.publisher);
            this.pyquery.set_author(this.options.author);
            this.pyquery.set_words_some(this.options.usewords);
            this.pyquery.set_words_none(this.options.excludewords);
            this.pyquery.set_start(int32(this.options.start));
            this.url = char(this.pyquery.get_url);
        end
    end
%     methods(Access=private)
%         function listener_options_Callback(this,src,event)
%             this.queryurl;
%         end
%     end
end