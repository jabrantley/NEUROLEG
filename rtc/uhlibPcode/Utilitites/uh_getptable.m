function output = uh_getptable(multcomparetable,coli,colj,varargin)
% This function will get pval after running multicompare statistic
pvalcol = get_varargin(varargin,'pcol',0); % pvalue column from p multcompare table;
star = get_varargin(varargin,'string',0);
thisrow = []; % Output of selected row from p table.
% Find the row from comparison
if ~istable(multcomparetable);
    for i=1:size(multcomparetable)
        if multcomparetable(i,1) == coli && multcomparetable(i,2) == colj
            thisrow=i;
            break;
        end
    end    
else
    varnames = multcomparetable.Properties.VariableNames;
    firstcolvar = multcomparetable.(varnames{1});
    secondcolvar = multcomparetable.(varnames{2});
    for i = 1:size(multcomparetable,1)
        if strcmpi(firstcolvar{i},coli) && strcmpi(secondcolvar{i},colj)
            thisrow=i;
            break;
        end
    end
end
% Look for p-value and convert to array if p-value is in table format.
if ~isempty(thisrow)
    if pvalcol == 0
        pval=multcomparetable(thisrow,end); % p-value in the last column               
    else
        pval=multcomparetable(thisrow,pvalcol); % specify p-value column
    end
    if istable(pval); % Convert table value to scalar
        pval = table2array(pval);
    end    
else    
    pval = 100;
end
if star == 0
    output = pval;
else
    output = uh_getpvalsymbol(pval,'ns','ns');
end
