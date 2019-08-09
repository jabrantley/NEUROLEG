% Program to calculate orientation using Kalman Filter and Gauss Newton
% optimization. Further, apply gravity compensation to raw measuremnts
% obtained from OPAL Motion Capture system from APDM. 
% For details regarding the Gauss Newton Optimization, refer
% <http://code.google.com/p/9dof-orientation-estimation/>

% Download following libraries: 
% 1. Gauss Newton optimization files, <http://9dof-orientation-estimation.googlecode.com/files/KalmanFilter_V11.zip>
% 2. MATLAB Quaternion Toolbox, <http://www.mathworks.com/matlabcentral/fileexchange/1176-quaternion-toolbox/content/quaternions/q2dcm.m>

% Author: Nikunj Bhagat, University of Houston
% Date Created: 7/5/2013 (DD-MM-YYYY)
% Version 1.2
% Last Modified: 6/3/2014 by Kevin
%                8/8/2019 by Justin Brantley:
%                   * Removed unneded and commented sections. 
%                   * Updated URL for 9DOF orientation estimatation: % https://code.google.com/archive/p/9dof-orientation-estimation/

function opal_out = Orientation_Estimation(opal_in)
Fs = 128;      % Opal's Sampling frequency
Ts = 1/Fs;     % Sample time
% Get data
Data = opal_in;
acc  = Data(:,1:3)';        % Accelerometer
gyro = Data(:,4:6)';        % Gyroscope 
magm = Data(:,7:9)';        % Magnetometer
% Set params
N = length(acc);
Meas_Filter_ON = 0;              % Set to 1, if you want to low pass filter raw measurements
Quat_Filter_ON = 1;
Quat_MA_Filter_ON = 1;
Quat_Butter_Filter_ON = 0;

% Design, 4th order butterworth, Lowpass Filter with cutoff = 10 Hz
if Meas_Filter_ON == 1
    n = 4; Wn = 10/(Fs/2);
    [b,a] = butter(n,Wn,'low');
    for s = 1:3
        acc(s,:) = filtfilt(b,a,acc(s,:));
        gyro(s,:) = filtfilt(b,a,gyro(s,:));
        magm(s,:) = filtfilt(b,a,magm(s,:));
    end
end

% Quaternions & Euler estimations
q_tilda = zeros(4,N);
q_hat = zeros(4,N);
euler_hat = zeros(3,N);
euler_2 = zeros(3,N);

% Gyroscope statistics
%Offset=[-3.6982,-3.3570,-2.5909]';
%var=[(0.5647/180*pi)^2 (0.5674/180*pi)^2 (0.5394/180*pi)^2]';
gyro_mean = [mean(gyro(1,:)),mean(gyro(2,:)),mean(gyro(:,3))]';
gyro(1,:) = gyro(1,:) - gyro_mean(1,1);     %Subtract mean from gyro data  
gyro(2,:) = gyro(2,:) - gyro_mean(2,1);
gyro(3,:) = gyro(3,:) - gyro_mean(3,1);
gyro_var  = [var(gyro(1,:)),var(gyro(2,:)),var(gyro(:,3))]';


%% System Model

% State transition matrix F, is time varying hence calculated in for loop

% Q - Process noise covariance matrix
Q1 = [gyro_var(1,1)+gyro_var(2,1)+gyro_var(3,1) -gyro_var(1,1)+gyro_var(2,1)-gyro_var(3,1) -gyro_var(1,1)-gyro_var(2,1)+gyro_var(3,1) gyro_var(1,1)-gyro_var(2,1)-gyro_var(3,1)];
Q2 = [-gyro_var(1,1)+gyro_var(2,1)-gyro_var(3,1) gyro_var(1,1)+gyro_var(2,1)+gyro_var(3,1) gyro_var(1,1)-gyro_var(2,1)-gyro_var(3,1) -gyro_var(1,1)-gyro_var(2,1)+gyro_var(3,1)];
Q3 = [-gyro_var(1,1)-gyro_var(2,1)+gyro_var(3,1) gyro_var(1,1)-gyro_var(2,1)-gyro_var(3,1) gyro_var(1,1)+gyro_var(2,1)+gyro_var(3,1) -gyro_var(1,1)+gyro_var(2,1)-gyro_var(3,1)];
Q4 = [gyro_var(1,1)-gyro_var(2,1)-gyro_var(3,1) -gyro_var(1,1)+gyro_var(2,1)-gyro_var(3,1) -gyro_var(1,1)+gyro_var(2,1)-gyro_var(3,1) gyro_var(1,1)+gyro_var(2,1)+gyro_var(3,1)];
Q  = [Q1;Q2;Q3;Q4];

% H - Observation model is identity
H = eye(4);

% R Process Noise covariance matrix 
var_u = 0.05;       
R = var_u*eye(4);

%% Kalman Filter Equations

Pk_1 = zeros(4,4);              % State error covariance P(k-1,k-1)
Pk   = zeros(4,4);              % P(k,k-1)
G    = zeros(4,4);              % Kalman Gain
p11  = zeros(1,N);
p12  = zeros(1,N);
mu=zeros(1,N);
dqnorm=zeros(1,N);
dq=zeros(4,N);

%Initialization
q_tilda_init =  [1 0 0 0]';
qhat_init = q_tilda_init;
P_init    = 2*eye(4);         % Unbias the KF

for k = 1:N
    if k == 1
        
        % Gauss Newton step 
        q_tilda(:,1) = GaussNewtonMethod(q_tilda_init,acc(:,1),magm(:,1));
        q_tilda(:,1) = q_tilda(:,1)/norm(q_tilda(:,1));
        q_hat(:,1) = qhat_init;
        Pk = P_init;
        G = Pk*H'/(H*Pk*H'+ R);             % Kalman Gain update, right matrix division
        q_hat(:,1) = q_hat(:,1) + G*(q_tilda(:,1) - H*q_hat(:,1)); % Correction
        q_hat(:,1) = q_hat(:,1)/norm(q_hat(:,1));   % Normalize q_hat
        Pk = (eye(4) - G*H)*Pk;             % Correction  
    else
        
        % Gauss Newton step 
        q_tilda(:,k) = GaussNewtonMethod(q_tilda(:,k-1),acc(:,k),magm(:,k));
        q_tilda(:,k) = q_tilda(:,k)/norm(q_tilda(:,k));
        
        % Compute F matrix
        const = Ts/2;
        F1=[1 -const*gyro(1,k-1) -const*gyro(2,k-1) -const*gyro(3,k-1)];
        F2=[const*gyro(1,k-1) 1 const*gyro(3,k-1) -const*gyro(2,k-1)];
        F3=[const*gyro(2,k-1) -const*gyro(3,k-1) 1 const*gyro(1,k-1)];
        F4=[-const*gyro(3,k-1) const*gyro(2,k-1) -const*gyro(1,k-1) 1];
    
        Fk_1=[F1;F2;F3;F4];     % F(k-1)
        
        q_hat(:,k) = Fk_1*q_hat(:,k-1);     % Prediction
        Pk = Fk_1*Pk_1*Fk_1' + Q;           % Prediction
        G = Pk*H'/(H*Pk*H'+ R);             % Kalman Gain update, right matrix division
       
        q_hat(:,k) = q_hat(:,k) + G*(q_tilda(:,k) - H*q_hat(:,k)); % Correction
        q_hat(:,k) = q_hat(:,k)/norm(q_hat(:,k));   % Normalize q_hat
        Pk = (eye(4) - G*H)*Pk;             % Correction  
        
    end
    p11(:,k) = G(1,1);
    p22(:,k) = G(2,2);
    Pk_1 = Pk;
end

%% Quaternion Filtering
if Quat_Filter_ON == 1
    if Quat_Butter_Filter_ON == 1
    % Low pass Butterworth Filter
     Fc = 40;
     n = 4; Wn = Fc/(Fs/2); 
    [b,a] = butter(n,Wn,'low');
    fig_title = ['Quaternion Estimation with Butterworth LowPass Filter, cutoff = ' num2str(Fc) ' Hz'];
    elseif Quat_MA_Filter_ON == 1
    % Moving Average Filter
    window_length = 5; 
    a = 1; 
    b = (1/window_length)*ones(1,window_length);
    fig_title = ['Quaternion Estimation with Moving Avg Filter, Window length = ' num2str(window_length)];
    else 
        disp('Error!! No filter selected');
        return;
    end
    % freqz(b,a,512,Fs); 
    for s = 1:4
        q_hat(s,:) = filtfilt(b,a,q_hat(s,:));
    end

end

%% Calculation of Rotation matrix from Quaternion and applying gravity compensation
Quaternion = q_hat';
Acc_b = acc';
fs = 128;
Ts = 1/fs;
t_plot = (1:size(Acc_b,1))/fs;

% NOTE: Quaternion order different then standard required by q2dcm commands. The scalar value is last. New
% order is Quat = q2*i + q3*j + q4*k + q1
Quat = [Quaternion(:,2) Quaternion(:,3) Quaternion(:,4) Quaternion(:,1)];

Tn2b = q2dcm(Quat); 
% q2dcm is available from Quaternion Toolbox. It calculates Direction
% Cosine or Rotation Matrix from Quaternion. It calculates the
% transformation matrix (Tn2b) from Navigation frame to Body frame. For gravity
% compensation, we need the transformation matrix (Tb2n) from body frame to
% navigation frame. Hence, take a transpose. 

Tb2n = zeros(size(Tn2b));
Acc_n = zeros(size(Acc_b));
for i = 1:length(Tn2b)
    Tb2n(:,:,i) = Tn2b(:,:,i)';
    Acc_n(i,:) = Tb2n(:,:,i)*(Acc_b(i,:)');     % Acceleration in navigation frame 
    Acc_n(i,:) = Acc_n(i,:) - [0 0 9.81];        % Gravity (9.81  m/s^2) compensation
end



fn = Acc_n;
t = (1:length(fn))/fs;
vel(1,:) = [0 0 0];
 for j=1:length(t)-1
     vel(j+1,1) = vel(j,1) + (t(j+1)-t(j))/2*(fn(j+1,1)+fn(j,1));
     vel(j+1,2) = vel(j,2) + (t(j+1)-t(j))/2*(fn(j+1,2)+fn(j,2));
     vel(j+1,3) = vel(j,3) + (t(j+1)-t(j))/2*(fn(j+1,3)+fn(j,3));
 end
% filtering to remove integration drifts
% Design of High Pass Filter
fc = 0.3;                    % Cutoff frequency in Hz
num = [1 -1];               
den = [((2*pi*fc*Ts) + 2)/2 ((2*pi*fc*Ts) - 2)/2];
vel_filt(:,1) = filter(num,den,vel(:,1));
vel_filt(:,2) = filter(num,den,vel(:,2));
vel_filt(:,3) = filter(num,den,vel(:,3));

opal_out = Acc_n;