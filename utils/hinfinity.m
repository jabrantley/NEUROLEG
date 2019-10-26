%Hinfinity sample-adaptive filter for noise cancellation - solution to time varying
%filter weight estimation problem
%-   Reference: B. Hassibi and T. Kailath, H-infinity adaptive filtering,
%    Proceeding of the 1995 IEEE International Conference on Acoustics,
%    Speech and Signal Processing, pp. 949-952, Detroit, MI, May 1995.

%Atilla Kilicarslan - 2014,
%University of Houston, Laboratory for Non-Invasive Brain Machine Interface Systems

% ================================  Inputs  ===========================================
% Yf       : EEGdata --> num_sample x reduced channels
% Rf       : Reference channel --> usually num_sample x 3
%            column1 = eye blink differences [eye_upper-eye_lower]
%            column2 = eyemotion differences [temple_right-temple_left]
%            column3 = +1s for drift and bias removal
% gamma    : maximum bound on Hinfinity gain --> constant
% Pt       : initial covariance matrix       --> 1 x num_electrodes CELL,
%            3x3 matrix per cell (for 3 references)
% wh       : initial filter weigths          --> 3 x num_electrodes (for 3 references)
% q        : deviation factor from gamma<=1 condition for time varying hinfinity weight estimation problem s.t. gamma^2<=1+q*ref_bar
%
% ===============================  Outputs  ============================================
% shsh     : Hinf Filtered EEG    -->  num_sample x reduced channels   -->samples x num_channels

% ================================ Parallel Computing  =================================
% This version of HinfFilter utilize parallel computing feature in matlab. It should run 5-6 times faster than that in single thread manner on computers with 8 cores.
% Warning: Some internal variables are modified that they can no longer be retrived after the process. Some others only hold the value at the current iteration.
% Of course you can further modify the code if you do want to save internal variables.
% Update by Y.He, Feb.4.2015
% =======================================================================================
% edit : 2_11_2016 Atilla Kilicarslan

function [sh]=hinfinity(Yf, Rf,varargin)

% Check input arguments
if nargin < 2
    error('Insufficient number of input arguments.  Must include data and reference noise.')
end

% Initialize matrices
sh    = zeros(size(Yf));              % Filtered data
zh    = zeros(size(Rf,1),size(Yf,2));
wh    = zeros(size(Rf,2),size(Yf,2)); % Weights matrix

% SET DEFAULT PARAMETERS
gamma = 1.15;                      % Controls supression.  1.05:.05:1.50 all ok.  1.15 seems best
q     = 10^-9;                     % q = 10^-9, 10^-10 are ok.  < 10^-10 causes filter oscillations at signal jumps
par   = 0;                         % Set parallel to off by default
numCores = feature('numCores');    % Get available number of cores for parallel option

% Get variable input arguments
for ii = 1:2:length(varargin)
    param = varargin{ii};
    val = varargin{ii+1};
    switch lower(param)
        case 'gamma'
            gamma = val;
        case 'cores'
            numCores = val;
        case 'parallel'
            switch val
                case {'on','true',1}
                    par = 1;
                case {'off','false',0}
                    par = 0;
                otherwise
                    par = 0;
            end
        case 'q'
            q = val;
    end
end

% Check parallel option
if par
    % Initialize variables for slicing
    pt = repmat({0.1*eye(3)},1,size(Yf,2));
    
    % Initialize parfor progress bar
%     parfor_progress(size(Yf,2));
    
    % Open parallel pool
    mypool = gcp('nocreate'); % If no pool, do not create new one.
    
    % Create pool
    if isempty(mypool)
        poolsize = 0;
        mypool   = parpool(numCores);
    end
    
else
    pt = 0.1*eye(3);
end

% ---------------------- BEGIN H INFINITY FILTER ------------------------ %

% PARALLEL VERSION
if par
    %Iteration over channels
    parfor m=1:size(Yf,2)
%         parfor_progress;
        shsh = zeros(size(Rf,1),1);
        % Iteration over samples
        for n=1:size(Rf,1)
            % Get sample per channel (eeg+noise2 and noise1)   noise2 is the reflection of noise1 onto that channel
            y = Yf(n,m);
            r = Rf(n,:)';
            % calculate filter gains
            P = inv(pt{m}) - (gamma^(-2))*(r*r');
            g  = (P\r)/(1+(r'/P)*r);
            % Identify noise 2
            zh = r'*wh(:,m);
            % Calculate the error, this is also the clean eeg
            shsh(n) = y-zh;
            % Update filter weights
            wh(:,m) = wh(:,m) + g*shsh(n);
            % Update noise covariance matrix
            pt{m} = inv (  (inv(pt{m})) + ((1-gamma^(-2))*(r*r')) ) + q*eye(size(Rf,2));
        end
        sh(:,m) = shsh;
    end
% parfor_progress(0); % Clean up    
    
   
% NON-PARALLEL VERSION
else
    for n=1:size(Rf,1)
        % Get sample per channel (eeg+noise2 and noise1)   noise2 is the reflection of noise1 onto that channel
        r  = Rf(n,:)';
        % Calculate filter gains
        P  = inv(pt) - (gamma^(-2))*(r*r');
        g  = (P\r)/(1+(r'/P)*r);
        for m=1:size(Yf,2)
            y           = Yf(n,m);
            % Identify noise 2
            zh(n,m)     = r'*wh(:,m);
            % Calculate the error, this is also the clean eeg
            sh(n,m)     = y-zh(n,m);
            % Update filter weights
            wh(:,m)     = wh(:,m) + g*sh(n,m);
        end
        % Update noise covariance matrix
        pt          = inv (  (inv(pt))+ ((1-gamma^(-2))*(r*r')) ) + q*eye(size(Rf,2) );
    end
    
end
% 
% if par
%     delete(mypool);
% end


end % EOF