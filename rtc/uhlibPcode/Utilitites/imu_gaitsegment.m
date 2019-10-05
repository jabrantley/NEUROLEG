%% imu_gaitsegment.m
%% *Description:*
%% *Usages:*
%
% *Inputs:*
% 
% *Outputs:*
% 
% *Options:*
% 
% *Notes:*
%
%% *Authors:*
% * *MATLAB Ver :* 9.0.0.341360 (R2016a)
% * *Date Created :* 31-Jul-2017 14:33:00
% * *Author:* Phat Luu. ptluu2@central.uh.edu
%
% _Laboratory for Noninvasive Brain Machine Interface Systems._
% 
% _University of Houston_
% 

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%%
function varargout = imu_gaitsegment(varargin) 
filename = 'D:\OneDrive\IMU-20170728-163611.h5';
opal = readopalh5(filename);
% Convert quaternion to euler angle
quat = opal.Ori; % Quaternion obtained from opal orientations.
euler = transpose(rad2deg(quat2eul(quat')));
% Foot flexion extention
yAng = euler(2,:);
% High pass filter data to remove drift and bias
Fs = 128; fn = Fs/2; cutoff = 0.1;
[A,B,C,D] = butter(4,cutoff/fn,'high'); %Define butter filter
[b,a] = ss2tf(A,B,C,D);
filtAng = filtfilt(b,a,yAng);
oribuff = cirBuffer('size',4);
HCcatching = 0;
TOcatching = 0;
lastEvent = 4;
HeelThres = 10;
ToeThres = -10;
for i = 1 : length(filtAng)
    sample = filtAng(i);
    oribuff.append(sample);
    gcEvent = 0;
    % Detect Heel Strike
    if HCcatching == 0
        if oribuff.meanVal > HeelThres
            if oribuff.isAscend
                HCcatching = 1;
            else
            end
        end
    else
        if oribuff.isDescend
            if lastEvent == 4
                fprintf('Detected: HC.\n')
                gcEvent = 1;
                lastEvent = 1;
            end
            HCcatching = 0;
        end
    end    
    % Detect Toe Off
    if TOcatching == 0
        if oribuff.meanVal < ToeThres
            if oribuff.isDescend
                TOcatching = 1;
            else
            end
        end
    else
        if oribuff.isAscend
            if lastEvent == 1
                fprintf('Detected: TO.\n')
                gcEvent = 4;
                lastEvent = 4;
            end
            TOcatching = 0;
        end
    end
    gcOut(i) = gcEvent;
end
assignin('base','gcEvent',gcOut);
assignin('base','yAng',yAng)


function varargout = readopalh5(filename)
opal.Acc = h5read(filename,'/SI-000738/Calibrated/Accelerometers');
opal.Ori = h5read(filename,'/SI-000738/Calibrated/Orientation');
opal.Time=h5read(filename,'/SI-000738/Time');
assignin('base','opal',opal)
if nargout == 1
    varargout{1} = opal;
else
end


