function uijlist_setfiles(jlistboxhdl,rootdirpath,varargin)
rootdir=dir(rootdirpath);
fontcolor='black';
icon=getmatlabicons;
type = get_varargin(varargin,'type',{});
fontsize = get_varargin(varargin,'fontsize',4);
searchtxt = get_varargin(varargin,'search',{});
excludetxt = get_varargin(varargin,'exclude',{});
sortopt = get_varargin(varargin,'sort','ascend');
%---------
model=get(jlistboxhdl,'Model');
model.removeAllElements;
set(jlistboxhdl,'Model',model);
listboxtext={};
j=1;
if strcmpi(sortopt, 'descend')
    [~,ind]=sort({rootdir.name});
    rootdir = rootdir(flip(ind));
end
if ~isempty(rootdir)
    for i=1:length(rootdir)
        thisfile=rootdir(i).name;
        if strcmpi(thisfile,'.') || strcmpi(thisfile,'..')
        else
            if rootdir(i).isdir==1
                thisfile=[thisfile '.folder'];
            end;
            ext=thisfile(strfind(thisfile,'.'):end);
            typepass=1;searchpass=1; excludepass = 1; 
            if ~isempty(type)
                typepass=0;
                for k=1:length(type)
                    if strcmpi(type{k},'.all')
                        typepass=1;
                        break;
                    end
                    if strcmpi(ext,type{k})
                        typepass=1;
                        break;
                    end
                end
            end
            if ~isempty(searchtxt)
                searchpass=0;
                for k=1:length(searchtxt)
                    if strfind(searchtxt{k},'&')
                        if isempty(strfind(lower(thisfile),lower(searchtxt{k}(2:end))))
                            searchpass=0;break;
                        end
                    end                    
                    if strfind(lower(thisfile),lower(searchtxt{k}))
                        searchpass=1;
                    end
                end         
            end
            if ~isempty(excludetxt)
                excludepass = 1;
                for k=1:length(excludetxt)
                    if strfind(excludetxt{k},'&')
                        if isempty(strfind(lower(thisfile),lower(excludetxt{k}(2:end))))
                            excludepass = 0;break;
                        end
                    end
                    if strfind(lower(thisfile),lower(excludetxt{k}))
                        excludepass = 0;
                    end
                end           
            end                   
            usethisfile = typepass && searchpass && excludepass;
            if usethisfile==1
                ext=thisfile(strfind(thisfile,'.'):end);
                if strcmpi(ext,'.folder'); useicon=icon.folder; thisfile=strrep(thisfile,'.folder','');
                elseif strcmpi(ext,'.m'); useicon=icon.file.m;
                elseif strcmpi(ext,'.mat'); useicon=icon.file.mat;
                elseif strcmpi(ext,'.txt'); useicon=icon.file.text;
                elseif strcmpi(ext,'.fig'); useicon=icon.file.fig;
                elseif strcmpi(ext,'.png'); useicon=icon.figure;
                else
                    useicon=icon.file.page;
                end
                iconTxt =['<html><img src="file:/',useicon,'" height=12 width=12/>'];
                msgTxt = ['&nbsp;&nbsp;<font color=',fontcolor,' size=',num2str(fontsize),'>',thisfile,'</font>'];
                listboxtext{j} = [iconTxt,msgTxt];
                j=j+1;
            end
        end
    end
end
newmodel=javaObjectEDT('javax.swing.DefaultListModel');
if ~isempty(listboxtext)
    for i=1:length(listboxtext)
        newmodel.addElement(listboxtext{i});
    end
    set(jlistboxhdl,'Model',newmodel);
else
end
