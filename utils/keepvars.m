% Written by Justin Brantley
%
% This function is used to clear all variables except those specified in
% the argument "vars".  It is an extension of the "-except" option of the
% function "clearvars".  
% 
% Example:  vars = who;
%        ...Some code here...
%           keepvars(vars);
%       
function keepvars(vars)

if iscell(vars)
    
    varnames = [];
    for i = 1:length(vars)
        varnames = [varnames char(vars{i}) ' ']; 
    end
    evalin('caller',['clearvars -except ' varnames]);
    
else
    error(['The input must be of type cell. Use (vars = who;)'...
           ' to store all variables in the workspace you wish '...
           ' to keep at a certain point in the script.']);
end

end