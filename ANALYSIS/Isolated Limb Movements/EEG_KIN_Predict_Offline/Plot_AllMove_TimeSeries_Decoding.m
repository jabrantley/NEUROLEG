
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
%bandnames = {'\delta ','\theta ','\alpha ','\beta ','\gamma ','\delta - \gamma ', '\theta - \gamma '};
bcs = blindcolors;
clrs = [bcs(4,:); bcs(8,:); bcs(6,:)];
vars = who;

% Make plot of all movements
%%

limb = {'RK','RA','LK','LA','BH'};
limbname = {'RK_{gonio}','RK_{target}','RA_{target}','LK_{target}','LA_{target}','BH_{target}'}
method = {'RR','KF','UKF'};
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
    ff = figure('color','w','units','inches','position',[6 2 6.5 6.5]);
    ax = tight_subplot(6,3,[.05 .025],[.05 .05],[.1 .01]);
    temp = reshape(1:6*3,3,6);%';
    axord = 1:length(ax);%temp(:);
    cnt = 1;
    for bb = 1:size(x0,1)
        for cc = 1:size(x0,2)
            x = x0{bb,cc}.predicted_sub{1};
            
            axes(ax(axord(cnt)));
            p1 = plot(zscore(x(2,:)),'linewidth',1.5);
            p1.Color = 0.5.*ones(3,1);
            hold on;
            p2 = plot(zscore(x(1,:)),'linewidth',1.5);
            p2.Color = bcs(6,:);%
            %         p3 = plot(x2{ii}(1,:),'linewidth',1.5);
            %         p3.Color = clrs(3,:);%bcs(6,:);%
            ax(axord(cnt)).XTickLabel = '';
            ax(axord(cnt)).YTickLabel = '';
            r1 = KalmanFilter.PearsonCorr(x(2,:),x(1,:));
            r2 = KalmanFilter.rsquared(x(2,:),x(1,:));
            ax(axord(cnt)).XLabel.String = ['R^2: ' num2str(round(r2,2)) ';  r-value: ' num2str(round(r1,2))];
            ax(axord(cnt)).XLabel.FontSize = 9;
            %xlabel(['R^2: ' num2str(round(r2,2)) ';  r-value: ' num2str(round(r1,2))])
            
            minval = min([zscore(x(2,:)),zscore(x(1,:))]);
            maxval = max([zscore(x(2,:)),zscore(x(1,:))]);
            maxmax = max(abs([minval maxval]));
            ax(axord(cnt)).YLim = [-maxmax maxmax];
            
            if any(axord(cnt)==(temp(:,1)))%(temp(1,:)))
                idx = find(axord(cnt)==(temp(1,:)));
                title(method{cc})%subjects{idx});
            end
            
            if any(axord(cnt)==(temp(1,:)))%(temp(:,1)))
                %idx2 = find(axord(cnt)==(temp(:,1)));
                ax(axord(cnt)).YLabel.String = limbname{bb};
                ax(axord(cnt)).YLabel.FontWeight = 'b';
                ax(axord(cnt)).YLabel.Rotation = 0;
                ax(axord(cnt)).YLabel.HorizontalAlignment = 'right';
                ax(axord(cnt)).YLabel.VerticalAlignment = 'middle';
            end
            
            %         ax(axord(cnt)).XColor = 'w';
            %         ax(axord(cnt)).YColor = 'w';
            %         axtemp = axes;
            axtemp = axes;
            axtemp.Position = ax(axord(cnt)).Position;
            axtemp.XTick = [];
            axtemp.YTick = [];
            axtemp.XColor = 'w';
            axtemp.YColor = 'w';
            axtemp.Color = 'none';
            ax(axord(cnt)).Box = 'off';
            
            
            cnt = cnt+1;
            
        end
    end
    flname = [subjects{aa} '_ALLMOVE_ALLMETHOD_TIMESERIES.png'];
    export_fig(flname,'-png','-r300');
end