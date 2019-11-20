% Make band power topoplots

close all;
clear all;
clc;

% Define drive
if strcmpi(getenv('username'),'justi')% WHICHPC == 1
    drive = 'D';
elseif strcmpi(getenv('username'),'jabrantl') %WHICHPC == 2
    drive = 'E';
end

% Add paths
basepath = [drive ':\Dropbox\Research\Analysis\MATLAB FUNCTIONS'];
addpath(genpath(fullfile(basepath,'Custom MATLAB Functions')));
addpath(fullfile(basepath,'eeglab'));
eeglab;
close all;
clc;

% Get channel locations
allchanlocs = readlocs([drive,':\Dropbox\Research\Data\UH-NEUROLEG\EEG Montage & Location Files\1020_64chan_Brainvision_EarGndRef.ced']);
allchanlocs([17,22,28,32]) = [];

% Load data
load('AllSub_PSDs.mat')

%% Define frequency bands
basenorm = 1;
handnorm = 0;
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

% Loop through subjects
allpsd = cell(length(AllSub_PSDs));
for aa = 1:length(AllSub_PSDs)
    allmove_psd = cell(size(AllSub_PSDs{aa},1),1);
    % Loop through each movement
    for bb = 1:size(AllSub_PSDs{aa},1)
        thismove_psd = zeros(size(AllSub_PSDs{aa}{bb},1),length(BANDS));
        % Loop throuh each channel
        for cc = 1:size(AllSub_PSDs{aa}{bb},1)
            % Loop through each frequency
            for dd = 1:length(BANDS)
                % Get mean power in band across all psds
                temp = zeros(1,size(AllSub_PSDs{aa}{bb}{cc},2));
                for ee = 1:size(AllSub_PSDs{aa}{bb}{cc},2)
                    temp(ee) = bandpower(AllSub_PSDs{aa}{bb}{cc}(:,ee),nfft(:),BANDS{dd},'psd');
                end
                %temp = mean(temp);
                temp = 10.*log10(median(temp));
                % Normalize to baseline
                if basenorm
                    if handnorm
                        temp2 = zeros(1,size(AllSub_PSDs{aa}{1}{cc},2));
                        for ee = 1:size(AllSub_PSDs{aa}{1}{cc},2)
                            temp2(ee) = bandpower(AllSub_PSDs{aa}{1}{cc}(:,ee),nfft(:),BANDS{dd},'psd');
                        end
                        %temp = mean(temp);
                        temp2 = 10.*log10(median(temp2));
                        temp = temp - temp2;
                    else
                        %temp = (temp-bandpower(AllBasePSDs{aa}(:,cc),nfft,BANDS{dd},'psd'))/bandpower(AllBasePSDs{aa}(:,cc),nfft,BANDS{dd},'psd');
                        temp = temp - 10.*log10(bandpower(AllBasePSDs{aa}(:,cc),nfft,BANDS{dd},'psd'));
                    end
                    
                end
                % Store value
                thismove_psd(cc,dd) = temp;
            end
        end
        allmove_psd{bb} = thismove_psd;
    end % bb
    allpsd{aa} = allmove_psd;
end % aa

%% Make figures

clr = flipud(lbmap(100,'brownblue'));
bcs = blindcolors;
% clrs = [bcs(4,:); bcs(8,:); bcs(6,:)];
%colormap(clr);
% Each subject
for aa = 3%:length(allpsd)
    
    % Load channel locations
    load([drive ':\Dropbox\Research\Data\UH-NEUROLEG\_RAW_SYNCHRONIZED_EEG_FMRI_DATA\TF0' num2str(aa) '-chanlocs.mat']);
    
    figure('color','w','units','inches','position',[5 2 6.5 6.5]);
    ax = tight_subplot(size(allpsd{aa},1),length(BANDS));%,[],[],[]);
    % Each movement
    axnum = reshape(1:length(allpsd{aa})*length(BANDS),length(allpsd{aa}),length(BANDS));
    axnum = axnum';
    axnum = axnum(:);
    cnt = 1;
    for bb = 1:length(allpsd{aa})
        % Each band
        for cc = 1:length(BANDS)
            axes(ax(axnum(cnt)));
            topoplot(allpsd{aa}{bb}(:,cc),chanlocs,'electrodes','on');
            colorbar;
            cnt = cnt+1;
        end
    end
end

colormap(clr);
