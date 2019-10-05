function tslide = uh_gettimeslide(timeline,winsize,stepsize,numwin)
% This function get new timeline when using sliding window
% winsize: number of samples in one window;
% stepsize: step size of moving window;
% numwin: number of moving window;
lastwinid = (numwin - 1)*stepsize + winsize; % in samples
tslide = linspace(timeline(winsize),timeline(lastwinid),numwin);
