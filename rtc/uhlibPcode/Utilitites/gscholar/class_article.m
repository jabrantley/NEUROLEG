classdef class_article < handle & hgsetget
    properties
        url;
        title;
        citations;
        author;
        year;
        enwlink;
        citelink;
    end
    methods
        %Contructor
        function this = class_article(varargin)
            this.url = get_varargin(varargin,'url','http://ieeexplore.ieee.org/document/7591006/');
            this.title = get_varargin(varargin,'title','untitled');
            this.citations = get_varargin(varargin,'citations','0');
            this.author = get_varargin(varargin,'author','nan');
            this.year = get_varargin(varargin,'year','2000');
            this.enwlink = get_varargin(varargin,'enwlink','');                        
            this.citelink = get_varargin(varargin,'citelink','');                        
        end
    end
end