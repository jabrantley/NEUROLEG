%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                  PROCESS DATA - SEGMENT MOVEMENT WINDOW                 %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get cleaned data, segment movement windows. Address discrepancy between
% movement onset cue and actual movement onset.

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
rawdir   = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_RAW_SYNCHRONIZED_EEG_FMRI_DATA');
movedir  = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_PROCESS_SYNCHRONIZED_EEG_FMRI_DATA','MOVEMENT_WINDOW');
basepath = fullfile(drive,'Dropbox','Research','Analysis','MATLAB FUNCTIONS');

% Add paths
addpath(genpath(fullfile(basepath,'Brainstorm','brainstorm3','toolbox')));
addpath(genpath(fullfile(basepath,'Custom MATLAB Functions')));
addpath(genpath(fullfile(basepath,'shoeeg')));
addpath(fullfile(basepath,'eeglab'));
eeglab;
close all;
clc;

% Clean up
clearvars -except drive datadir rawdir savedir basepath EEG movedir

% Get files for each subject
subs = {'TF01','TF02','TF03'};

% Get variable names
vars = who;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%              COMPUTE LAG           %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lag1 = cell(1,length(subs));
lag2 = cell(1,length(subs));

% Loop through each subject, concatenate, and process
for aa = 1:length(subs)
    
    % Get variables
    vars = who;
    
    % Get eeg files for each subject
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-eeg.mat'   ]));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-stim.mat'  ]));
    % Load movement data
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-angles.mat']));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-gonio.mat' ]));
    
    % Get trial information
    trialbreaks = EEG.trialbreaks;
    movetimes = cell(size(STIM,1),2);
    stimpattern = cell(size(STIM,1),1);
    movements = {'RK','RA'};
    %limb = 'RK';
    
    %     if loadAng
    %         n = length(movements);
    %     else
    %         n = 1;
    %     end
    %
    for aaa = 1%:length(movements)
        limb = movements{aaa};
        
        for bb = 1:size(STIM,1)
            
            % Get movement times from STIM
            rk_idx      = find(strcmpi(STIM(bb).states,limb)); % Get movements of right knee
            rk_onset    = STIM(bb).initialDelay + STIM(bb).onsets(rk_idx); % seconds
            rk_duration = STIM(bb).Duration(rk_idx); % seconds
            rk_time     = [rk_onset; rk_onset + rk_duration]'; % seconds [onset, offset]
            rk_samples  = floor(rk_time .* EEG.srate); % sample points
            
            % Store movement times
            movetimes{bb,1} = find(EEG.trialbreaks==bb);
            movetimes{bb,2} = rk_samples;
            
            %         if loadAng
            %             % Angle data
%             try
%                 movedata =  ANGLES(bb).data(aaa,:);
%                 %         else
%                 % Get gonio data
%             catch err
%                 disp(err.message)
%                 try
                    movedata = GONIO(bb).data(aaa,:);
%                 catch err2
%                     disp(err2.message)
%                     continue
%                 end
%             end
            %         end
            % Get EMG data
            %         emgdata   = EMG(bb).data(3,:);
            %         filtdata  = filterdata('data',emgdata','srate',EEG.srate,...
            %             'highpass',25,'highorder',2,...
            %             'visualize','off');
            %         %'lowpass','200','loworder',2,...
            %
            %         filtdata2  = filterdata('data',abs(filtdata).^2,'srate',EEG.srate,...
            %             'lowpass',1,'loworder',2,...
            %             'visualize','off');
            
            % Create movement
            stimtime = ones(1,length(find(EEG.trialbreaks==bb)));
            numCycles = 6;   % number of cycles
            move_freq = .5; % speed of moving dot in hz
            stimpattern{bb} = cell(size(rk_onset)); % for storing prescribed pattern
            window_buffer = 3*EEG.srate; % 1 second shift TO ACCOUNT FOR ONSET ERROR
            for cc = 1:length(rk_onset)
                % Create movement pattern vector
                timevec = 0:1/EEG.srate:rk_duration(cc); % time vector
                sinwave = cos(move_freq*2*pi*timevec); % create sinwave
                dsinwave = diff([0 sinwave]); % velocity of wave
                stimpattern{bb}{cc} = [sinwave; dsinwave];
                
                % Store stim time
                stimtime(rk_samples(cc,1):rk_samples(cc,2)) = sinwave;
                
                % Run xcorr for this window - add buffer to account for full
                % movement
                temp_time = rk_samples(cc,1)-window_buffer:rk_samples(cc,2)+window_buffer;
                [xcvalue,xclag] = xcorr(zscore(stimtime(temp_time)),zscore(movedata(temp_time)));
                %             [xcvalue,xclag] = xcorr(zscore(goniodata(temp_time)),zscore(stimtime(temp_time)));
                [~,maxIDX]      = max(xcvalue);
                IDXshift        = xclag(maxIDX);
                lag1{aaa,aa}    = [lag1{aaa,aa},IDXshift]; clear IDXshift
            end % cc = 1:length(rk_onset)
            
            % Run xcorr for full trial
            %         [xcvalue,xclag] = xcorr(zscore(abs(stimtime-1)),zscore(filtdata2));
            [xcvalue,xclag] = xcorr(zscore(stimtime),zscore(movedata));
            [~,maxIDX]      = max(xcvalue);
            IDXshift        = xclag(maxIDX);
            lag2{aaa,aa}    = [lag2{aaa,aa}, IDXshift]; clear IDXshift
            
        end % bb = 1:size(STIM,1)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%        SEGMENT MOVE WINDOW         %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop through each subject, concatenate, and process
for aa = 1:length(subs)
    
    % Get variables
    vars = who;
    
    % Get eeg files for each subject
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-eeg.mat'   ]));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-emg.mat'   ]));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-stim.mat'  ]));
    % Load movement data
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-angles.mat']));
    load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-gonio.mat' ]));
    
    % Get trial information
    trialbreaks = EEG.trialbreaks;
    movetimes = cell(size(STIM,1),2);
    stimpattern = cell(size(STIM,1),1);
    movements = {'RK','RA','LK','LA'};
   
    for aaa = 1:length(movements)
        limb = movements{aaa};
        
        for bb = 1:size(STIM,1)
            
            % Get movement times from STIM
            rk_idx      = find(strcmpi(STIM(bb).states,limb)); % Get movements of right knee
            rk_onset    = STIM(bb).initialDelay + STIM(bb).onsets(rk_idx); % seconds
            rk_duration = STIM(bb).Duration(rk_idx); % seconds
            rk_time     = [rk_onset; rk_onset + rk_duration]'; % seconds [onset, offset]
            rk_samples  = floor(rk_time .* EEG.srate); % sample points
            
            % Store movement times
            movetimes{bb,1} = find(EEG.trialbreaks==bb);
            movetimes{bb,2} = rk_samples;
            
            % Get gonio and EMG data
            try
                movedata = GONIO(bb).data(aaa,:);
                usegon   = 1;
            catch err
                usegon   = 0;
                disp(err.message)
            end
            muscledata = EMG(bb).data;s
            
            % Create movement
            stimtime        = ones(1,length(find(EEG.trialbreaks==bb)));
            numCycles       = 6;   % number of cycles
            move_fresq       = .5; % speed of moving dot in hz
            stimpattern{bb} = cell(size(rk_onset)); % for storing prescribed pattern
            window_buffer   = 2*EEG.srate; % 1 second shift TO ACCOUNT FOR ONSET ERROR
            for cc = 1:length(rk_onset)
                tstart    = rk_samples(cc,1)-window_buffer;
                tstop     = rk_samples(cc,1)+(12*EEG.srate)- 1/EEG.srate + window_buffer;
                temp_time = (tstart:tstop) + mean(lag2{aa});
                eegdata   = EEG.data(:,temp_time);
                emgdata   = muscledata(:,temp_time);
                savefile(eegdata  , 'EEG'  , movedir,[subs{aa} '-T0' num2str(bb) '-' movements{aaa} num2str(cc) '-eeg.mat'  ]); 
                savefile(emgdata  , 'GONIO', movedir,[subs{aa} '-T0' num2str(bb) '-' movements{aaa} num2str(cc) '-emg.mat'  ]); 
                if usegon
                    goniodata = movedata(:,temp_time);
                    savefile(goniodata, 'EMG'  , movedir,[subs{aa} '-T0' num2str(bb) '-' movements{aaa} num2str(cc) '-gonio.mat']); 
                end
            end % cc = 1:length(rk_onset)
        end % bb = 1:size(STIM,1)
    end
end




