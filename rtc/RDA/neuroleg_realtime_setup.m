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
numEEGchans   = length(chans2keep);    % number of eeg chans
EOGchannels   = [17,22,28,32];         % Define EOG channels
% EOGchannels   = [];                    % Define EOG channels
numEOGchans   = length(EOGchannels);   % number of eeg chans
BIOchannels   = [0,8];                 % 0-7 are analog channels, 8 and up start digital
numBIOchans   = length(BIOchannels);   % number of emg chans
numHinfRefs   = 3;                     % num reference channels for eog and bias/drift
time2cut      = 1;                     % Seconds to cut off after hinf
joint_angles  = [1, 60];               % Limits of joint angle for leg
% Store setup variables
setup         = struct('emgsrate',emgsrate,'eegsrate',eegsrate,'updaterate',updaterate,...
    'numEEGchans',numEEGchans,'EOGchannels',EOGchannels,'numEOGchans',numEOGchans,'numEEGpnts',numEEGpnts,...
    'chans2keep',chans2keep,'allEEGchans',allEEGchans,'numBIOchans',numBIOchans,'BIOchannels',BIOchannels,...
    'joint_angles',joint_angles,'time2cut',time2cut);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%     Kalman filter parameters     %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KF_ORDER  = [3,5];
KF_LAGS   = [3,5];
KF_LAMBDA = logspace(-2,2,5);
KF = struct('order',KF_ORDER,'lags',KF_LAGS,'lambda',KF_LAMBDA);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ner
%                                  %
%          Design EMG filter       %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Design bandpass butterworth filter for EMG
filt_order_emg = 2;            % butterworth filter order
filt_freqs_emg = [35 240 4];   % pass band
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
numCycles   = 4;                       % number of cycles
trainCycles = numCycles-2;             % number of cycles to keep for training
move_freq   = .25;                     % speed of moving dot in hz
Tau         = numCycles*(1/move_freq); % time constant
oldtimevec     = 0:updaterate:Tau;        % time vector
delaybuffer = 3;                      % seconds
newtimevec  = 0:updaterate:(Tau+2*delaybuffer);
% Variable velocity - smoother and more natural
swave       = (joint_angles(2)/2) + (joint_angles(2)/2)*cos(move_freq*2*pi*oldtimevec+pi);
fullwave    = swave(1).*ones(1,length(newtimevec));
start_idx   = length(0:updaterate:delaybuffer-updaterate);
fullwave(1,start_idx:length(swave)+start_idx-1) = swave;

dswave      = diff([0 swave]);

% Store sine wave params
sinwave     = struct('time',newtimevec,'wave',fullwave,'dwave',dswave,...
    'freq',move_freq,'cycles',numCycles,'delay',delaybuffer);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%         Generate figure          %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% f  = figure('color','w'); f.Position = [962, 42, 958, 954];
f = figure('color','w','units','inches','position',[-16.5 1.5 15.5 7.5]);

% Top axes
ax = gca; ax.Position = [.1 .55 .85 .4]; ax.Box = 'on';
p  = plot(fullwave,fullwave,'linewidth',2); hold on;
s  = scatter(0,0,125,'filled');

% Bottom axes
ax1 = axes; ax1.Position = [.1 .05 .85 .4]; ax1.Box = 'on';
p1  = plot(newtimevec,fullwave/max(fullwave),'linewidth',2); hold on;
s1  = scatter(newtimevec(1),fullwave(1)/max(fullwave),125,'filled');
xlim([delaybuffer-.5, Tau + delaybuffer + .5]);
% Store figure params
fig = struct('f',f,'p',p,'s',s,'p1',p,'s1',s1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%         STORE ALL PARAMS         %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = struct('eeg_bp_filt',eeg_bp_filt,'emg_bp_filt',emg_bp_filt,'emg_lp_filt',emg_lp_filt,...
    'hinf',hinf,'sinewave',sinwave,'fig',fig,'setup',setup,'kalman',KF);

end
