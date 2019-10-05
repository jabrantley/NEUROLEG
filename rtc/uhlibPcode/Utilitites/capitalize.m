function xout = capitalize(xin)
xout = regexprep(xin,'(\<[a-z])','${upper($1)}');
end