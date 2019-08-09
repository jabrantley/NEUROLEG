function out = loadBiometrics(in,n)
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

try
    if cols == n+1
        out.rawdata = temp.data(:,1:n);
        temptrigger = temp.data(:,n+1:end);
        temptrigger = temptrigger - min(temptrigger);
        temptrigger = temptrigger/max(temptrigger);
        out.trigger = temptrigger;
    else
        out.rawdata = temp.data;
        out.trigger = [];
    end
catch
    out.rawdata = [];
end

try
    out.header  = temp.textdata;
catch
    out.header = [];
end

end