function varargout = templatecode_mfile(varargin)
[stacktrace, ~] = dbstack;
thisFuncName = stacktrace.name;
fprintf('RUNNING: %s.\n',thisFuncName); 
%=BEGIN====
% Input
input = get_varargin(varargin,'input','default');
% Define Variables
% Output
output = [];
if nargout == 1
    varargout{1} = output;
else
    assignin('base','output',output);
end
%=END====
fprintf('DONE: %s \n', thisFuncName);