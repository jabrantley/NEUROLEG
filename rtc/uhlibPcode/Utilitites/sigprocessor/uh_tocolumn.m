function yout = uh_tocolumn(x)
if size(x,1)<size(x,2)
    yout=x';
else
    yout=x;
end