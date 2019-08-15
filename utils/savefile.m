% savefile(data,varname,dirname,flname)
function savefile(data,varname,dirname,flname)

if nargin < 4
   filename = dirname;
else
   filename = fullfile(dirname,flname);
end

datainfo = whos('data');
% 
% if strcmpi(datainfo.class,'cell')
% 
%     
% else
    eval([varname ' = data;']);
% end

if datainfo.bytes >= 2E9
    fprintf('File size is larger than 2 GB.  Using v7.3 switch. This may take a while....')
    save( filename , varname ,'-v7.3');
    fprintf('done.\n\n')
else
    fprintf('Saving data...')
    save( filename , varname);
    fprintf('done.\n')
end

fprintf('File successfully saved.\n\n');
end