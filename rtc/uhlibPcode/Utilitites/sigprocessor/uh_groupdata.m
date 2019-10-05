function outputgroupdata = uh_groupdata(signal,ngroup,varargin)
% put a vector of data into Ngroup.
% Input: vector of data;
% Output: mean or median of each group
midtype = get_varargin(varargin,'type','mean');
%==
space=fix(linspace(1,length(signal),ngroup+1));
mgroup=zeros(ngroup,1);
stdgroup=zeros(ngroup,1);
if strcmpi(midtype,'mean')
    for k=1:ngroup
        mgroup(k)=mean(signal(space(k):space(k+1)));
        stdgroup(k)=std(signal(space(k):space(k+1)));
    end
elseif strcmpi(midtype,'median')
    for k=1:ngroup
        mgroup(k)=median(signal(space(k):space(k+1)));
        stdgroup(k)=quantile(signal(space(k):space(k+1)),0.25);
    end
end
outputgroupdata.space = space(2:end);
outputgroupdata.mgroup = mgroup;
outputgroupdata.stdgroup = stdgroup;
