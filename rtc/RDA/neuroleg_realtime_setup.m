function params = neuroleg_realtime_setup

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%          Define parameters       %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
emgsrate      = 1000;     % EMG sampling frequency
eegsrate      = 1000;     % EEG sampling frequency 
updaterate    = 1/50; % data arrive in 50 ms windows
numEEGpnts    = eegsrate* updaterate; % number of points in EEG
numEMGchans   = 1;       % number of emg chans 
numEEGchans   = 60;       % number of eeg chans 
numEOGchans   = 4;       % number of eeg chans 
numHinfRefs   = 3;        % num reference channels for eog and bias/drift
joint_angles = [1, 60];

% Store setup variables
setup        = struct('emgsrate',emgsrate,'eegsrate',eegsrate,'updaterate',updaterate,...
               'numEEGchans',numEEGchans,'numEMGchans',numEMGchans,...
               'numEOGchans',numEOGchans,'numEEGpnts',numEEGpnts,...
               'joint_angles',joint_angles);
           
           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%          Design EEG filter       %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filt_order_eeg = 2;        % butterworth filter order
filt_freqs_eeg = [8 12];   % pass band
xnn_bp_eeg     = zeros(2*filt_order_eeg,numEEGchans);
[A1,B1,C1,D1]  = butter(filt_order_eeg,filt_freqs_eeg/(eegsrate/2),'bandpass');

% Store filter params
eeg_bp_filt    = struct('A',A1,'B',B1,'C',C1,'D',D1,...
                     'xnn',xnn_bp_eeg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%          Design EMG filter       %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Design bandpass butterworth filter for EMG
filt_order_emg = 2;            % butterworth filter order
filt_freqs_emg = [35 450 4];   % pass band
xnn_bp_emg     = zeros(2*filt_order_emg,numEMGchans);
xnn_lp_emg     = zeros(filt_order_emg,numEMGchans);

% Bandpass filter
[A2,B2,C2,D2]  = butter(filt_order_emg,filt_freqs_emg(1:2)/(emgsrate/2),'bandpass');
emg_bp_filt    = struct('A',A2,'B',B2,'C',C2,'D',D2,...
                'xnn',xnn_bp_emg);
            
% Low pass filter - envelope
[A3,B3,C3,D3]  = butter(filt_order_emg,filt_freqs_emg(3)/(emgsrate/2),'low');
emg_lp_filt    = struct('A',A3,'B',B3,'C',C3,'D',D3,...
                'xnn',xnn_lp_emg);
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%       Hinfinity parameters       %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gamma      = 1.15;  % gamma for Hinf (>1, increase to accommodate larger artifacts)
q          = 1e-9;  % q for Hinf (increase if higher frequencies are handled)
pt_hinf    = 0.1.*eye(numHinfRefs);
wh_hinf    = 0+zeros(numHinfRefs,numEEGchans);
% cleandata  = zeros(numEEGchans,sizeWindow);
% noisedata  = zeros(numHinfRefs,sizeWindow);
hinf       = struct('gamma',gamma,'q',q,'pt',pt_hinf,'wh',wh_hinf);
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%    Generate movement pattern     %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numCycles   = 4;                       % number of cycles
trainCycles = numCycles-2;             % number of cycles to keep for training
move_freq   = .25;                     % speed of moving dot in hz
Tau         = numCycles*(1/move_freq); % time constant
timevec     = 0:updaterate:Tau;        % time vector

% Variable velocity - smoother and more natural
swave       = (joint_angles(2)/2) + (joint_angles(2)/2)*cos(move_freq*2*pi*timevec+pi);
dswave      = diff([0 swave]);

% Store sine wave params
sinwave     = struct('time',timevec,'wave',swave,'dwave',dswave,...
                 'freq',move_freq,'cycles',numCycles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%         Generate figure          %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f  = figure('color','w'); f.Position = [962, 42, 958, 954];

% Top axes
ax = gca; ax.Position = [.1 .55 .85 .4]; ax.Box = 'on';
p  = plot(swave,swave); hold on;
s  = scatter(0,0,125,'filled');

% Bottom axes
ax1 = axes; ax1.Position = [.1 .05 .85 .4]; ax1.Box = 'on';
p1  = plot(timevec,swave/max(swave)); hold on;
s1  = scatter(timevec(1),swave(1)/max(swave),125,'filled');

% Store figure params
fig = struct('f',f,'p',p,'s',s,'p1',p,'s1',s1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%         STORE ALL PARAMS         %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = struct('eeg_bp_filt',eeg_bp_filt,'emg_bp_filt',emg_bp_filt,'emg_lp_filt',emg_lp_filt,...
                'hinf',hinf,'sinewave',sinwave,'fig',fig,'setup',setup);
            
end
