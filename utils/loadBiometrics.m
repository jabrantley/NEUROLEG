% Load biometrics datalog data
% Written by: Justin Brantley
function out = loadBiometrics(in)
% Specify number of data channels to assist in finding triggers
disp(['Loading: ' in]);
try
    temp = importdata(in);
catch e
    disp('No file found.')
    out = temp;
    return
end
[rows, cols] = size(temp.data);

% Get data
out.rawdata = temp.data(:,1:end-1);
% Get trigger channel
temptrigger = temp.data(:,end);
% Rescale between [0,1]
out.trigger = rescale_data(temptrigger);
out.trigger(find(isnan(out.trigger))) = 0;

try
    out.header  = temp.textdata;
catch
    out.header = [];
end

end