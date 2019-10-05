function y = uh_timewarp(x,varargin)
% Convert to ch x time;
warpsize = get_varargin(varargin,'warpsize',100); %warpsize and newsize are identical
newsize = get_varargin(varargin,'newsize',100);
torow = get_varargin(varargin,'torow',1); % conver to channel x time format
if torow == 1
    x = uh_torow(x);
end

if newsize ~= 100
    warpsize = newsize;
end
interpmethod = get_varargin(varargin,'method','pchip'); % cubic spline

[ch, Npts] = size(x);
orgx = linspace(0,100,Npts);
intx = linspace(0,100,warpsize);
y = zeros(ch,warpsize);
for i = 1:ch
    y(i,:) = interp1(orgx,x(i,:),intx,interpmethod);
end