function varargout = uh_windowpeak(x,varargin)
% This function run sliding window to find peak for input data x;
% v1.0: non overlapping window;
winsize = get_varargin(varargin,'winsize',1);
Fs = get_varargin(varargin,'Fs',100);
minpeakopt = get_varargin(varargin,'minpeakopt','meanpeak'); % or 'median'. Find minpeakheight from mean or median or peaks
% get number of window
winindex1=[];
winindex2=[];stopidx=0;
winno=1;
%find sliding size
while stopidx<=length(x) %Sliding window.
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
allpeakpos=[];
for i=1:length(winindex1)
    winx=x(winindex1(i):winindex2(i));
    if length(winx)>=10      %enough data for findpeaks
        if strcmpi(minpeakopt,'meanpeak')
            [xpeakraw,~]=findpeaks(winx);
            minpeakheight=mean(xpeakraw);
        elseif strcmpi(minpeakopt,'medianpeak');
            [xpeakraw,~]=findpeaks(winx);
            minpeakheight=median(xpeakraw);
        elseif strcmpi(minpeakopt,'median')
            minpeakheight=median(winx);
        elseif strcmpi(minpeakopt,'zero')
            minpeakheight=0;
        else
            minpeakheight=min(winx);
        end        
        T = uh_getsignalperiod(winx,'method','autocorrelation','lag',10);
        if ~isnan(T)
            [xpeak, xpeakpos] = findpeaks(winx,'MinPeakDistance',round(0.8*T*Fs),'MinPeakHeight',minpeakheight);
            allpeakpos=[allpeakpos; uh_tocolumn(xpeakpos+winindex1(i)-1)];
        end
    else
    end
end
%Outputs from this function,...
%Change output1, output2, etc to your output variables
switch nargout
    case 0
    case 1
        varargout{1}=allpeakpos;
    case 2
        varargout{1}=output1;
        varargout{2}=output2;
    otherwise
end
