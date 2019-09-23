%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                     NEUROLEG REAL TIME PROCESSING                       %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function implements the real time processing for control of
% the neuroleg from EEG. Uses RDA from Brain Products for streaming EEG
% data.
%
% University of Houston, Non-Invasive Brain Machine Interfaces Laboratory
% Written by: Justin Brantley - justin.a.brantley@gmail.com
% 09/20/2019: Date created

function [cleandata,filtdata,params] = neuroleg_realtime_processing(eegdata,eogdata,params)

% Generate noise template from eogdata
eye_artifacts = [eogdata(:,3) - eogdata(:,4),...
    eogdata(:,1) - eogdata(:,2),...
    ones(size(eogdata,1),1)];

cleandata = zeros(size(eegdata));
noisedata = zeros(size(eye_artifacts));

% Run Hinfinity to remove eye artifacts - operates on all channels @ a
% single time point
for ii = 1:size(eegdata,1) % all chans @ 1 time point
    [cleandata(ii,:),~,params.hinf.pt, params.hinf.wh] = hinfinity_local(eegdata(ii,:), eye_artifacts(ii,:), params.hinf.gamma, params.hinf.pt, params.hinf.wh, params.hinf.q);
end

% Filter data - filter each channel across time
xnn_temp = zeros(size(params.emg_bp_filt.xnn));
filtdata = zeros(size(cleandata));
for ii = 1:size(eegdata,2) % all time for a single channel
    [filtdata(:,ii),xnn_temp(:,ii)] = ss_filter_local(cleandata(:,ii),params.eeg_bp_filt.xnn(:,ii),params.A,params.B,params.C,params.D);
end
params.eeg_bp_filt.xnn = xnn_temp;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          %
%   State Space Filter     %
%                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [filt_mat,xn_out] = ss_filter_local(dataIn,Xn0,A,B,C,D)

filt_mat = zeros(length(dataIn),1);
for ii = 1 : length(dataIn)
    u = dataIn(ii);
    Xn1 = A*Xn0+B*u;
    ytemp = C*Xn0+D*u;
    filt_mat(ii) = ytemp;
    Xn0 = Xn1;
end
xn_out = Xn0;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          %
%  H-Infinity EOG Removal  %
%                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sh,zh,Pt,Wh] = hinfinity_local(Yf, Rf, gamma, Pt, Wh, q)
% University of Houston, Non-Invasive Brain Machine Interfaces Laboratory
% Original function written by Atilla Kilicarslan
% Modified by Justin Brantley
% 09/20/2019

% Reference for Ocular Artifact Cleaning:
% ----------------------------------------------------------------------------
% A robust adaptive denoising framework for real-time artifact removal in scalp EEG measurements.
% Kilicarslan A, Grossman RG, Contreras-Vidal JL.
% J Neural Eng. 2016 Apr;13(2):026013. doi: 10.1088/1741-2560/13/2/026013.
% ----------------------------------------------------------------------------

% Get data size
numTP  = size(Rf,1);
numDat = size(Yf,2);

% Preallocate
zh     = zeros(numTP,numDat);
sh     = zeros(numTP,numDat);

for n = 1:numTP
    % Get sample per channel (eeg+noise2 and noise1)   noise2 is the reflection of noise1 onto that channel
    r  = Rf(n,:)';
    % Calculate filter gains
    % P  = inv(  inv(Pt) - (gamma^(-2))*(r*r')  );
    % g  = (P*r)/(1+r'*P*r);
    P  = inv(Pt) - (gamma^(-2))*(r*r');
    g  = (P\r)/(1+(r'/P)*r);
    for m = 1:numDat
        y       = Yf(n,m);
        % Identify noise 2
        zh(n,m) = r'*Wh(:,m);
        % Calculate the error, this is also the clean eeg
        sh(n,m) = y-zh(n,m);
        % Update filter weights
        Wh(:,m) = Wh(:,m) + g*sh(n,m);
    end
    % Update noise covariance matrix
    Pt          = inv (  (inv(Pt))+ ((1-gamma^(-2))*(r*r')) ) + q*eye(size(Rf,2) );
end

end