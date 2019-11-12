close all
figure; ax1 = tight_subplot(3,3);
figure; ax2 = tight_subplot(3,3);
mdl = [];
for ii = 1:length(predicted_sub)
axes(ax1(ii)); scatter(predicted_sub{ii}(1,:),predicted_sub{ii}(2,:));
%X = [ones(length(predicted_sub{ii}(1,:)),1) predicted_sub{ii}(1,:)'];
X = predicted_sub{ii}(1,:)';
Y = predicted_sub{ii}(2,:)';
b = X\Y;
hold on; plot(predicted_sub{ii}(1,:), X*b);
mdl{ii} = b;
axes(ax2(ii)); plot(predicted_sub{ii}(2,:)); hold on; plot(predicted_sub{ii}(1,:));
plot(X*b);
legend({'Actual Knee Angle','Predicted Knee Angle','Corrected Knee Angle'})
end
 
 
figure; ax3 = tight_subplot(3,3);
for ii = 1:length(predicted_sub)
axes(ax3(ii));histogram(predicted_sub{ii}(2,:)); hold on; histogram(predicted_sub{ii}(1,:));
legend({'Actual Knee Angle','Predicted Knee Angle'})
end


