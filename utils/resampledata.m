% resampledata - Resample timeseries A to timeseries B

% Example:
%     EMGdata = resampledata(EMGdata,EEGdata,1000,1000);

% See also: RESAMPLE, TIMESERIES
function out = resampledata(in1,desiredpnts,srate)

% Get size data - should be channels (rows) x time (cols)
[rowsIN,colsIN] = size(in1);
currentpnts = colsIN;

% Create linearly spaced vector based on size and sampling rate
t1 = linspace(0,(currentpnts-1)/srate,currentpnts);
if ~isscalar(desiredpnts)
    % Desired points is vector of times
    t2 = desiredpnts;
    % Initialize out
    out = zeros(rowsIN,length(desiredpnts));
else
    % Create vector of times
    t2 = linspace(0,(currentpnts-1)/srate,desiredpnts);
    % Initialize out
    out = zeros(rowsIN,desiredpnts);
end

for ii = 1:rowsIN
    
    s1 = timeseries(in1(ii,:),t1);
    s2 = resample(s1,t2,'linear');
    
    out(ii,:) = transpose(squeeze(s2.data));
    
end
end