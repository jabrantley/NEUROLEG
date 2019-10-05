function uh_fprintf(msg,varargin)
% This is an extended version of fprint, which include information of 
% time and current function running.
[stacktrace, ~]=dbstack;
if length(stacktrace) > 1
    thisFuncName=stacktrace(end-1).name;
else
    thisFuncName=stacktrace(1).name;
end
color = get_varargin(varargin,'color','k');
% get current time info
classtime = class_datetime;
extmsg = sprintf('%s-%s.m: "%s"\n',classtime.time,thisFuncName,msg);
if color == 'r'
    fprintf(2,extmsg);
else
    fprintf(extmsg);
end