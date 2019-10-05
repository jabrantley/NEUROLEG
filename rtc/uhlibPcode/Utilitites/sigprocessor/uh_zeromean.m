function y = uh_zeromean(x)
% Rearrange to ch x time
xrow = uh_torow(x);
meanval=mean(xrow,2); % mean by channel across time;
y = xrow - repmat(meanval,1,size(xrow,2));