function yout = uh_torow(x)
if size(x,2)<size(x,1)
    yout=x';
else
    yout=x;
end