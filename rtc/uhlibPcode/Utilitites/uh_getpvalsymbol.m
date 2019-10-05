function statisticmark = uh_getpvalsymbol(pval,varargin)
% This function will get pval after running multicompare statistic
ns = get_varargin(varargin,'ns',sprintf('ns'));
if (0.01 < pval) && (pval <= 0.05)
    statisticmark=sprintf('$$\\ast$$');
elseif 0.001<pval && pval<=0.01
    statisticmark=sprintf('$$\\ast\\!\\ast$$');
elseif pval<=0.001
    statisticmark=sprintf('$$\\ast\\!\\ast\\!\\ast$$');
else
    statisticmark=ns;
end