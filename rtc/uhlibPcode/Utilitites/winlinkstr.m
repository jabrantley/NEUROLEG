function yout = winlinkstr(xin)
yout = sprintf('<a href="matlab:winopen(''%s'')">%s</a>\n',xin,xin);
end