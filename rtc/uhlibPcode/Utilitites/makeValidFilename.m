function output = makeValidFilename(filename)
expression = '[~!@#$%^&*()_+`={}|;"''<,>.?/:]';
output = regexprep(filename,expression,' ');
expression = {'\','x80','x93','xe2','\[(.*)\]'};
for i = 1 : length(expression)
    exp = expression{i};
    output = regexprep(output,exp,'');
end
