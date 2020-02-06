% Plot all movements

close all;
clear all;
clc;

% Define drive
if strcmpi(getenv('username'),'justi')% WHICHPC == 1
    drive = 'D';
elseif strcmpi(getenv('username'),'jabrantl') %WHICHPC == 2
    drive = 'E';
end

datadir = [drive ':\Dropbox\Research\Analysis\NEUROLEG\ANALYSIS\Isolated Limb Movements\EEG_KIN_Predict_Offline\OFFLINERESULTS'];
subjects = {'TF01','TF02','TF03'};
bandnames = {'\delta ','\theta ','\alpha ','\beta ','\gamma ','\delta - \gamma ', '\theta - \gamma '};
bcs = blindcolors;
clrs = [bcs(4,:); bcs(8,:); bcs(6,:)];
vars = who;

%% Make box plot for RK grouped by method for each band
% r1_allsub = cell(length(subjects),1);
% r2_allsub = cell(length(subjects),1);
% 
% 
% for aa = 1:length(subjects)
%     % Get data
%     kf  = load(fullfile(datadir,[subjects{aa} '_KF_RESULTS_MOTORCHAN_GONIO_RK_WIN25_Z1_CAR1_AUG0_UKF0_V1.mat']));
%     ukf = load(fullfile(datadir,[subjects{aa} '_KF_RESULTS_MOTORCHAN_GONIO_RK_WIN25_Z1_CAR1_AUG0_UKF1_V1.mat']));
%     rr  = load(fullfile(datadir,[subjects{aa} '_RR_RESULTS_MOTORCHAN_GONIO_RK_WIN25_Z1_CAR1_V1.mat']));
% 
%     x0 = {rr,kf,ukf};
%     w = [1,2,3,4,5,6,9,10];
%     r1_band = cell(length(ukf.R1_sub_all),1);
%     r2_band = cell(length(ukf.R1_sub_all),1);
% 
%     for bb = 1:length(w)
%         %------------------------ R1 -----------------------%
%         allR1 = zeros(3,15);
%         for iter = 1:length(x0)
%             x = x0{iter};
%             if iter == 1
%                 allmed_r1 = [];
%                 combos_r1 = [];
%                 % Very inefficient but need to retain idx somehow
%                 for cc = 1:size(x.R1_sub_all{w(bb)},1)
%                     for dd = 1:size(x.R1_sub_all{w(bb)},2)
% 
%                         allmed_r1 = cat(1,allmed_r1,median(x.R1_sub_all{w(bb)}{cc,dd}(1,:)));
%                         combos_r1 = cat(1,combos_r1,[cc,dd]);
% 
%                     end
%                 end
%                 idxR1 = find(max(allmed_r1)==allmed_r1);
%                 r1_fold = x.R1_sub_all{w(bb)}{combos_r1(idxR1,1),combos_r1(idxR1,2)}(1,:);
%                 allR1(iter,:) = r1_fold;
%             else
%                 allmed_r1 = [];
%                 combos_r1 = [];
%                 % Very inefficient but need to retain idx somehow
%                 for cc = 1:size(x.R1_sub_all{w(bb)},1)
%                     for dd = 1:size(x.R1_sub_all{w(bb)},2)
%                         for ee = 1:size(x.R1_sub_all{w(bb)},3)
%                             for ff = 1:size(x.R1_sub_all{w(bb)},4)
%                                 allmed_r1 = cat(1,allmed_r1,median(x.R1_sub_all{w(bb)}{cc,dd,ee,ff}(1,:)));
%                                 combos_r1 = cat(1,combos_r1,[cc,dd,ee,ff]);
%                             end
%                         end
%                     end
%                 end
%                 idxR1 = find(max(allmed_r1)==allmed_r1);
%                 r1_fold = x.R1_sub_all{w(bb)}{combos_r1(idxR1,1),combos_r1(idxR1,2),combos_r1(idxR1,3),combos_r1(idxR1,4)}(1,:);
%                 allR1(iter,:) = r1_fold;
%             end
%         end
%         r1_band{bb} = allR1;
% 
%         %---------------------------- R2 -------------------------%
%         allR2 = zeros(3,15);
%         for iter = 1:length(x0)
%             x = x0{iter};
%             if iter == 1
%                 allmed_r2 = [];
%                 combos_R2 = [];
%                 % Very inefficient but need to retain idx somehow
%                 for cc = 1:size(x.R2_sub_all{w(bb)},1)
%                     for dd = 1:size(x.R2_sub_all{w(bb)},2)
% 
%                         allmed_r2 = cat(1,allmed_r2,median(x.R2_sub_all{w(bb)}{cc,dd}(1,:)));
%                         combos_R2 = cat(1,combos_R2,[cc,dd]);
% 
%                     end
%                 end
%                 idxR2 = find(max(allmed_r2)==allmed_r2);
%                 r2_fold = x.R2_sub_all{w(bb)}{combos_R2(idxR2,1),combos_R2(idxR2,2)}(1,:);
%                 allR2(iter,:) = r2_fold;
%             else
%                 allmed_r2 = [];
%                 combos_R2 = [];
%                 % Very inefficient but need to retain idx somehow
%                 for cc = 1:size(x.R2_sub_all{w(bb)},1)
%                     for dd = 1:size(x.R2_sub_all{w(bb)},2)
%                         for ee = 1:size(x.R2_sub_all{w(bb)},3)
%                             for ff = 1:size(x.R2_sub_all{w(bb)},4)
%                                 allmed_r2 = cat(1,allmed_r2,median(x.R2_sub_all{w(bb)}{cc,dd,ee,ff}(1,:)));
%                                 combos_R2 = cat(1,combos_R2,[cc,dd,ee,ff]);
%                             end
%                         end
%                     end
%                 end
%                 idxR2 = find(max(allmed_r2)==allmed_r2);
%                 r2_fold = x.R2_sub_all{w(bb)}{combos_R2(idxR2,1),combos_R2(idxR2,2),combos_R2(idxR2,3),combos_R2(idxR2,4)}(1,:);
%                 allR2(iter,:) = r2_fold;
%             end
%         end
%         r2_band{bb} = allR2;
%     end
% 
% %     figure('color','w','units','inches','position',[6,1,6.5 3]);
% %     ax1 = gca;
% %     aboxplot(cat(3,r1_band{:}),'labels',{'\delta ','\theta ','\alpha ','\beta ','\gamma_{low}','\gamma_{high}','\delta - \gamma ', '\theta - \gamma_{low} '},'colormap',clrs);
% %     ylabel('r-value')
% %     legend({'Ridge Regression','Kalman Filter','Unscented Kalman Filter'},'Location','NorthOutside','Box','off','Orientation','horizontal')
% %     flname= [subjects{aa} '-RK-rvalue.png'];
% %     export_fig(flname,'-png','-r300');
% % 
% %     figure('color','w','units','inches','position',[6,1,6.5 3]);
% %     ax2 = gca;
% %     aboxplot(cat(3,r2_band{:}),'labels',{'\delta ','\theta ','\alpha ','\beta ','\gamma_{low}','\gamma_{high}','\delta - \gamma ', '\theta - \gamma_{low} '},'colormap',clrs);
% %     ylabel('R^2')
% %     legend({'Ridge Regression','Kalman Filter','Unscented Kalman Filter'},'Location','NorthOutside','Box','off','Orientation','horizontal')
% %     flname2 = [subjects{aa} '-RK-rsquared.png'];
% %     export_fig(flname2,'-png','-r300');
%     
% 
%     ff = figure('color','w','units','inches','position',[6,1,6.5 6]);
%     ax = tight_subplot(2,1,[.05 05],[.05 .05],[.1 .01]);
%     axes(ax(1));
%     aboxplot(cat(3,r1_band{:}),'labels',{'','','','','','','',''},'colormap',clrs);
%     ylabel('r-value')
%     legend({'Ridge Regression','Kalman Filter','Unscented Kalman Filter'},'Location','NorthOutside','Box','off','Orientation','horizontal')
%     axes(ax(2));
%     aboxplot(cat(3,r2_band{:}),'labels',{'\delta ','\theta ','\alpha ','\beta ','\gamma_{low}','\gamma_{high}','\delta - \gamma ', '\theta - \gamma_{low} '},'colormap',clrs);
%     ylabel('R^2')
%     ax(2).Position(2) = .125;
%     ax(1).FontSize = 11;
%     ax(2).FontSize = 11;
%     ax(1).XLabel.FontSize = 14;
%     ax(2).XLabel.FontSize = 14;
%     drawnow;
%     ax(2).Position(4) = ax(1).Position(4);
%     %legend({'Ridge Regression','Kalman Filter','Unscented Kalman Filter'},'Location','NorthOutside','Box','off','Orientation','horizontal')
%     flname2 = [subjects{aa} '-RK-rsquared.png'];
%     export_fig(flname2,'-png','-r300');
%     
% end



%% Make box plot for RK grouped by method for each band
% r1_allsub = cell(length(subjects),1);
% r2_allsub = cell(length(subjects),1);
limb = {'RK','RA','LK','LA','BH'};

for aa = 1:length(subjects)
    % Get data
    kf  = load(fullfile(datadir,[subjects{aa} '_KF_RESULTS_MOTORCHAN_GONIO_RK_WIN25_Z1_CAR1_AUG0_UKF0_V1.mat']));
    ukf = load(fullfile(datadir,[subjects{aa} '_KF_RESULTS_MOTORCHAN_GONIO_RK_WIN25_Z1_CAR1_AUG0_UKF1_V1.mat']));
    rr  = load(fullfile(datadir,[subjects{aa} '_RR_RESULTS_MOTORCHAN_GONIO_RK_WIN25_Z1_CAR1_V1.mat']));
    x0 = {rr,kf,ukf};
    for bb = 1:length(limb)
        kf  = load(fullfile(datadir,[subjects{aa} '_KF_RESULTS_MOTORCHAN_TARGET_' limb{bb} '_WIN25_Z1_CAR1_AUG0_UKF0_V0.mat']));
        ukf = load(fullfile(datadir,[subjects{aa} '_KF_RESULTS_MOTORCHAN_TARGET_' limb{bb} '_WIN25_Z1_CAR1_AUG0_UKF1_V0.mat']));
        rr  = load(fullfile(datadir,[subjects{aa} '_RR_RESULTS_MOTORCHAN_TARGET_' limb{bb} '_WIN25_Z1_CAR1_V1.mat']));
        x0 = cat(1,x0,{rr,kf,ukf});
    end
    %------------------------ R1 -----------------------%
    r1_limb = cell(size(x0,1),1);
    r2_limb = cell(size(x0,1),1);
    for iter0 = 1:size(x0,1)
        allR1 = zeros(3,15);
        for iter1 = 1:size(x0,2)
            x = x0{iter0,iter1};
            if iter1 == 1
                allmed_r1 = [];
                combos_r1 = [];
                % Very inefficient but need to retain idx somehow
                for cc = 1:size(x.R1_sub_all{1},1)
                    for dd = 1:size(x.R1_sub_all{1},2)
                        
                        allmed_r1 = cat(1,allmed_r1,median(x.R1_sub_all{1}{cc,dd}(1,:)));
                        combos_r1 = cat(1,combos_r1,[cc,dd]);
                        
                    end
                end
                idxR1 = find(max(allmed_r1)==allmed_r1);
                r1_fold = x.R1_sub_all{1}{combos_r1(idxR1,1),combos_r1(idxR1,2)}(1,:);
                allR1(iter1,:) = r1_fold;
            else
                allmed_r1 = [];
                combos_r1 = [];
                % Very inefficient but need to retain idx somehow
                for cc = 1:size(x.R1_sub_all{1},1)
                    for dd = 1:size(x.R1_sub_all{1},2)
                        for ee = 1:size(x.R1_sub_all{1},3)
                            for ff = 1:size(x.R1_sub_all{1},4)
                                allmed_r1 = cat(1,allmed_r1,median(x.R1_sub_all{1}{cc,dd,ee,ff}(1,:)));
                                combos_r1 = cat(1,combos_r1,[cc,dd,ee,ff]);
                            end
                        end
                    end
                end
                idxR1 = find(max(allmed_r1)==allmed_r1);
                r1_fold = x.R1_sub_all{1}{combos_r1(idxR1,1),combos_r1(idxR1,2),combos_r1(idxR1,3),combos_r1(idxR1,4)}(1,:);
                allR1(iter1,:) = r1_fold;
            end
            r1_limb{iter0} = allR1;
        end
        %r1_band{bb} = allR1;
        
        %---------------------------- R2 -------------------------%
        allR2 = zeros(3,15);
        for iter1 = 1:length(x0)
            x = x0{iter0};
            if iter1 == 1
                allmed_r2 = [];
                combos_R2 = [];
                % Very inefficient but need to retain idx somehow
                for cc = 1:size(x.R2_sub_all{1},1)
                    for dd = 1:size(x.R2_sub_all{1},2)
                        
                        allmed_r2 = cat(1,allmed_r2,median(x.R2_sub_all{1}{cc,dd}(1,:)));
                        combos_R2 = cat(1,combos_R2,[cc,dd]);
                        
                    end
                end
                idxR2 = find(max(allmed_r2)==allmed_r2);
                r2_fold = x.R2_sub_all{1}{combos_R2(idxR2,1),combos_R2(idxR2,2)}(1,:);
                allR2(iter1,:) = r2_fold;
            else
                allmed_r2 = [];
                combos_R2 = [];
                % Very inefficient but need to retain idx somehow
                for cc = 1:size(x.R2_sub_all{1},1)
                    for dd = 1:size(x.R2_sub_all{1},2)
                        for ee = 1:size(x.R2_sub_all{1},3)
                            for ff = 1:size(x.R2_sub_all{1},4)
                                allmed_r2 = cat(1,allmed_r2,median(x.R2_sub_all{1}{cc,dd,ee,ff}(1,:)));
                                combos_R2 = cat(1,combos_R2,[cc,dd,ee,ff]);
                            end
                        end
                    end
                end
                idxR2 = find(max(allmed_r2)==allmed_r2);
                r2_fold = x.R2_sub_all{1}{combos_R2(idxR2,1),combos_R2(idxR2,2),combos_R2(idxR2,3),combos_R2(idxR2,4)}(1,:);
                allR2(iter1,:) = r2_fold;
            end
        end
        r2_limb{iter0} = allR1;
        %r2_band{bb} = allR2;
    end
    
%     figure('color','w','units','inches','position',[6,1,6.5 3]);
%     ax1 = gca;
%     aboxplot(cat(3,r1_limb{:}),'labels',{'RK_{gonio}','RK_{target}','RA_{target}','LK_{target}','LA_{target}','BH_{target}'},'colormap',clrs);
%     ylabel('r-value')
%     legend({'Ridge Regression','Kalman Filter','Unscented Kalman Filter'},'Location','NorthOutside','Box','off','Orientation','horizontal')
%     flname= [subjects{aa} '-ALLMOVE-rvalue.png'];
%     export_fig(flname,'-png','-r300');
%     
%     figure('color','w','units','inches','position',[6,1,6.5 3]);
%     ax2 = gca;
%     aboxplot(cat(3,r2_limb{:}),'labels',{'RK_{gonio}','RK_{target}','RA_{target}','LK_{target}','LA_{target}','BH_{target}'},'colormap',clrs);
%     ylabel('R^2')
%     legend({'Ridge Regression','Kalman Filter','Unscented Kalman Filter'},'Location','NorthOutside','Box','off','Orientation','horizontal')
%     flname2 = [subjects{aa} '-ALLMOVE-rsquared.png'];
%     export_fig(flname2,'-png','-r300');
    
    ff = figure('color','w','units','inches','position',[6,1,6.5 6]);
    ax = tight_subplot(2,1,[.05 05],[.05 .05],[.1 .01]);
    axes(ax(1));
    aboxplot(cat(3,r1_limb{:}),'labels',{'','','','','','','',''},'colormap',clrs);
    ylabel('r-value')
    legend({'Ridge Regression','Kalman Filter','Unscented Kalman Filter'},'Location','NorthOutside','Box','off','Orientation','horizontal')
    axes(ax(2));
    aboxplot(cat(3,r2_limb{:}),'labels',{'IK_{gonio}','IK_{target}','IA_{target}','PK_{target}','PA_{target}','BH_{target}'},'colormap',clrs);
    ylabel('R^2')
    ax(2).Position(2) = .125;
    ax(1).FontSize = 11;
    ax(2).FontSize = 11;
    ax(1).XLabel.FontSize = 14;
    ax(2).XLabel.FontSize = 14;
    drawnow;
    ax(2).Position(4) = ax(1).Position(4);
    %legend({'Ridge Regression','Kalman Filter','Unscented Kalman Filter'},'Location','NorthOutside','Box','off','Orientation','horizontal')
    flname2 = [subjects{aa} '-ALLMOVE-rsquared.png'];
    export_fig(flname2,'-png','-r300');
    
end






% %% Make box plot for
% r1_allsub = cell(length(subjects),1);
% r2_allsub = cell(length(subjects),1);
% for aa = 1:length(subjects)
%     % Get data
%     kf  = load(fullfile(datadir,[subjects{aa} '_KF_RESULTS_MOTORCHAN_GONIO_RK_WIN25_Z1_CAR1_AUG0_UKF0_V1.mat']));
%     ukf = load(fullfile(datadir,[subjects{aa} '_KF_RESULTS_MOTORCHAN_GONIO_RK_WIN25_Z1_CAR1_AUG0_UKF1_V1.mat']));
%     rr  = load(fullfile(datadir,[subjects{aa} '_RR_RESULTS_MOTORCHAN_GONIO_RK_WIN25_Z1_CAR1_V1.mat']));
%
%     x0 = {rr,kf,ukf};
%
%     %------------------------ R1 -----------------------%
%     allR1 = zeros(3,15);
%     for iter = 1:length(x0)
%         x = x0{iter};
%         if iter == 1
%             allmed_r1 = [];
%             combos_r1 = [];
%             % Very inefficient but need to retain idx somehow
%             for bb = 1:size(x.R1_sub_all,1)
%                 for cc = 1:size(x.R1_sub_all{bb},1)
%                     for dd = 1:size(x.R1_sub_all{bb},2)
%
%                         allmed_r1 = cat(1,allmed_r1,median(x.R1_sub_all{bb}{cc,dd}(1,:)));
%                         combos_r1 = cat(1,combos_r1,[bb,cc,dd]);
%
%                     end
%                 end
%             end
%             idxR1 = find(max(allmed_r1)==allmed_r1);
%             r1_fold = x.R1_sub_all{combos_r1(idxR1,1)}{combos_r1(idxR1,2),combos_r1(idxR1,3)}(1,:);
%             allR1(iter,:) = r1_fold;
%         else
%             allmed_r1 = [];
%             combos_r1 = [];
%             % Very inefficient but need to retain idx somehow
%             for bb = 1:size(x.R1_sub_all,1)
%                 for cc = 1:size(x.R1_sub_all{bb},1)
%                     for dd = 1:size(x.R1_sub_all{bb},2)
%                         for ee = 1:size(x.R1_sub_all{bb},3)
%                             for ff = 1:size(x.R1_sub_all{bb},4)
%                                 allmed_r1 = cat(1,allmed_r1,median(x.R1_sub_all{bb}{cc,dd,ee,ff}(1,:)));
%                                 combos_r1 = cat(1,combos_r1,[bb,cc,dd,ee,ff]);
%                             end
%                         end
%                     end
%                 end
%             end
%             idxR1 = find(max(allmed_r1)==allmed_r1);
%             r1_fold = x.R1_sub_all{combos_r1(idxR1,1)}{combos_r1(idxR1,2),combos_r1(idxR1,3),combos_r1(idxR1,4),combos_r1(idxR1,5)};
%             allR1(iter,:) = r1_fold;
%         end
%     end
%     r1_allsub{aa} = allR1;
%
%     %---------------------------- R2 -------------------------%
%      allR2 = zeros(3,15);
%     for iter = 1:length(x0)
%         x = x0{iter};
%         if iter == 1
%             allmed_r2 = [];
%             combos_R2 = [];
%             % Very inefficient but need to retain idx somehow
%             for bb = 1:size(x.R2_sub_all,1)
%                 for cc = 1:size(x.R2_sub_all{bb},1)
%                     for dd = 1:size(x.R2_sub_all{bb},2)
%
%                         allmed_r2 = cat(1,allmed_r2,median(x.R2_sub_all{bb}{cc,dd}(1,:)));
%                         combos_R2 = cat(1,combos_R2,[bb,cc,dd]);
%
%                     end
%                 end
%             end
%             idxR2 = find(max(allmed_r2)==allmed_r2);
%             r2_fold = x.R2_sub_all{combos_R2(idxR2,1)}{combos_R2(idxR2,2),combos_R2(idxR2,3)}(1,:);
%             allR2(iter,:) = r2_fold;
%         else
%             allmed_r2 = [];
%             combos_R2 = [];
%             % Very inefficient but need to retain idx somehow
%             for bb = 1:size(x.R2_sub_all,1)
%                 for cc = 1:size(x.R2_sub_all{bb},1)
%                     for dd = 1:size(x.R2_sub_all{bb},2)
%                         for ee = 1:size(x.R2_sub_all{bb},3)
%                             for ff = 1:size(x.R2_sub_all{bb},4)
%                                 allmed_r2 = cat(1,allmed_r2,median(x.R2_sub_all{bb}{cc,dd,ee,ff}(1,:)));
%                                 combos_R2 = cat(1,combos_R2,[bb,cc,dd,ee,ff]);
%                             end
%                         end
%                     end
%                 end
%             end
%             idxR2 = find(max(allmed_r2)==allmed_r2);
%             r2_fold = x.R2_sub_all{combos_R2(idxR2,1)}{combos_R2(idxR2,2),combos_R2(idxR2,3),combos_R2(idxR2,4),combos_R2(idxR2,5)};
%             allR2(iter,:) = r2_fold;
%         end
%     end
%     r2_allsub{aa} = allR2;
%
%
% %     x = kf.predicted_sub;
% % %     x2 = rr.predicted_sub;
% %     y = kf.combos;
% %     x(6:8) = [];
% %     y(6:8) = [];
% %     for ii  = 1:size(x)
% end
% %%
% figure('color','w','units','inches','position',[6,1,6.5 4]);
% subplot(2,1,1);
% ax1 = gca;
% aboxplot(cat(3,r1_allsub{:}),'labels',{'TF01','TF02','TF03'},'colormap',clrs);
%
% subplot(2,1,2);
% ax2 = gca;
% aboxplot(cat(3,r2_allsub{:}),'labels',{'TF01','TF02','TF03'},'colormap',clrs);

