function varargout = uh_getsignalperiod(signal,varargin)
% Get gait period of walking data, assume that f>0.2
Fs = get_varargin(varargin,'Fs',100);
method = get_varargin(varargin,'method','fft');
timelag = get_varargin(varargin,'lag',10);
minf = get_varargin(varargin,'minf',0.2); % minimum frequency.
if strcmpi(method,'fft')
    [pxx,f] = periodogram(signal,rectwin(length(signal)),length(signal),Fs);
    pxx=smooth(10*log10(pxx),'loess'); %convert to dB and smooth data.
    [peak peakpos]=max(pxx(find(minf<f))); %normal walk
    fpeak=f(find(f>=minf,1,'first')+peakpos);
    if ~isempty(fpeak)
        period=1/fpeak;
    else
        period=0;
    end
elseif strcmpi(method,'autocorrelation')
    [autocor,lags] = xcorr(signal,timelag*Fs,'coeff'); %maximum lag is for autocorrelation
    [peakraw,~]=findpeaks(autocor);
    minpeakheight=mean(peakraw);
    [~,locs]=findpeaks(autocor,'minpeakheight',minpeakheight);
    period=mean(diff(locs))/Fs;
end
%Outputs from this function,...
%Change output1, output2, etc to your output variables
switch nargout
    case 0
    case 1
        varargout{1}=period;
    case 2
        varargout{1}=output1;
        varargout{2}=output2;
    otherwise
end
