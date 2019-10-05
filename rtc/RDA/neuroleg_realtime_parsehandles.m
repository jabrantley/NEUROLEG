% Parse default params file
function handles = neuroleg_realtime_parsehandles(handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%          Define parameters       %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get params
params = handles.params;
% Set # EEG Channels
params.setup.allEEGchans = handles.eeg_nbchans.Value - params.setup.numEOGchans;
% Set EEG sampling rate
params.setup.eegsrate = handles.edit_eeg_srate.Value;
% Set EMG sampling rate
params.setup.emgsrate = handles.edit_biometrics_srate.Value;
% Get biometrics channels
% params.setup.BIOchannels = 
% params.setup.numBIOchans   = length(params.setup.BIOchannels);
% Zscore data
params.setup.standardizeEEG = handles.zscore_eegdata.Value;
params.setup.standardizeEMG = handles.zscore_emgdata.Value;
% Get control
if handles.radio_eeg_control.Value && ~handles.radio_emg_control.Value
    params.setup.control = 'EEG';
elseif ~handles.radio_eeg_control.Value && handles.radio_emg_control.Value
    params.setup.control = 'EMG';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%    Generate movement pattern     %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% # Train iterations
params.setup.trainiterations = handles.edit_num_trainiter.Value;
% # cycle per trial
params.sinewave.cycles = handles.edit_cycles_per_trial.Value;
% move frequency
params.sinewave.freq = str2double(handles.edit_move_freq.String);
% Make movement pattern
[fullwave, dswave,timevec] = make_movement_pattern(params.sinewave.cycles,params.sinewave.freq,params.sinewave.delay,params.setup.updaterate,params.setup.joint_angles);
% Update sinewave
params.sinewave.wave  = fullwave;
params.sinewave.dwave = dswave;
params.sinewave.time = timevec;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%       Hinfinity parameters       %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Kalman order
params.kalman.order = handles.edit_kalman_ord.Value;
% Kalman lambda
params.kalman.lambda = handles.edit_kalman_lambda.Value;
% Hinfinity gamma
params.hinf.gamma = handles.edit_hinf_gamma.Value;
% Hinfinity q
params.hinf.q = handles.edit_hinf_q.Value;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%          Design EEG filter       %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EEG filt freq
if params.eeg_bp_filt.band ~= handles.edit_eeg_filtfreq.Value
    % Get filt bands
    params.eeg_bp_filt.band = handles.edit_eeg_filtfreq.Value;
    % Get SS filter params
    [params.eeg_bp_filt.A,params.eeg_bp_filt.B,params.eeg_bp_filt.C,params.eeg_bp_filt.D]  = ...
        butter(2,params.eeg_bp_filt.band(1:2)/(params.setup.eegsrate/2),'bandpass');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%          Design EMG filter       %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EMG filt freq
if params.eeg_bp_filt.band ~= handles.edit_eeg_filtfreq.Value
    % Get filt bands
    emg_filt_band = handles.edit_emg_filtfreq.Value;
    % Get bandpass filter bands
    params.emg_bp_filt.band = emg_filt_band(1:2);
    % Get lowerpass filter band
    params.emg_lp_filt.band = emg_filt_band(3);
    % Get bandpass SS filter params
    [params.emg_bp_filt.A,params.emg_bp_filt.B,params.emg_bp_filt.C,params.emg_bp_filt.D]  = ...
        butter(2,params.emg_bp_filt.band(1:2)/(params.setup.emgsrate/2),'bandpass');
    % Get lowpass SS filter params
    [params.emg_lp_filt.A,params.emg_lp_filt.B,params.emg_lp_filt.C,params.emg_lp_filt.D]  = ...
        butter(2,params.emg_lp_filt.band/(params.setup.emgsrate/2),'bandpass');
end

% Update handles
handles.params = params;
end