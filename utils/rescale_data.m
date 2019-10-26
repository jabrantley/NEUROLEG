% Rescale data between desired range
% Written by: Justin Brantley
%
%  data: matrix of (n x m)
%   opt: 'rows' - rescale rows; 'cols' - rescale columns; 'all' - rescale all single max,min
% range: (n x 2) range of values to rescale data. if matrix, use each row
%                to rescale each vector
function result = rescale_data(data,opt,range)

% Set default scaling direction
if nargin < 2 || isempty(opt)
    if size(data,2) == 1
        opt = 'cols';
    else
        opt = 'rows';
    end
end

% Set default range
if nargin < 3 || isempty(range)
    range = [0 1];
end

% Compute min and max
switch opt
    % Rescale to overall max and min
    case 'all'
        minval = min(data(:));
        maxval = max(data(:));
    % Rescale along each row
    case 'rows'
        minval = min(data,[],2);
        maxval = max(data,[],2);
    % Rescale along each column
    case 'cols'
        data = data';
        minval = min(data,[],2);
        maxval = max(data,[],2);
end

% Compute scaling value
scale  = range(:,2) - range(:,1);

% Compute offset
offset = range(:,1);

% Rescale data
numer  = bsxfun(@times,bsxfun(@minus,data,minval),scale);
denom  = maxval-minval;
result = bsxfun(@rdivide,numer,denom) + offset;

% Correct dimensions if needed
if strcmpi('opt','cols')
    result = result';
end

end % EOF