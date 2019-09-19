clc, clear all, format compact, close all

%% Info

% Created by Atilla Kilicarslan,
% University of Houston, Electrical and Computer Engineering Department
% Non-Invasive Brain Machine Interface Systems Lab.
% Houston, TX, USA
% 07/2019

% ----------------------------------------------------------------------------
% This code implements the motion artifact cleaning from all EEG sensors,
% using the forehead acceleration values. This is a test code for calling the MEX
% implementation fo the method (uhbmi_CleanMotionArtifacts_mex.mexw64)
% ----------------------------------------------------------------------------

% Reference for Motion Artifact Cleaning:
%-----------------------------------------------------------------------------
% Characterization and real-time removal of motion artifacts from EEG signals.
% Kilicarslan A, Contreras-Vidal JL.
% Journal of Neural Eng. 2019 Jun 20. doi: 10.1088/1741-2552/ab2b61.
%-----------------------------------------------------------------------------

% Reference for Ocular Artifact Cleaning:
% ----------------------------------------------------------------------------
% A robust adaptive denoising framework for real-time artifact removal in scalp EEG measurements.
% Kilicarslan A, Grossman RG, Contreras-Vidal JL.
% J Neural Eng. 2016 Apr;13(2):026013. doi: 10.1088/1741-2560/13/2/026013.
% ----------------------------------------------------------------------------

% Code Info:
% ----------------------------------------------------------------------------
% cleanData(i,:) = uhbmi_CleanMotionArtifacts_mex(inDataEEG(i,:), inDataRef(i,:), gamma, q, numTaps, A, B, C, D);
% ::inputs
% inDataEEG(i,:) = 1x64 EEG data (time x Channels) to be cleaned
% inDataRef(i,:) = 1x3( or n) reference data of 3 axis gravity compensated acceleration. For other implementations, MEX compiled for n<=10
% gamma          = 1x1 gamma for Hinf algorithm
% q              = 1x1 q for hinf Algorithm
% numTaps        = 1x1 number of taps for the volterra kernel
% A(4x4xn)
% B(4x1xn)
% C(1x4xn)
% D(1x1xn)       = state space butterworth filter parameters for each frequency band.
%                  n = number of target frequency bands to clean. MEX compiled for n<=10
% ::outputs
% cleanData(i,:) = 1x64 clenaed EEG data

% Copyright Info:
% ----------------------------------------------------------------------------
%Copyright
%2019
%Atilla Kilicarslan
%Jose Luis contreras-Vidal
%University of Houston, Houston TX, USA

%% LOAD EEG AND ACCELERATION DATA
load uhbmi_MotionArtifactSampleData.mat % 4 mph walking on a treadmill

%reference: gravity compansated forehead acceleration.
%This code has not been tested with non-gravity compansated values.

% rawData: Ocular artifact cleaned EEG (using our Hinf Method) data for 64 channels.
% Note that channels 17 22 28 and 32 are just noise and do not contain ANY information.
% Original channel data were used as reference for ocular artifact cleaning.
% some data are present here just for simplicity, to conform with the channel indices

% CAR <- optional
% temp = 1:64; temp([17 22 28 32]) = [];
% rawData(:,temp) = bsxfun(@minus,rawData(:,temp),mean(rawData(:,temp),2));

%% DEFINITIONS

% ----- Data -------
samplingFrequency = 100; % sampling frequency

% Get a sub section of the data for fast debugging.
% First and last 1 minutes are standing still on the treadmill.
limitData = 120*samplingFrequency:180*samplingFrequency;
inDataRef = reference(limitData,:);
inDataEEG = rawData(limitData,:);

% ----- Band Pass Filter -------
frequenciesToClean  = [2 3 6];  % these are the target frequencies to clean from EEG. Leave it empty ([]) if you need to clean
                                % the data with an approximately narrowband reference signal (such as reference for ocular artifacts, 
                                % as the reference EOG has information content in a narrow frequency range. 
                                % Other high frequency noises in the EOG / or noises with no information content do not matter) 
                                % As an example for the current motion artifact implementation, and as a proof of concept, CH 1 data is mostly
                                % contaminated at 2, 3, and 6 Hz frequencies. A wider coverage for other ferquencies are certainly possible.
                                
butterOrder         = 2;             % Butterworth filter order
fBound              = 0.6;           % +- pass band around each target frequency
numDecomp           = length(frequenciesToClean);


if numDecomp~=0
    A=zeros(butterOrder*2,butterOrder*2,numDecomp); % state space filter parameters per target frequency band
    B=zeros(butterOrder*2,1,numDecomp);
    C=zeros(1,butterOrder*2,numDecomp);
    D=zeros(1,1,numDecomp);
    for i=1:numDecomp
        Wn  = [frequenciesToClean(i)-fBound frequenciesToClean(i)+fBound]/(0.5*samplingFrequency);
        [A(:,:,i),B(:,:,i),C(:,:,i),D(:,:,i)]  = butter(butterOrder,Wn);
    end
else
    A=zeros(butterOrder*2,butterOrder*2,1); % state space filter parameters per target frequency band
    B=zeros(butterOrder*2,1,1);
    C=zeros(1,butterOrder*2,1);
    D=zeros(1,1,numDecomp);
    Wn   = [0.3 (0.5*samplingFrequency)-1]/(0.5*samplingFrequency);
    [A(:,:,1),B(:,:,1),C(:,:,1),D(:,:,1)]  = butter(butterOrder,Wn);
end


% ----- Motion Artifact Filter -------
% Note that gamma and q are important for good filter performnace.
% Non-proper selections can make the filter unstable and cause divergence.
gamma               = 1.5;    % gamma for Hinf (>1, increase to accommodate larger artifacts)
q                   = 1e-15;  % q for Hinf (increase if higher frequencies are handled)
numTaps             = 3;      % number of time taps to use for Volterra
% numTaps>=1 is the non-linear cleaning case
% for Linear cleaning numTaps should be 0.
% If you need time tapped reference values but linear cleaning,
% tap the reference BEFORE it enters the _mex function and use taps = 0

%% CLEAN MOTION ARTIFACTS
% This implementation is for each sample of EEG data (for all 64 channels), simulating the real-time implementation of the
% motion artifact filter. For offline processing, EEG and REF data can be
% given as Nx64 and Nx3, where N is the number of samples..

% TODO : Double check the MEX implementation for accepting offline/bufered data.
% It is very simple to modify, just lift/adjust the size constraint on the
% incoming data, if not already done. inadvisable to make them inf.

cleanData = zeros(size(inDataEEG)); % allocate memory for clean data
clear uhbmi_CleanMotionArtifacts    % clear the persistent variables for the MEX implementation

tic
%profile on;
for i=1:size(inDataEEG,1)
    % for MEX CALL
%     cleanData(i,:) = uhbmi_CleanMotionArtifacts_mex(inDataEEG(i,:), inDataRef(i,:), gamma, q, numTaps, A, B, C, D);
    % for .m file CALL
    cleanData(i,:) = uhbmi_CleanMotionArtifacts(inDataEEG(i,:), inDataRef(i,:), gamma, q, numTaps, A, B, C, D);
end
%profile viewer;
computeTime = toc;
%% PLOT RESULTS TO COMPARE

close all
ch        = 1; % EEG channel to plot
plotLim   = 1:size(inDataEEG,1); % time limits for plotting (just for fast debugging) if needed
t         = 0:1/samplingFrequency:(length(plotLim)-1)/samplingFrequency;
info      = sprintf('Cleaned %d Target Frequencies, %d channels of %0.2f sec EEG in ~%0.2f seconds',...
    numDecomp, size(inDataEEG,2),length(inDataEEG)/samplingFrequency, computeTime );

figure
subplot(2,1,1), hold on, grid on
title(info)
plot(t,inDataEEG(plotLim,ch)-mean(inDataEEG(plotLim,ch)))
plot(t,cleanData(plotLim,ch))
legend('raw','clean')
xlabel('time [sec]')
ylabel('EEG amplitude [ \muV ]')
xlim([0 t(end)])

subplot(2,1,2), hold on
pmtm([inDataEEG(plotLim,ch)-mean(inDataEEG(plotLim,ch)) cleanData(plotLim,ch)],4,[],samplingFrequency)
legend('raw','clean')
%xlim([0 20])
%ylim([-80 45])



