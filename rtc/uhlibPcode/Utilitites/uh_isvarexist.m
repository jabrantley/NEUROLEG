function y = uh_isvarexist(varname);
cmdstr = sprintf('evalin(''base'',''exist(''''%s'''',''''var'''')'');',varname);
y = eval(cmdstr);