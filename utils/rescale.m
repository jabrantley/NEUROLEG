% Rescale data between [0 1]
% Written by: Justin Brantley
function result = rescale(data)
    numer = bsxfun(@minus,data,min(data(:)));
    denom = max(data(:)) - min(data(:));
    result = bsxfun(@rdivide,numer,denom);
end