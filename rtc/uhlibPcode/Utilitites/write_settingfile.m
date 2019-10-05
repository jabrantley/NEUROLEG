function write_settingfile(fid,varargin)
% This file write setting information for NEUROLEG project
expdate = get_varargin(varargin,'expdate','0-0-0'); % date of experiment
alleegch = get_varargin(varargin,'alleegch',64); % number of all eeg ch
remeegch = get_varargin(varargin,'remeegch',48); % remained eeg channels
jointfactor = get_varargin(varargin,'jointfactor','90 90 45 90 90 45');
notes = get_varargin(varargin,'notes','BMI Team-UH');
% Write to the text file;
fprintf(fid,'Exp Date: %s \n',expdate);
fprintf(fid,'Numbers of all EEG channels: %d \n',alleegch);
fprintf(fid,'Numbers of used EEG channels: %d \n',remeegch);
fprintf(fid,'Joint Factor: %s\n',jointfactor);
fprintf(fid,'Notes: %s \n',[notes';repmat(char(10),1,size(notes,1))]); %Important, notes is char matrix