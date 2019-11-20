

close all;
clear;
clc;

% Define directory
thisdir = pwd;
idcs = strfind(pwd,filesep);
parentdir = thisdir(1:idcs(end-2));
addpath(genpath(fullfile(parentdir)));

% Define drive
if strcmpi(getenv('username'),'justi')% WHICHPC == 1
    drive = 'D:';
elseif strcmpi(getenv('username'),'jabrantl') %WHICHPC == 2
    drive = 'E:';
elseif strcmpi(computer,'MACI64') % macbook
    drive = '/Volumes/STORAGE/';
end

% Get channel locations
allchanlocs = readlocs([drive,'\Dropbox\Research\Data\UH-NEUROLEG\EEG Montage & Location Files\1020_64chan_Brainvision_EarGndRef.ced']);
allchanlocs([17,22,28,32]) = [];

% Get current directory
thisdir = cd;
fullfile(cd,'OFFLINERESULTS')

% Subject names
subjects = {'TF01','TF02','TF03'};
movements = {'RK','RA','LK','LA'};
whichbands = {
% Colors
clr = flipud(lbmap(100,'brownblue'));
bcs = blindcolors;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                         PLOT GONIO DECODING                             %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Try with brainstorm clean
all_sub_rval_BS =  cell(length(subjects),1);
% Get variables
vars = who;
for aa = 1:length(subjects) % number of subjects
    load([subjects{aa} '_KF_RESULTS_GONIO_EachChanBSClean_RK_WIN50_Z1_CAR1_AUG1_UKF1'])
    all_rval = zeros(length(BANDS),length(montages));
    for bb = 1:size(predicted_sub,1)
        for cc = 1:size(predicted_sub,2)
            all_rval(bb,cc) = PearsonCorr(predicted_sub{bb,cc}(1,:),predicted_sub{bb,cc}(2,:));
            %all_rval(bb,cc) = R2_sub_mean{bb,cc};
        end % bb
    end % cc
    all_sub_rval_BS{aa} = all_rval;
end % aa
% Clean up
keepvars(vars);

% Make figures for decoding results on topoplot
figure('color','w','units','inches','position',[5 2 6.5 6.5]);
ax = tight_subplot(length(subjects),size(all_sub_rval_BS{1},1));%,[],[],[]);
axnum = 1:length(subjects)*size(all_sub_rval_BS{1},1);
cnt = 1;
for aa = 1:length(subjects)
   % Load channel locations
   load([drive '\Dropbox\Research\Data\UH-NEUROLEG\_RAW_SYNCHRONIZED_EEG_FMRI_DATA\' subjects{aa} '-chanlocs.mat']);
   for bb = 1:size(all_sub_rval_BS{aa},1)
       axes(ax(axnum(cnt)));
       topoplot(all_sub_rval_BS{aa}(bb,:),chanlocs,'electrodes','on','style','map','conv','on');
       c = colorbar;
%        c.Limits = [floor(min(all_sub_rval_BS{aa}(bb,:))), 1];
       c.Location = 'NorthOutSide';
       cnt = cnt + 1;
   end
end

% Try with realtime clean
all_sub_rval_RT =  cell(length(subjects),1);
% Get variables
vars = who;
for aa = 1:length(subjects) % number of subjects
    load([subjects{aa} '_KF_RESULTS_GONIO_EachChanRTClean_RK_WIN50_Z1_CAR1_AUG1_UKF1'])
    all_rval = zeros(length(BANDS),length(montages));
    for bb = 1:size(predicted_sub,1)
        for cc = 1:size(predicted_sub,2)
            all_rval(bb,cc) = PearsonCorr(predicted_sub{bb,cc}(1,:),predicted_sub{bb,cc}(2,:));
        end % bb
    end % cc
    all_sub_rval_RT{aa} = all_rval;
end % aa
% Clean up
keepvars(vars);

% Make figures for decoding results on topoplot
figure('color','w','units','inches','position',[5 2 6.5 6.5]);
ax = tight_subplot(length(subjects),size(all_sub_rval_RT{1},1));%,[],[],[]);
axnum = 1:length(subjects)*size(all_sub_rval_RT{1},1);
cnt = 1;
for aa = 1:length(subjects)
   % Load channel locations
   load([drive '\Dropbox\Research\Data\UH-NEUROLEG\_RAW_SYNCHRONIZED_EEG_FMRI_DATA\' subjects{aa} '-chanlocs.mat']);
   for bb = 1:size(all_sub_rval_RT{aa},1)
       axes(ax(axnum(cnt)));
       topoplot(all_sub_rval_RT{aa}(bb,:),chanlocs,'electrodes','on','style','map');
       c = colorbar;
       c.Limits = [floor(min(all_sub_rval_RT{aa}(bb,:))), 1];
       c.Location = 'NorthOutSide';
       cnt = cnt + 1;
   end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                        PLOT TARGET DECODING                             %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Try with brainstorm clean
all_sub_rval_BS =  cell(length(subjects),1);
% Get variables
vars = who;
for aa = 1:length(subjects) % number of subjects
    sub_rval = cell(length(movements),1);
    for bb = 1:length(movements)
        load([subjects{aa} '_KF_RESULTS_TARGET_EachChanBSClean_' movements{bb} '_WIN50_Z1_CAR1_AUG1_UKF1.mat'])
        move_rval = zeros(length(BANDS),length(montages));
        for cc = 1:size(predicted_sub,1)
            for dd = 1:size(predicted_sub,2)
%                 move_rval(cc,dd) = PearsonCorr(predicted_sub{cc,dd}(1,:),predicted_sub{cc,dd}(2,:));
                move_rval(cc,dd) = KalmanFilter.rsquared(predicted_sub{cc,dd}(1,:),predicted_sub{cc,dd}(2,:));% R2_sub_mean{cc,dd};
            end
        end % cc
        sub_rval{bb} = move_rval;
    end% bb
    all_sub_rval_BS{aa} = sub_rval;
end % aa
% Clean up
keepvars(vars);


for aa = 1:length(subjects)
    % Load channel locations
    load([drive '\Dropbox\Research\Data\UH-NEUROLEG\_RAW_SYNCHRONIZED_EEG_FMRI_DATA\' subjects{aa} '-chanlocs.mat']);
    % Make figures for decoding results on topoplot
    figure('color','w','units','inches','position',[5 2 6.5 6.5]);
    ax = tight_subplot(size(all_sub_rval_BS{aa},1),size(all_sub_rval_BS{aa}{1},1));%,[],[],[]);
    axnum = 1:size(all_sub_rval_BS{aa},1)*size(all_sub_rval_BS{aa}{1},1);
    cnt = 1;
    for bb = 1:size(all_sub_rval_BS{aa},1)
        for cc = 1:size(all_sub_rval_BS{aa}{bb},1)
            axes(ax(axnum(cnt)));
            topoplot(all_sub_rval_BS{aa}{bb}(cc,:),chanlocs,'electrodes','on','style','map');
            c = colorbar;
            %maxval = max(abs([round(min(all_sub_rval_BS{aa}{bb}(cc,:)),2) round(max(all_sub_rval_BS{aa}{bb}(cc,:)),2)]))
            %c.Limits = [-maxval maxval];
            c.Limits = [min(all_sub_rval_BS{aa}{bb}(cc,:)) max(all_sub_rval_BS{aa}{bb}(cc,:))];
            c.Location = 'NorthOutSide';
            cnt = cnt + 1;
        end
    end
end


% Try with brainstorm clean
all_sub_rval_RT =  cell(length(subjects),1);
% Get variables
vars = who;
for aa = 1:length(subjects) % number of subjects
    sub_rval = cell(length(movements),1);
    for bb = 1:length(movements)
        load([subjects{aa} '_KF_RESULTS_TARGET_EachChanRTClean_' movements{bb} '_WIN50_Z1_CAR1_AUG1_UKF1.mat'])
        move_rval = zeros(length(BANDS),length(montages));
        for cc = 1:size(predicted_sub,1)
            for dd = 1:size(predicted_sub,2)
%                 move_rval(cc,dd) = PearsonCorr(predicted_sub{cc,dd}(1,:),predicted_sub{cc,dd}(2,:));
                all_rval(bb,cc) = R2_sub_mean{bb,cc};
            end
        end % cc
        sub_rval{bb} = move_rval;
    end% bb
    all_sub_rval_RT{aa} = sub_rval;
end % aa
% Clean up
keepvars(vars);


for aa = 1:length(subjects)
    % Load channel locations
    load([drive '\Dropbox\Research\Data\UH-NEUROLEG\_RAW_SYNCHRONIZED_EEG_FMRI_DATA\' subjects{aa} '-chanlocs.mat']);
    % Make figures for decoding results on topoplot
    figure('color','w','units','inches','position',[5 2 6.5 6.5]);
    ax = tight_subplot(size(all_sub_rval_RT{aa},1),size(all_sub_rval_RT{aa}{1},1));%,[],[],[]);
    axnum = 1:size(all_sub_rval_RT{aa},1)*size(all_sub_rval_RT{aa}{1},1);
    cnt = 1;
    for bb = 1:size(all_sub_rval_BS{aa},1)
        for cc = 1:size(all_sub_rval_RT{aa}{bb},1)
            axes(ax(axnum(cnt)));
            topoplot(all_sub_rval_RT{aa}{bb}(cc,:),chanlocs,'electrodes','on','style','map');
            c = colorbar;
            maxval = max(abs([round(min(all_sub_rval_RT{aa}{bb}(cc,:)),2) round(max(all_sub_rval_RT{aa}{bb}(cc,:)),2)]))
            c.Limits = [-maxval maxval];
            c.Location = 'NorthOutSide';
            cnt = cnt + 1;
        end
    end
end
