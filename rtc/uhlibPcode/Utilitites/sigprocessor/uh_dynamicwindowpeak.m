function varargout = uh_dynamicwindowpeak(x,varargin)
% This function run sliding window to find peak for input data x;
% v1.0: non overlapping window;
winref = get_varargin(varargin,'winref',1);
Fs = get_varargin(varargin,'Fs',100);
minpeakopt = get_varargin(varargin,'minpeakopt','meanpeak');
lag = get_varargin(varargin,'lag',3);
selpeak = get_varargin(varargin,'selpeak',[]);
% find mean value of peaks.
allpeakpos=[];
for i=1:length(winref)-1
    winx=x(winref(i):winref(i+1));
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
        [xpeak, xpeakposwin]=findpeaks(winx,'MinPeakHeight',minpeakheight);
        if ~isempty(xpeakposwin)
            if ~isempty(selpeak)
                xpeakpos=xpeakposwin(selpeak);
            else
                xpeakpos=xpeakposwin;
            end
        else
            xpeakpos=[];
        end
        allpeakpos=[allpeakpos; uh_tocolumn(xpeakpos+winref(i)-1)];        
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
