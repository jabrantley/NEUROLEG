function [fullwave, dswave,newtimevec] = make_movement_pattern(numCycles,move_freq,delaybuffer,updaterate,joint_angles)
Tau         = numCycles*(1/move_freq); % time constant
oldtimevec     = 0:updaterate:Tau;        % time vector
newtimevec  = 0:updaterate:(Tau+delaybuffer+0.5*delaybuffer);
% Variable velocity - smoother and more natural
swave       = (joint_angles(2)/2) + (joint_angles(2)/2)*cos(move_freq*2*pi*oldtimevec+pi);
fullwave    = swave(1).*ones(1,length(newtimevec));
start_idx   = length(0:updaterate:delaybuffer-updaterate);
fullwave(1,start_idx:length(swave)+start_idx-1) = swave;
dswave      = diff([0 fullwave]);
end