%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                   NEUROLEG REAL TIME - TRAIN UKF MODEL                  %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function implements the UKF training between EEG/EMG and angles. 
%
% University of Houston, Non-Invasive Brain Machine Interfaces Laboratory
% Written by: Justin Brantley - justin.a.brantley@gmail.com
% 09/24/2019: Date created

function neuroleg_realtime_train(params,EEG,EMG,ANGLES)

% Get EOG data
EOG = EEG(params.setup.EOGchannels,:);

% Remove EOG from EEG data
EEG(params.setup.EOGchannels,:) = [];

% Process data
[params,cleaneeg,filteeg,filtemg,envemg] = neuroleg_realtime_processing(params,EEG',EOG',EMG');

% Smooth angles using moving average
filtangles = smooth(ANGLES,20);

% Split data
find([0 diff(SYNCHANGLE>0)]
params.sinewave.cycles
find([0 diff(repmat(SYNCHANGLE,1,4)>0)]>0)
end