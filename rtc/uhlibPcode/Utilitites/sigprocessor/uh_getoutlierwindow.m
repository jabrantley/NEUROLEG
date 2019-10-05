function alloutlierpos = uh_getoutlierwindow(x,varargin)
% get number of window
Fs = get_varargin(varargin,'Fs',100);
winsize = get_varargin(varargin,'winsize',Fs);
winindex1=[];
winindex2=[];stopidx=0;
winno=1;
%find sliding size
while stopidx <= length(x) %Sliding window.
    temp1=(winno-1)*winsize+1;
    temp2=temp1+winsize;
    stopidx=temp1+winsize;
    if temp2>length(x)
        temp2=length(x);
    else                
    end
    winindex1=[winindex1 temp1];
    winindex2=[winindex2 temp2];
    winno=winno+1;
end
% find mean value of peaks.
alloutlierpos=[];
for i=1:length(winindex1)
    winx=x(winindex1(i):winindex2(i));    
    outlierwin=uh_getoutlier(winx)+winindex1(i)-1;
    if ~isempty(outlierwin)
        if size(outlierwin,1)>size(outlierwin,2)
        else
            outlierwin=outlierwin';
        end
        alloutlierpos=[alloutlierpos; outlierwin];
    end
end
