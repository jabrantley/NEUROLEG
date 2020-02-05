function params = neuroleg_realtime_setup

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%          Define parameters       %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
emgsrate      = 500;                   % EMG sampling frequency
eegsrate      = 500;                   % EEG sampling frequency
updaterate    = 1/50;                  % data arrive in 50 ms windows
numEEGpnts    = eegsrate* updaterate;  % number of points in EEG
allEEGchans   = 60;                    % Total number of EEG channels
chans2keep    = [40,10,42,9,39,...     % EEG channels to keep
                 13,44,14,45,15];
% chans2keep    = [9,10,13,14,15,18,19,24];%,...
%23,27,29,30,31];
numEEGchans    = length(chans2keep);    % number of eeg chans
EOGchannels    = [17,22,28,32];         % Define EOG channels
% EOGchannels   = [];                    % Define EOG channels
numEOGchans    = length(EOGchannels);   % number of eeg chans
BIOchannels    = [0,8];                 % 0-7 are analog channels, 8 and up start digital
numBIOchans    = length(BIOchannels);   % number of emg chans
numHinfRefs    = 3;                     % num reference channels for eog and bias/drift
time2cut       = 1;                     % Seconds to cut off after hinf
joint_angles   = [1, 60];               % Limits of joint angle for leg
train_iters    = 4;
standardizeEEG = 1;
standardizeEMG = 1;
control        = 'EMG';
eeggain        = 1;
autogain       = struct('intact',1,'phantom',1);
filteog        = 0; % filter eog using first bandpass filter to rm noise
% Store setup variables
setup         = struct('emgsrate',emgsrate,'eegsrate',eegsrate,'updaterate',updaterate,...
    'numEEGchans',numEEGchans,'EOGchannels',EOGchannels,'numEOGchans',numEOGchans,'numEEGpnts',numEEGpnts,...
    'chans2keep',chans2keep,'allEEGchans',allEEGchans,'numBIOchans',numBIOchans,'BIOchannels',BIOchannels,...
    'joint_angles',joint_angles,'time2cut',time2cut,'trainiterations',train_iters,...
    'standardizeEEG',standardizeEEG,'standardizeEMG',standardizeEMG,'control',control,...
    'EEGgain',eeggain,'autogain',autogain,'filteog',filteog);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%     Kalman filter parameters     %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KF_ORDER  = [1,1];
KF_LAGS   = [3,10];
KF_LAMBDA = logspace(-2,2,5);
KF = struct('order',KF_ORDER,'lags',KF_LAGS,'lambda',KF_LAMBDA);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%    Design first EEG filter       %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filt_order_eeg0 = 2;        % butterworth filter order
filt_freqs_eeg0 = [0.3 50];  % pass band
xnn_bp_eeg0     = zeros(2*filt_order_eeg0,numEEGchans+numEOGchans);
[A0,B0,C0,D0]  = butter(filt_order_eeg0,filt_freqs_eeg0/(eegsrate/2),'bandpass');

% Store filter params
eeg_bp_filt0    = struct('A',A0,'B',B0,'C',C0,'D',D0,...
                        'xnn',xnn_bp_eeg0,'band',filt_freqs_eeg0);
                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%          Design EEG filter       %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filt_order_eeg = 2;        % butterworth filter order
filt_freqs_eeg = [0.3 4];  % pass band
xnn_bp_eeg     = zeros(2*filt_order_eeg,numEEGchans);
[A1,B1,C1,D1]  = butter(filt_order_eeg,filt_freqs_eeg/(eegsrate/2),'bandpass');

% Store filter params
eeg_bp_filt    = struct('A',A1,'B',B1,'C',C1,'D',D1,...
                        'xnn',xnn_bp_eeg,'band',filt_freqs_eeg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%          Design EMG filter       %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Design bandpass butterworth filter for EMG
filt_order_emg = 2;            % butterworth filter order
filt_freqs_emg = [35, 240, 4];   % pass band
xnn_bp_emg     = zeros(2*filt_order_emg,numBIOchans);
xnn_lp_emg     = zeros(filt_order_emg,numBIOchans);

% Bandpass filter
[A2,B2,C2,D2]  = butter(filt_order_emg,filt_freqs_emg(1:2)/(emgsrate/2),'bandpass');
emg_bp_filt    = struct('A',A2,'B',B2,'C',C2,'D',D2,...
                        'xnn',xnn_bp_emg,'band',filt_freqs_emg(1:2));

% Low pass filter - envelope
[A3,B3,C3,D3]  = butter(filt_order_emg,filt_freqs_emg(3)/(emgsrate/2),'low');
emg_lp_filt    = struct('A',A3,'B',B3,'C',C3,'D',D3,...
    'xnn',xnn_lp_emg,'band',filt_freqs_emg(3));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%       Hinfinity parameters       %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(EOGchannels)
    gamma      = 1.15;  % gamma for Hinf (>1, increase to accommodate larger artifacts)
    q          = 1e-9;  % q for Hinf (increase if higher frequencies are handled)
    pt_hinf    = 0.1.*eye(numHinfRefs);
    wh_hinf    = 0+zeros(numHinfRefs,numEEGchans);
    % cleandata  = zeros(numEEGchans,sizeWindow);
    % noisedata  = zeros(numHinfRefs,sizeWindow);
    hinf       = struct('gamma',gamma,'q',q,'pt',pt_hinf,'wh',wh_hinf);
else
    hinf = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%    Generate movement pattern     %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numCycles   = 8;                       % number of cycles
move_freq   = 0.25;                    % speed of moving dot in hz
delaybuffer = 10;                       % seconds
Tau         = numCycles*(1/move_freq); % time constant
% Get sinewave
[fullwave, dswave,newtimevec] = make_movement_pattern(numCycles,move_freq,delaybuffer,updaterate,joint_angles);
facealpha = ones(1,length(fullwave));
facealpha(1:delaybuffer/updaterate) = linspace(0,1,delaybuffer/updaterate);

% Store sine wave params
sinwave     = struct('time',newtimevec,'wave',fullwave,'dwave',dswave,...
                     'freq',move_freq,'cycles',numCycles,'delay',delaybuffer,...
                     'facealpha',facealpha);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%         Generate figure          %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fig = build_movement_fig(sinwave);
fig = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%         STORE ALL PARAMS         %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = struct('eeg_bp_filt',eeg_bp_filt,'eeg_bp_filt0',eeg_bp_filt0,'emg_bp_filt',emg_bp_filt,'emg_lp_filt',emg_lp_filt,...
    'hinf',hinf,'sinewave',sinwave,'fig',fig,'setup',setup,'kalman',KF);

end