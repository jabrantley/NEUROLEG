load('E:\Dropbox\Research\Analysis\NEUROLEG\analysis\Isolated Limb Movements\EEG_KIN_Predict_Offline\allPredict_50msWindow_FrontalChans.mat')

figure('color','w','units','inches','position',[5 2 6.5 2]);
p1 = plot(PREDICT_ALL{1}{3}(2,:));
hold on; 
p2 = plot(PREDICT_ALL{1}{3}(1,:));
ax = gca;

p1.Color = 'k';
p2.Color = bc(8,:);

p1.LineWidth = 1.85;
p2.LineWidth = 1.85;

ax.Position = [.01 .01 .98 .98];
ax.XColor = 'none';
ax.YColor = 'none';

alldata = PREDICT_ALL{1}{3}(:);

xlim([0 length(PREDICT_ALL{1}{3}(2,:))])
ylim([min(alldata) max(alldata)])

export_fig offlinePredictionUKF_deltaEEG.png -png -r300