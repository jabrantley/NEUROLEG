function varargout = uh_getoutlier(matinput,varargin)
% Detecting outlier based on MAD methods;
% Future: Consider STD for normal distribution.
% And Turkey method with uses box plot and IQR-quartile range;
% Matinput must be in column format;
% Output outlierid matrix with has the same size as matinput in column0 and 1
dev = get_varargin(varargin,'dev',3);  %deviation from median
meanopt = get_varargin(varargin,'meanopt','median');
removeopt = get_varargin(varargin,'remove',0);
replaceopt = get_varargin(varargin,'replace',0);
interpmethod = get_varargin(varargin,'method','pchip');
matinput = uh_tocolumn(matinput);
[~,cols] = size(matinput);
outlierid = zeros(size(matinput));
matoutput = matinput;
for i = 1 : cols
    signal = matinput(:,i);
    if strcmpi(meanopt,'median')
        med = median(signal);
        medmad = mad(signal,1);
    else
        med = mean(signal);
        medmad = std(signal);
    end
    thisid = find(signal < med-dev*medmad | signal > med+dev*medmad);
    if ~isempty(thisid)
        outlierid(thisid,i) = 1;
    end
    if replaceopt == 1
        if ~isempty(thisid)
            matoutput(:,i) = interp1(setdiff(1:length(signal),thisid),...
                signal(setdiff(1:length(signal),thisid)),1:length(signal),interpmethod);
        end
    end
end
if replaceopt == 1
    return;
end
if removeopt == 1
    matoutput = matinput;
    matoutput(find(outlierid)) = nan;    
end
% Output 
if nargout == 1
    varargout{1} = outlierid;
elseif nargout == 2
    varargout{1} = outlierid;
    varargout{2} = matoutput;
else
end