% Rescale data between [0 1]
% Written by: Justin Brantley
function result = rescale_data(data,opt)
    if nargin < 2
        opt = 'all';
    end
    
    switch opt
        case 'all'
            minval = min(data(:));
        case 'rows'
            minval = min(data,[],1);
        case 'cols'
            minval = min(data,[],2);
    end
            
    numer = bsxfun(@minus,data,minval);
    denom = max(data(:)) - min(data(:));
    result = bsxfun(@rdivide,numer,denom);
end