%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%          ANALYZE EEG VS ISOLATED LIMB MOVEMENTS IN CHANEL SPACE         %
%                                                                         %
%               SEGMENT MOVEMENT WINDOW USING PHASE SHIFT                 %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1: Get cleaned data, segment movement windows. Address discrepancy between
%    movement onset cue and actual movement onset.
% 2: Get adjusted movement window, compute feature, train kalman filter

close all;
clear;
clc;

% Run parallel for
onCluster   = 0;
runParallel = 0;

% Define directory
thisdir = pwd;
idcs = strfind(pwd,filesep);
parentdir = thisdir(1:idcs(end-2));
addpath(genpath(fullfile(parentdir)));

% Set data dir
if onCluster
    rawdir  = '/project/contreras-vidal/justin/TEMPDATA/';
else
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
    rawdir   = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_RAW_SYNCHRONIZED_EEG_FMRI_DATA');
end

% Clean up
clearvars -except drive datadir rawdir savedir basepath EEG movedir parentdir ...
    onCluster runParallel

% Get files for each subject
subs = {'TF01','TF02','TF03'};

% Get variable names
vars = who;

% Filter parameters
realtimefilt = 0;
car_data     = 1;

% Define movement pattern parameters
srate          = 1000;
numCycles      = 6;   % number of cycles
move_freq      = .5; % speed of moving dot in hz
window_buffer  = 1; % 1 second shift TO ACCOUNT FOR ONSET ERROR
trial_duration = 12; % instead of using exp dur from STIM, fix length for consistency

% Define frequency bands
nfft    = [0.1:.1:100];
lodelta = [.3 1.5];
delta   = [.3 4];
theta   = [4 8];
alpha   = [8 13];
himu    = [10 12];
beta    = [15 30];
gamma   = [30 55];
higamma = [65 90];
full    = [.3 50];
nodelta = [4 50];
BANDS   = {theta,alpha,beta,gamma,higamma};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%        SEGMENT MOVE WINDOW         %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
all_movetimes = cell(length(subs),1);
% Loop through each subject, concatenate, and process
for aa = 1:length(subs)
    
    % Get variables
    vars = who;
    
    % Get eeg files for each subject
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-eeg.mat'   ]));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-stim.mat'  ]));
    % Load movement data
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-gonio.mat' ]));
    
    % Get trial information
    trialbreaks = EEG.trialbreaks;
    stimpattern = cell(size(STIM,1),1);
    movements = {'BH','RK','RA','LK','LA'};
    movetimes = cell(length(movements),2);
    
    % Loop through each movement
    for aaa = 1:length(movements)
        limb = movements{aaa};
        movetimes{aaa,1} = cell(size(STIM,1),2);
        movetimes{aaa,2} = movements{aaa};
        
        % Loop through each trial
        for bb = 1:size(STIM,1)
            
            % Get movement times from STIM
            rk_idx      = find(strcmpi(STIM(bb).states,limb)); % Get movements of right knee
            rk_onset    = STIM(bb).initialDelay + STIM(bb).onsets(rk_idx); % seconds
            rk_duration = STIM(bb).Duration(rk_idx); % seconds
            rk_time     = [rk_onset; rk_onset + rk_duration + window_buffer]'; % seconds [onset, offset]
            rk_samples  = floor(rk_time .* EEG.srate); % sample points
            
            % Store movement times
            movetimes{aaa}{bb,1} = find(EEG.trialbreaks==bb);
            movetimes{aaa}{bb,2} = rk_samples;
            
        end % bb = 1:size(STIM,1)
    end
    all_movetimes{aa} = movetimes;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%            ESTIMATE PSD            %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AllSub_PSDs = cell(length(subs),1);
AllBasePSDs = cell(length(subs),1);
% Loop through each subject
for aa = 1:length(subs)
    
    % Get variables
    vars = who;
    
    % Get eeg files for each subject
    if realtimefilt
        load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-eeg.mat'   ]));
    else
        if onCluster
            load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-BRAINSTORM-eeg.mat'   ]));
        else
            load(fullfile(datadir, [subs{aa}, '-ALLTRIALS-BRAINSTORM-eeg.mat'   ]));
        end
        
    end
    
    % Load stim data
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-stim.mat'  ]));
    
    % Get trial information
    trialbreaks = EEG.trialbreaks;
    stimpattern = cell(size(STIM,1),1);
    movements = {'BH','RK','RA','LK','LA'};
    movetimes = all_movetimes{aa};
    
    % Get channel locations
    montages = {EEG.chanlocs.labels};
    
    % Get eeg data
    eeg_data = EEG.data;
    
    % Common average reference
    if realtimefilt && car_data
        meanEEG = repmat(mean(eeg_data,1),size(eeg_data,1),1);
        eeg_data = eeg_data - meanEEG;
    end
   
    % Compute baseline psd
    basepsd = zeros(length(nfft),size(EEG.data,1));
    for bb = 1:size(EEG.data,1)
        [pxx,freq] = pmtm(EEG.data(bb,find(EEG.trialbreaks==0)),4,nfft,EEG.srate);
        basepsd(:,bb) = pxx(:);
    end
    AllBasePSDs{aa} = basepsd;
    
    move_psds = cell(length(movements),1);
    % Loop through each movement
    for bb = 1:length(movements)% 1:length(movements)
        
        % Initialize cell array for movedata
        psd_chan_data = cell(size(eeg_data,1),1);%,16);
        
        % Get move times for this movement
        thismove = movetimes{bb};
        
            % Loop through each trial
            for cc = 1:size(thismove,1)
                % Get eeg for trial
                trialdata = eeg_data(:,thismove{cc,1});
                for dd= 1:size(thismove{cc,2},1)
                    % Get movement window
                    move_win  = thismove{cc,2}(dd,:);
                    % Get start time and stop time
                    t1 = move_win(1)-window_buffer;
                    t2 = round(move_win(1)+(trial_duration*EEG.srate)- 1/EEG.srate + window_buffer);
                    % Shift time according to computed phase lag
                    temp_time =  move_win(1):move_win(2);%(t1:t2);
                    % Get data
                    tempeeg = trialdata(:,temp_time);
%                     
                    for ee = 1:size(tempeeg,1)
                        [pxx,freq] = pmtm(tempeeg(ee,:),4,nfft,EEG.srate);
                        psd_chan_data{ee,1} = cat(2,psd_chan_data{ee,1},pxx(:));
                    end
                end % dd = 1:size(movetimes{aaa}{cc,2},1)
            end %  cc = 1:size(movetimes{aaa},1)
            
%         filename = [subs{aa} '_KF_RESULTS_TARGET_EachChanBSClean_' movements{aaa} '_WIN' num2str(num2str(1/update_rate)) '_Z' num2str(zscore_data) '_CAR' num2str(car_data) '_AUG' num2str(useAug) '_UKF' num2str(useUKF) '.mat'];
%         save(filename,'R2_sub_all','R2_sub_mean','predicted_sub','BANDS','montages');
          move_psds{bb} = psd_chan_data;
    end % aaa = 1:length(movements)
    AllSub_PSDs{aa} = move_psds;
    %filename = [subs{aa} '_KF_RESULTS_WIN' num2str(num2str(1/update_rate)) '_Z' num2str(zscore_data) '_CAR' num2str(car_data) '_AUG' num2str(useAug) '_UKF' num2str(useUKF) '.mat'];
    %save(filename,'R2_ALL','R2_MEAN','PREDICT_ALL');
end % aa = 1:length(subs)

save('AllSub_PSDs.mat','AllSub_PSDs','AllBasePSDs')