%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                  PROCESS DATA - CLEAN EEG AFTER ICA                     %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% In this analysis, ICA was run and bad ICS were removed from data.

close all;
clear;
clc;

% Define drive
if strcmpi(getenv('username'),'justi')% WHICHPC == 1
    drive = 'D:';
elseif strcmpi(getenv('username'),'jabrantl') %WHICHPC == 2
    drive = 'E:';
elseif strcmpi(computer,'MACI64') % macbook
    drive = '/Volumes/STORAGE/';
end

% Define directories
datadir  = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_PROCESS_SYNCHRONIZED_EEG_FMRI_DATA');
basepath = fullfile(drive,'Dropbox','Research','Analysis','MATLAB FUNCTIONS');
addpath(datadir);

% Add paths
addpath(genpath(fullfile(basepath,'Brainstorm','brainstorm3','toolbox')));
addpath(genpath(fullfile(basepath,'Custom MATLAB Functions')));
addpath(genpath(fullfile(basepath,'shoeeg')));
addpath(fullfile(basepath,'eeglab'));
eeglab;
close all;
clc;

% Clean up
clearvars -except drive datadir savedir basedir EEG

% Get all mat files
eegfiles = dir(fullfile(datadir, '*ALLTRIALS-eeg.mat'));

%% Load subject data
% ii = 1;
% disp(eegfiles(ii).name)
% load(fullfile(datadir,eegfiles(ii).name));
% 
% %% Analyze ICs
% EEG.data = double(EEG.data);
% EEG.reject.gcompreject = zeros( size(EEG.icawinv,2),1);
% 
% eegplot(EEG.data,'srate',EEG.srate,'winlength',10)
% 
% EEG.icaact = EEG.icaweights*EEG.icasphere*EEG.data;
% eegplot(EEG.icaact,'srate',EEG.srate,'dispchans',1,'winlength',10)
% mrifile = 'TF01-SurfVolMNI.nii';
% dipplot(EEG.dipfit.model,'mri',mrifile,'normlen','on','coordformat','MNI')
% EEG = JB_selectcomps(EEG,1:size(EEG.icawinv,2));
% 
% %%
% icnum = 1;
% figure; plot(EEG.icaact(icnum,:));

%%
% goodics = [TF01; TF02; TF03];
% ICs to keep = 1; bad ics = 0
goodics01 = [1,0,0,0,1,1,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,1,1,0,0,0,0,1,1,1,1,0,1,0,0,0];
goodics02 = [0,0,0,0,0,0,1,0,0,1,1,0,1,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1,1,0,1,1,0,1,1,1,1,1,1,1,0,1,1,1,1,0,1];
goodics03 = [1,1,1,0,1,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,1,1,1,0,1,1,1,1,1,0,1,1,1,0,1];

goodics = [goodics01; goodics02; goodics03];

rvThreshold = 16;

forBrainstorm = 1;

%if forBrainstorm
    
% Load files
for ii = 1:length(eegfiles)
    % Get variable names
    vars = who;
    % Load EEG data
    load(fullfile(datadir,eegfiles(ii).name));
    % Check to make sure the EEG struct is complete 
    [EEG,~] = eeg_checkset(EEG);
    
    % ------------ IMPORTANT ------------ %
    % Use data before high pass filtering
    EEG.data = EEG.preICAeeg;
    % ----------------------------------- %
    
    % Convert to double precision
    EEG.data = double(EEG.data);
    %EEG.icaact = EEG.icaweights*EEG.icasphere*EEG.data;
    % Store original ICA decomposition and DIPFIT before dipole removal
    EEG.ica_orig = struct('icawinv',EEG.icawinv,'icasphere',EEG.icasphere,'icaweights',EEG.icaweights);
    EEG.dipfit_orig = EEG.dipfit;
    % Select components based on residual variance
    components2keepFromRV = eeg_dipselect(EEG, rvThreshold, 'rv');
    % Select all components to keep
    if forBrainstorm
        components2keep = find(goodics(ii,:));
        method = 'BRAINSTORM';
    else
        % find components with low RV that are not noise in badics (badics
        components2keep = setdiff(components2keepFromRV,find(goodics(1,:)==0)); 
        method = 'DIPFIT';
    end
    % Remove non-selected components
    EEG = pop_subcomp(EEG, components2keep, 0, 1); % keep components with flag = 1
    % Compute ICA components
%     EEG.icaact = EEG.icaweights*EEG.icasphere*EEG.data;
    % 3D view as reference
    % dipplot(EEG.dipfit.model,'normlen','on','meshdata',EEG.dipfit.hdmfile,'coordformat','MNI');
    
    % Create new filename
    splitname = strsplit(eegfiles(ii).name,'-');
    flname = strjoin({splitname{1:2},method,splitname{end}},'-');
    % Save file information
    EEG.filename = flname;
    % Get rid of old data for size
    EEG.preICAeeg = [];
    EEG.preICAeeg = ['Data in: ' eegfiles(ii).name];
    % Save data
    savefile(EEG,'EEG',datadir,flname)
    
    % Save as set
    % pop_saveset(EEG,'filename',eegfiles(ii).name,'filepath',setdir); 
    
    % Clean up
    keepvars(vars);
    vars = who;
end






    
