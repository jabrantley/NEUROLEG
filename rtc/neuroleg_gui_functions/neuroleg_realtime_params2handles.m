function handles = neuroleg_realtime_params2handles(params,handles)
% Subject Name
handles.edit_subject_name.String = 'NAME';
% Set save directory
handles.dir_name.String = pwd;
% Set # EEG Channels
handles.eeg_nbchans.Value = params.setup.allEEGchans + params.setup.numEOGchans;
handles.eeg_nbchans.String = num2str(handles.eeg_nbchans.Value);
% Set EEG sampling rate
handles.edit_eeg_srate.Value = params.setup.eegsrate;
handles.edit_eeg_srate.String = num2str(handles.edit_eeg_srate.Value);
% Set EMG sampling rate
handles.edit_biometrics_srate.Value = params.setup.emgsrate;
handles.edit_biometrics_srate.String = num2str(handles.edit_biometrics_srate.Value);
% # Train iterations
handles.edit_num_trainiter.Value = params.setup.trainiterations;
handles.edit_num_trainiter.String = num2str(handles.edit_num_trainiter.Value);
% # cycle per trial
handles.edit_cycles_per_trial.Value = params.sinewave.cycles;
handles.edit_cycles_per_trial.String = num2str(handles.edit_cycles_per_trial.Value);
% Kalman order
handles.edit_kalman_ord.Value = params.kalman.order;
handles.edit_kalman_ord.String = strjoin(sprintfc('%.1g',handles.edit_kalman_ord.Value),',');
% Kalman lambda
handles.edit_kalman_lambda.Value = params.kalman.lambda;
handles.edit_kalman_lambda.String = strjoin(sprintfc('%.1g',handles.edit_kalman_lambda.Value),',');
% Hinfinity gamma
handles.edit_hinf_gamma.Value = params.hinf.gamma;
handles.edit_hinf_gamma.String = num2str(handles.edit_hinf_gamma.Value);
% Hinfinity q
handles.edit_hinf_q.Value = params.hinf.q;
handles.edit_hinf_q.String = num2str(handles.edit_hinf_q.Value);
% EEG filt freq
handles.edit_eeg_filtfreq.Value = params.eeg_bp_filt.band;
handles.edit_eeg_filtfreq.String = strjoin(sprintfc('%.1g',handles.edit_eeg_filtfreq.Value),',');
% EMG filt freq
handles.edit_emg_filtfreq.Value = params.emg_bp_filt.band;
handles.edit_emg_filtfreq.String = strjoin(sprintfc('%d',handles.edit_emg_filtfreq.Value),',');
% EMG filt freq
handles.edit_emg_filtfreq.Value = [params.emg_bp_filt.band,params.emg_lp_filt.band];
handles.edit_emg_filtfreq.String = strjoin(sprintfc('%d',handles.edit_emg_filtfreq.Value),',');
% Add params to handles
handles.params = params;