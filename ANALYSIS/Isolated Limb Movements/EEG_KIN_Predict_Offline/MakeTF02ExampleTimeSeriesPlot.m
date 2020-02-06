
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
%%

ff = figure('color','w','units','inches','position',[6 2 6.5 6.5]);
ax = tight_subplot(4,1,[.1 .05],[.05 .05],[.1 .01]);
%temp = reshape(1:7*3,3,7)';
%axord = temp(:);
cnt = 1;

kf = load(fullfile(datadir,'TF02_KF_RESULTS_MOTORCHAN_GONIO_RK_WIN25_Z1_CAR1_AUG0_UKF1_V1.mat'));
% rr = load(fullfile(datadir,[subjects{aa} '_RR_RESULTS_MOTORCHAN_GONIO_RK_WIN25_Z1_CAR1_V1.mat']));
x = kf.predicted_sub;
%     x2 = rr.predicted_sub;
y = kf.combos;
x(6:8) = [];
y(6:8) = [];

toPlot = [1,2,length(x)-1,length(x)];
bandnames = {'\delta','\theta','\delta-\gamma','\theta-\gamma'};

for ii  = 1:length(toPlot)
    axes(ax(ii));
    p1 = plot(zscore(x{toPlot(ii)}(2,:)),'linewidth',1.5);
    p1.Color = 0.5.*ones(3,1);
    hold on;
    p2 = plot(zscore(x{toPlot(ii)}(1,:)),'linewidth',1.5);
    p2.Color = bcs(6,:);%clrs(aa,:);%bcs(6,:);%
    %         p3 = plot(x2{ii}(1,:),'linewidth',1.5);
    %         p3.Color = clrs(3,:);%bcs(6,:);%
    ax(ii).XTickLabel = '';
    ax(ii).XTick = '';
    ax(ii).YTickLabel = '';
    ax(ii).YTick = '';
    r1 = KalmanFilter.PearsonCorr(x{toPlot(ii)}(2,:),x{toPlot(ii)}(1,:));
    r2 = KalmanFilter.rsquared(x{toPlot(ii)}(2,:),x{toPlot(ii)}(1,:));
    ax(ii).XLabel.String = ['R^2: ' num2str(round(r2,2)) ';  r-value: ' num2str(round(r1,2))];
    ax(ii).XLabel.FontSize = 10;
    %xlabel(['R^2: ' num2str(round(r2,2)) ';  r-value: ' num2str(round(r1,2))])
    
    minval = min([zscore(x{toPlot(ii)}(2,:)),zscore(x{toPlot(ii)}(1,:))]);
    maxval = max([zscore(x{toPlot(ii)}(2,:)),zscore(x{toPlot(ii)}(1,:))]);
    maxmax = max(abs([minval maxval]));
    ax(ii).YLim = [1.1*minval 1.1*maxval];
    
    %     if any(ii==(temp(1,:)))
    %         idx = find(ii==(temp(1,:)));
    %         title(subjects{idx});
    %     end
    
    if ii == 1
        leg = legend([p1,p2],{'Actual','Predicted'},'Location','NorthOutside',...
            'Orientation','Horizontal','box','off');%,'FontSize','12');
        leg.FontSize = 10;
    else
        ax(ii).Position(4) = ax(1).Position(4);
    end
    
    ax(ii).YLabel.FontSize = 14;
    ax(ii).YLabel.Position(1) = -10;
    ax(ii).YLabel.String = bandnames{ii};
    ax(ii).YLabel.FontWeight = 'b';
    ax(ii).YLabel.Rotation = 0;
    ax(ii).YLabel.HorizontalAlignment = 'right';
    ax(ii).YLabel.VerticalAlignment = 'middle';
    
    axtemp = axes;
    axtemp.Position = ax(ii).Position;
    axtemp.XTick = [];
    axtemp.YTick = [];
    axtemp.XColor = 'w';
    axtemp.YColor = 'w';
    axtemp.Color = 'none';
    axtemp.YLim = [minval maxval];
    ax(ii).Box = 'off';
    
    cnt = cnt+1;
end

export_fig TF02_UKF_Examples.png -r300 -png

% axleg = axes;
% axleg.Position = [ax(1).Position(1), ax(1).Position(2)+ax(1).Position(4), ax(1).Position(3), .05];
% 
% p1 = plot(ones(1,10),'linewidth',1.5,'color',0.5.*ones(3,1));
% hold on;
% p2 = plot(1.1.*ones(1,10),'linewidth',1.5,'color',bcs(6,:));
% axleg.XColor = 'none';
% axleg.YColor = 'none';
% leg = legend([p1,p2],{'Actual','Predicted'},'Location','South','Orientation','Horizontal')
%export_fig AllSub_UKF_Gonio_allblue.png -r300 -png

%
% ff = figure('color','w','units','inches','position',[6 2 6.5 6.5]);
% ax = tight_subplot(7,3,[.05 .025],[.05 .05],[.1 .01]);
% temp = reshape(1:7*3,3,7)';
% axord = temp(:);
% cnt = 1;
% for aa = 1:3
%     kf = load(fullfile(datadir,[subjects{aa} '_KF_RESULTS_MOTORCHAN_GONIO_RK_WIN25_Z1_CAR1_AUG0_UKF1_V1.mat']));
% %     rr = load(fullfile(datadir,[subjects{aa} '_RR_RESULTS_MOTORCHAN_GONIO_RK_WIN25_Z1_CAR1_V1.mat']));
%
%     x = kf.predicted_sub;
% %     x2 = rr.predicted_sub;
%     y = kf.combos;
%     x(6:8) = [];
%     y(6:8) = [];
%     for ii  = 1:size(x)
%         axes(ax(axord(cnt)));
%         p1 = plot(zscore(x{ii}(2,:)),'linewidth',1.5);
%         p1.Color = 0.5.*ones(3,1);
%         hold on;
%         p2 = plot(zscore(x{ii}(1,:)),'linewidth',1.5);
%         p2.Color = bcs(6,:);%clrs(aa,:);%bcs(6,:);%
% %         p3 = plot(x2{ii}(1,:),'linewidth',1.5);
% %         p3.Color = clrs(3,:);%bcs(6,:);%
%         ax(axord(cnt)).XTickLabel = '';
%         ax(axord(cnt)).XTick = '';
%         ax(axord(cnt)).YTickLabel = '';
%         ax(axord(cnt)).YTick = '';
%         r1 = KalmanFilter.PearsonCorr(x{ii}(2,:),x{ii}(1,:));
%         r2 = KalmanFilter.rsquared(x{ii}(2,:),x{ii}(1,:));
%         ax(axord(cnt)).XLabel.String = ['R^2: ' num2str(round(r2,2)) ';  r-value: ' num2str(round(r1,2))];
%         %xlabel(['R^2: ' num2str(round(r2,2)) ';  r-value: ' num2str(round(r1,2))])
%
%         minval = min([zscore(x{ii}(2,:)),zscore(x{ii}(1,:))]);
%         maxval = max([zscore(x{ii}(2,:)),zscore(x{ii}(1,:))]);
%         ax(axord(cnt)).YLim = [minval maxval];
%
%         if any(axord(cnt)==(temp(1,:)))
%             idx = find(axord(cnt)==(temp(1,:)));
%             title(subjects{idx});
%         end
%
%         if any(axord(cnt)==(temp(:,1)))
%             idx2 = find(axord(cnt)==(temp(:,1)));
%             ax(axord(cnt)).YLabel.String = bandnames{idx2};
%             ax(axord(cnt)).YLabel.FontWeight = 'b';
%             ax(axord(cnt)).YLabel.Rotation = 0;
%             ax(axord(cnt)).YLabel.HorizontalAlignment = 'right';
%             ax(axord(cnt)).YLabel.VerticalAlignment = 'middle';
%         end
%
%         axtemp = axes;
%         axtemp.Position = ax(axord(cnt)).Position;
%         axtemp.XTick = [];
%         axtemp.YTick = [];
%         axtemp.XColor = 'w';
%         axtemp.YColor = 'w';
%         axtemp.Color = 'none';
%         ax(axord(cnt)).Box = 'off';
%
%         cnt = cnt+1;
%     end
% end
%
% export_fig AllSub_UKF_Gonio_allblue.png -r300 -png
%

