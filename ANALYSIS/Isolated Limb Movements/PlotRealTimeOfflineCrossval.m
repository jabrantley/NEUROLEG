% Plot offline results

close all;
clear;
clc;

% Run parallel for
onCluster   = 0;
runParallel = 0;

% Define directory
thisdir = pwd;
idcs = strfind(pwd,filesep);
parentdir = thisdir(1:idcs(end-1));
addpath(genpath(fullfile(parentdir)));

% Define drive
if strcmpi(getenv('username'),'justi')% WHICHPC == 1
    drive = 'D:';
elseif strcmpi(getenv('username'),'jabrantl') %WHICHPC == 2
    drive = 'E:';
elseif strcmpi(computer,'MACI64') % macbook
    drive = '/Volumes/STORAGE/';
end
% Define directories
datadir  = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','REALTIMECONTROL','TF01');
rawdir   = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_RAW_SYNCHRONIZED_EEG_FMRI_DATA');


load('RealTimeResults_CrossVal_UseWINEEG.mat')

r1_vals = nan(18,19);
r2_vals = nan(18,19);
%r1_vals = cell(1,18);
%r2_vals = cell(1,18);
for aa = 1:18
    
    allmed_r1 = [];
    combos_r1 = [];
    % Very inefficient but need to retain idx somehow
    for bb = 1:size(R1_ALL{aa},1)
        for cc = 1:size(R1_ALL{aa},2)
            for dd = 1:size(R1_ALL{aa},3)
                for ee = 1:size(R1_ALL{aa},4)
                    allmed_r1 = cat(1,allmed_r1,median(R1_ALL{aa}{bb,cc,dd,ee}));
                    combos_r1 = cat(1,combos_r1,[bb,cc,dd,ee]);
                end
            end
        end
    end
    idxR1 = find(max(allmed_r1)==allmed_r1);
    r1_fold = R1_ALL{aa}{combos_r1(idxR1,1),combos_r1(idxR1,2),combos_r1(idxR1,3),combos_r1(idxR1,4)};
    
    allmed_r2 = [];
    combos_r2 = [];
    % Very inefficient but need to retain idx somehow
    for bb = 1:size(R2_ALL{aa},1)
        for cc = 1:size(R2_ALL{aa},2)
            for dd = 1:size(R2_ALL{aa},3)
                for ee = 1:size(R2_ALL{aa},4)
                    allmed_r2 = cat(1,allmed_r2,median(R2_ALL{aa}{bb,cc,dd,ee}));
                    combos_r2 = cat(1,combos_r2,[bb,cc,dd,ee]);
                end
            end
        end
    end
    idxR2 = find(max(allmed_r2)==allmed_r2);
    r2_fold = R2_ALL{aa}{combos_r2(idxR2,1),combos_r2(idxR2,2),combos_r2(idxR2,3),combos_r2(idxR2,4)};
    
    % Store values for plotting
    r1_vals(aa,1:length(r1_fold)) = r1_fold;
    r2_vals(aa,1:length(r2_fold)) = r2_fold;
 
    
end
r1_vals = transpose(r1_vals);
r2_vals = transpose(r2_vals);
group = repmat(1:18,19,1);

%%
bc = blindcolors;
figure('color','w','units','inches','position',[5,5,6.5 5]); 
ax = tight_subplot(2,1,[.05 .05],[.1 .05],[.035 .025]);
% Plot R1 values
axes(ax(1));
p0 = plot(cat(2,R1_MEAN{:}),'color',0.5.*ones(3,1),'linewidth',2);
hold on; 
p1 = plot(cat(2,R1_MEAN{:}),'color',bc(4,:),'linewidth',2); 
bx1 = boxplot(r1_vals(:),group(:),'color',0.5.*ones(3,1),'PlotStyle','compact');
boxes = findall(ax(1),'Tag','Box');
legend([p0,p1],{'Train accuracy','Test accuracy'},'Box','off')
set(gca,'XTickLabel',{' '})
ylabel('r-value')
title('Pearson''s Correlation Coefficient vs. Number of Training Folds')
ax(1).YLim(2) =1;
axes(ax(2));
p3 = plot(cat(2,R2_MEAN{:}),'color',0.5.*ones(3,1),'linewidth',2); 
hold on;
p4 = plot(cat(2,R2_MEAN{:}),'color',bc(6,:),'linewidth',2); 
bx2 = boxplot(r2_vals(:),group(:),'color',0.5.*ones(3,1),'PlotStyle','compact');
boxes = findall(ax(2),'Tag','Box');
legend([p3,p4],{'Train accuracy','Test accuracy'},'Box','off')

ax(2).XTickLabel = sprintfc('%d',2:20);
ax(2).XTick = 1:19;
ax(2).YLim(2) =1;
xlabel('Number of Training Folds')
ylabel('R^2')
title('Coefficient of Determination vs. Number of Training Folds')
export_fig('OfflineCrossVal_RealTime_TF01.png','-png','-r300')

figure('color','w','units','inches','position',[5,5,3,2]);
ax2 = axes;
p21 =plot(zscore(PREDICT_ALL{3}(2,:)),'color',0.5.*ones(3,1),'linewidth',1.5); 
hold on; 
p22 = plot(zscore(PREDICT_ALL{3}(1,:)),'color',bc(3,:),'linewidth',1.5);
leg2 = legend([p21,p22],{'Target','Predicted'},'Location','northoutside','box','off',...
    'orientation','horizontal')

xlim([0 length(PREDICT_ALL{3}(1,:))])
ax2.XTick = [];
ax2.YTick = [];
ax2.Box = 'off';
ax2.XColor = 'w';
ax2.YColor = 'w';
export_fig('OfflineCrossVal_RealTime_TF01_example1.png','-png','-r300')


figure('color','w','units','inches','position',[5,5,3,2]);
ax3 = axes;
p31 =plot(zscore(PREDICT_ALL{15}(2,:)),'color',0.5.*ones(3,1),'linewidth',1.5); 
hold on; 
p32 = plot(zscore(PREDICT_ALL{15}(1,:)),'color',bc(8,:),'linewidth',1.5);
leg2 = legend([p31,p32],{'Target','Predicted'},'Location','northoutside','box','off',...
    'orientation','horizontal')

xlim([0 length(PREDICT_ALL{15}(1,:))])
ax3.XTick = [];
ax3.YTick = [];
ax3.Box = 'off';
ax3.XColor = 'w';
ax3.YColor = 'w';
export_fig('OfflineCrossVal_RealTime_TF01_example2.png','-png','-r300')
