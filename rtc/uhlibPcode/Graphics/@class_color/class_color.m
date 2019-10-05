classdef class_color < handle & hgsetget    
    properties
        gradientcolor;
        color;
        defaultcolor;
        cmap; %colormap using lbmap;
        r;
        g;
        b;
        c;
        y;
        m;
        w;
        k;
        grey = 211/256*[1 1 1];
        seagreen = [46, 139, 87]./256;
        goldenrod = [218,165,32]./256;
        orange = [255,165,0]./256;
        pink = [213,73,116]./256;
        potato = [229,97,9]./256;
        % To tint the color;
        alpha = 0.5;
        % Blind color;
        blindcolor; % cell format 
        % http://www.somersault1824.com/tips-for-designing-scientific-figures-for-color-blind-readers/
        sroncolor;  % Ref https://personal.sron.nl/~pault/colourschemes.pdf
        % Light color;        
        gradientres = 32;
        cmapres = 128;
    end
    methods (Access = public) %Constructor
        %Constructor
        function this = class_color(varargin)
            this.color = get_varargin(varargin,'color',[0 0 1]);
            this.cmapres = get_varargin(varargin,'cmapres',256);
            this.gradientres = get_varargin(varargin,'gradientres',256);
            this.alpha = get_varargin(varargin,'alpha',0.5);
            %--------------------
            this.r=this.str2color('r');
            this.g=this.str2color('g');
            this.b=this.str2color('b');
            this.c=this.str2color('c');
            this.y=this.str2color('y');
            this.m=this.str2color('m');
            this.w=this.str2color('w');
            this.k=this.str2color('k');            
            this.defaultcolor{1}=this.r;
            this.defaultcolor{2}=this.k;
            this.defaultcolor{3}=this.b;
            this.defaultcolor{4}=this.goldenrod;
            this.defaultcolor{5}=this.seagreen;
            this.defaultcolor{6}=this.m;
            this.defaultcolor{7}=this.orange;
            this.defaultcolor{8}=this.g;
            this.defaultcolor{9}=this.potato;
            this.defaultcolor{10}=this.c;
            % Get blind color
            this.getblindcolor;            
            % Sron color pallete
            this.getsroncolor;
            % Gradient color;
            this.gradientcolor = this.getgradient(this.grey,this.k,this.gradientres);
            this.cmap =  flipud(this.lbmap(this.cmapres,'brownblue'));
        end
        
    end
    methods
        function getblindcolor(this)
            blindcolormat = [0 0 0; 0 73 73; 0 146 146; 255 109 182; 255 182 119;,...
                73 0 146; 0 109 219; 182 109 255; 109 182 255; 182 219 255;,...
                146 0 0; 146 73 0; 219 209 0; 36 255 36; 255 255 109]./256;
            for i = 1 : size(blindcolormat,1)
                this.blindcolor{i} = blindcolormat(i,:);
            end
        end
        function showblindcolor(this)
            figure;
            palette = class_rectangle_mat('rows',5,'cols',3,'gap',[0.1 0.1]);
            id = reshape(1 : palette.rows*palette.cols,palette.rows,[]);
            for i = 1 : palette.rows
                for j = 1 : palette.cols
                    thiscolor = this.blindcolor{id(i,j)};
                    set(palette.rect{i,j},'facecolor',thiscolor,...
                        'string',[mat2str(round(thiscolor*256)), ', ' num2str(id(i,j))],'textcolor','r');
                    palette.rect{i,j}.drawshape;
                end
            end    
            axis off;
        end        
         function getsroncolor(this)
            sroncolormat = [0 0 0; 51 34 136; 136 204 238; 68 170 153; 17 119 51;,...
                153 153 51; 221 204 119; 204 102 119; 136 34 85; 170 68 153;,...
                255 109 182; 255 182 119; 0 109 219; 36 255 36]./256;
            for i = 1 : size(sroncolormat,1)
                temp = sroncolormat(i,:);
                this.sroncolor.normal{i} = temp;                
                this.sroncolor.light{i} = temp + (1-temp)*this.alpha;
            end
            this.sroncolor.size = size(sroncolormat,1);
         end
         function showcolorpallet(this,varargin)
             colorpallet = get_varargin(varargin,'pallete',this.blindcolor);    
             printopt = get_varargin(varargin,'print',1);
             numcolor = length(colorpallet);
             rows = get_varargin(varargin,'rows',3);
             cols = get_varargin(varargin,'cols',ceil(numcolor/rows));
             gaps = get_varargin(varargin,'gaps',[0.1 0.1]);
             figure;
             palette = class_rectangle_mat('rows',rows,'cols',cols,'gap',gaps);
             id = reshape(1 : palette.rows*palette.cols,palette.rows,[]);
             for i = 1 : palette.rows
                 for j = 1 : palette.cols
                     try
                     thiscolor = colorpallet{id(i,j)};
                     set(palette.rect{i,j},'facecolor',thiscolor);                     
                     set(palette.rect{i,j}.textobj,'string',[mat2str(round(thiscolor*256)), ', ' num2str(id(i,j))],'color','k');
                     palette.rect{i,j}.drawshape;
                     catch 
                     end
                 end
             end
             axis off;
             %===============================PRINT===================================
             if printopt==1
                 thisfilename = mfilename('fullpath');
                 [thisdir,~,~] = fileparts(thisfilename);
                 datetime = class_datetime;
                 myprinter = class_export_fig('filename',fullfile(thisdir,sprintf('%s-ColorPallete',datetime.ymd)),...
                     'format','jpg','resolution',800,'paper',[0 0 6 4],'handles',gcf);
                 myprinter.export;
             end
         end
    end
    methods (Static)
        grad=getgradient(c1,c2,depth);
        color=str2color(str);
        cmap=lbmap(n,scheme);
    end
end
        
