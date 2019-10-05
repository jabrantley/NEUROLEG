classdef class_FileIO < hgsetget;
%======================       
    properties (SetAccess = public, GetAccess = public)        
        ext; %file extension;
        exist=0;        
    end
    properties (SetAccess = public, GetAccess = public)                
        fullfilename;
        filedir;
    end
    properties (SetObservable)
        filename;
    end
    methods (Access = public) %Constructor
        %Constructor
        function this = class_FileIO(varargin)
             for i = 1 : 2 : nargin
                if strcmpi(varargin{i},'fullfilename') % if fullfilename as input
                    this.fullfilename = get_varargin(varargin,'fullfilename',[cd 'untitled.m']) ;
                    [this.filedir,this.filename,this.ext] = fileparts(this.fullfilename);
                    return;
                else
                    this.filedir = get_varargin(varargin,'filedir',cd);
                    this.filename = get_varargin(varargin,'filename','untitled');
                    extin = get_varargin(varargin,'ext','');
                    [~,~,ext] = fileparts(this.filename);
                    if isempty(ext)
                        if isempty(extin)
                            this.ext = '';
                            this.fullfilename = fullfile(this.filedir,this.filename);                            
                        else
                            this.ext = extin;
                            this.fullfilename = fullfile(this.filedir,[this.filename,this.ext]);
                        end
                    else                        
                        this.fullfilename = fullfile(this.filedir,this.filename);
                        this.ext = ext;
                    end
                end
             end                        
            this.isexist;
            % Set observation;
%             addlistener(this,'filename','PostSet',@this.listener_filename_Callback);
        end
        function savevars(this,varargin)
            fprintf('Saving...Filename: %s\n',this.filename);
            cmdstr=sprintf('save(''%s'',',this.fullfilename);  
            for i =1:length(varargin)                
                cmd=sprintf('%s=varargin{i};',inputname(i+1));
                eval(cmd);
                cmdstr=[cmdstr sprintf('''%s'',',inputname(i+1))];
            end
            cmdstr=[cmdstr sprintf('''-v7.3'');')];
            eval(cmdstr);
            fprintf('DONE...Saved: %s\n',this.filename);
        end   
        function savews(this)
            fprintf('Saving...Filename: %s\n',this.filename);
            cmdstr=sprintf('save(''%s'',',this.fullfilename);  
            wsvars = evalin('base','who');            
            for i =1:length(wsvars)
                cmd=sprintf('%s=evalin(''base'',''%s'');',wsvars{i},wsvars{i});
                eval(cmd);
                cmdstr=[cmdstr sprintf('''%s'',',wsvars{i})];
            end
            cmdstr=[cmdstr sprintf('''-v7.3'')')];
            eval(cmdstr);
            fprintf('DONE...Saved: %s\n',this.filename);
        end
        function addvars(this,varargin)
            cmdstr=sprintf('save(''%s'',',this.fullfilename);
            try
                datastruct=load(this.fullfilename);
                fname=fieldnames(datastruct);
                for i=1:length(fname)
                    cmd=sprintf('%s=datastruct.(fname{i})',fname{i});
                    eval(cmd);
                    cmdstr=[cmdstr sprintf('''%s'',',fname{i})];
                end
                for i=1:length(varargin)
                    cmd=sprintf('%s=varargin{i}',inputname(i+1));
                    eval(cmd);
                    cmdstr=[cmdstr sprintf('''%s'',',inputname(i+1))];
                end
                cmdstr=[cmdstr sprintf('''-v7.3'');')];
                eval(cmdstr);
            catch
                for i =1:length(varargin)
                    cmd=sprintf('%s=varargin{i}',inputname(i+1));
                    eval(cmd);
                    cmdstr=[cmdstr sprintf('''%s'',',inputname(i+1))];
                end
                cmdstr=[cmdstr sprintf('''-v7.3'');')];
                eval(cmdstr);
            end
        end
        function addwsvars(this,varargin)
            cmdstr=sprintf('save(''%s'',',this.fullfilename);
            try
                datastruct=load(this.fullfilename);
                fname=fieldnames(datastruct);
                for i=1:length(fname)
                    cmd=sprintf('%s=datastruct.(fname{i})',fname{i});
                    eval(cmd);
                    cmdstr=[cmdstr sprintf('''%s'',',fname{i})];
                end
                for i=1:length(varargin)                    
                    cmd=sprintf('%s=evalin(''base'',''%s'');',varargin{i},varargin{i});
                    eval(cmd);
                    cmdstr=[cmdstr sprintf('''%s'',',varargin{i})];
                end
                cmdstr=[cmdstr sprintf('''-v7.3'')')];
                eval(cmdstr);
            catch
                for i =1:length(varargin)
                    cmd=sprintf('%s=evalin(''base'',''%s'');',varargin{i},varargin{i});
                    eval(cmd);
                    cmdstr=[cmdstr sprintf('''%s'',',varargin{i})];
                end
                cmdstr=[cmdstr sprintf('''-v7.3'')')];
                eval(cmdstr);
            end
        end
        function loadtows(this)
            structdata=load(this.fullfilename);
            fname=fieldnames(structdata);            
            for fn=1:length(fname)
                assignin('base',sprintf('%s',fname{fn}),structdata.(fname{fn}));
            end
        end
        function isexist(this)
            thisdir=dir(this.filedir);            
            for i=1:length(thisdir)
                if ~isempty(strfind(lower(thisdir(i).name),lower(this.filename)))
                    this.exist=1;
                    return;
                end
            end
        end
        function mat2txt(this,inputmat)
            if strcmpi(this.ext,'.txt')
                fprintf('print to %s txt file.\n',this.filename);
                fid = fopen(this.fullfilename,'w');
                for i = 1 : size(inputmat,1)
                    for j = 1: size(inputmat,2)
                        fprintf(fid,'%.2f \t',inputmat(i,j));
                    end
                    fprintf(fid,'\n');
                end
                fclose(fid);
            end
        end
        function output = uh_textscan(this,varargin)
            numlines = get_varargin(varargin,'numlines',0);
            this.fullfilename
            fid = fopen(this.fullfilename,'r');
            filestr = textscan(fid,'%s','delimiter','\n');
            filestr = filestr{:};
            if numlines == 0; numlines = size(filestr,1); end
            output = cell(numlines,1);
            for line = 1 : numlines
                output{line,1} = filestr{line};
            end
            fclose(fid);
        end        
    end
    methods (Access = private) %Destructor
        function listener_filename_Callback(this,src,event)            
            this.fullfilename = [this.filedir,'\',this.filename,this.ext];       
            this.isexist;
        end        
        function delete(this)
        end
    end
    methods (Static)
    end
end