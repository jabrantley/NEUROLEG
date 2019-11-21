
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
%%
ff = figure('color','w','units','inches','position',[6 2 6.5 6.5]);
ax = tight_subplot(7,3,[.05 .025],[.05 .05],[.1 .01]);
temp = reshape(1:7*3,3,7)';
axord = temp(:);
cnt = 1;
for aa = 1:3
    load(fullfile(datadir,[subjects{aa} '_KF_RESULTS_MOTORCHAN_GONIO_RK_WIN25_Z1_CAR1_AUG1_UKF1.mat']))
    
    x = predicted_sub;
    y = combos;
    x(6:8) = [];
    y(6:8) = [];
    for ii  = 1:size(x)
        axes(ax(axord(cnt)));
        p1 = plot(x{ii}(2,:),'linewidth',1.5); 
        p1.Color = 0.5.*ones(3,1);
        hold on; 
        p2 = plot(x{ii}(1,:),'linewidth',1.5);
        p2.Color = clrs(aa,:);%bcs(6,:);%
        ax(axord(cnt)).XTickLabel = '';
        ax(axord(cnt)).YTickLabel = '';
        r1 = KalmanFilter.PearsonCorr(x{ii}(2,:),x{ii}(1,:));
        r2 = KalmanFilter.rsquared(x{ii}(2,:),x{ii}(1,:));
        ax(axord(cnt)).XLabel.String = ['R^2: ' num2str(round(r2,2)) ';  r-value: ' num2str(round(r1,2))];
        %xlabel(['R^2: ' num2str(round(r2,2)) ';  r-value: ' num2str(round(r1,2))])
        
        minval = min([x{ii}(2,:),x{ii}(1,:)]);
        maxval = max([x{ii}(2,:),x{ii}(1,:)]);
        ax(axord(cnt)).YLim = [minval maxval];
        
        if any(axord(cnt)==(temp(1,:)))
            idx = find(axord(cnt)==(temp(1,:)));
            title(subjects{idx});
        end
        
        if any(axord(cnt)==(temp(:,1)))
            idx2 = find(axord(cnt)==(temp(:,1)));
            ax(axord(cnt)).YLabel.String = bandnames{idx2};
            ax(axord(cnt)).YLabel.FontWeight = 'b';
            ax(axord(cnt)).YLabel.Rotation = 0;
            ax(axord(cnt)).YLabel.HorizontalAlignment = 'right';
            ax(axord(cnt)).YLabel.VerticalAlignment = 'middle';
        end
        cnt = cnt+1;
    end
end

 export_fig AllSub_UKF_Gonio.png -r300 -png
%%

ff = figure('color','w','units','inches','position',[6 2 6.5 6.5]);
ax = tight_subplot(7,3,[.05 .025],[.05 .05],[.1 .01]);
temp = reshape(1:7*3,3,7)';
axord = temp(:);
cnt = 1;
for aa = 1:3
    load(fullfile(datadir,[subjects{aa} '_KF_RESULTS_MOTORCHAN_GONIO_RK_WIN25_Z1_CAR1_AUG0_UKF0.mat']))
    
    x = predicted_sub;
    y = combos;
    x(6:8) = [];
    y(6:8) = [];
    for ii  = 1:size(x)
        axes(ax(axord(cnt)));
        p1 = plot(x{ii}(2,:),'linewidth',1.5); 
        p1.Color = 0.5.*ones(3,1);
        hold on; 
        p2 = plot(x{ii}(1,:),'linewidth',1.5);
        p2.Color = clrs(aa,:);%bcs(6,:);%
        ax(axord(cnt)).XTickLabel = '';
        ax(axord(cnt)).YTickLabel = '';
        r1 = KalmanFilter.PearsonCorr(x{ii}(2,:),x{ii}(1,:));
        r2 = KalmanFilter.rsquared(x{ii}(2,:),x{ii}(1,:));
        ax(axord(cnt)).XLabel.String = ['R^2: ' num2str(round(r2,2)) ';  r-value: ' num2str(round(r1,2))];
        %xlabel(['R^2: ' num2str(round(r2,2)) ';  r-value: ' num2str(round(r1,2))])
        
        if any(axord(cnt)==(temp(1,:)))
            idx = find(axord(cnt)==(temp(1,:)));
            title(subjects{idx});
        end
        
        if any(axord(cnt)==(temp(:,1)))
            idx2 = find(axord(cnt)==(temp(:,1)));
            ax(axord(cnt)).YLabel.String = bandnames{idx2};
            ax(axord(cnt)).YLabel.FontWeight = 'b';
            ax(axord(cnt)).YLabel.Rotation = 0;
            ax(axord(cnt)).YLabel.HorizontalAlignment = 'right';
            ax(axord(cnt)).YLabel.VerticalAlignment = 'middle';
        end
        cnt = cnt+1;
    end
end

 export_fig AllSub_KF_Gonio.png -r300 -png
