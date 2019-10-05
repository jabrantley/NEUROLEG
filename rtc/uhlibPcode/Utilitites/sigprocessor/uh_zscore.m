function varargout = uh_zscore(x,varargin)
% convert to ch x time
compdir = get_varargin(varargin,'dir',2);
x =  uh_torow(x);
[rows, cols] = size(x);
if compdir == 2
    m = mean(x,2);
    onestd = std(x,0,2);
    y = (x-repmat(m,1,cols))./repmat(onestd,1,cols);
else
    m = mean(x,1);
    onestd = std(x,0,1);
    y = (x-repmat(m,rows,1))./repmat(onestd,rows,1);
end
if nargout == 1
    varargout{1} = y;
elseif nargout == 2
    varargout{1} = y;
    varargout{2} = m;
elseif nargout == 3
    varargout{1} = y;
    varargout{2} = m;
    varargout{3} = onestd;
end