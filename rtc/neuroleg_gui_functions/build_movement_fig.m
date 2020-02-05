function fig = build_movement_fig(sinewave)

% Time constant
Tau = sinewave.cycles*(1/sinewave.freq);

% Build figure
%f  = figure('color','w'); 
% f.Position = [962, 42, 958, 954];
%f = figure('color','w','units','inches','position',[-16.5 1.5 15.5 7.5]);

f = figure('color','w','units','pixels','position',[-955 170 880 1502]);
f.Color = 0.9.*ones(1,3); %[136,139,141]./255;% UH grey
ButtonH = uicontrol('Style', 'PushButton', 'String', 'Close', ...
'Units', 'pixels', 'Callback', 'delete(gcbf)');
WindowAPI(f, 'position','full');
WindowAPI(f, 'clip');

% Create axis
ax = gca;
ax.Color = f.Color;
ax.Box = 'on';
ax.Position = [.1 .3 .8 .4];
p = line([0,0],[min(sinewave.wave), max(sinewave.wave)]);
p.Color = 'k';
p.LineWidth = 2;
hold on;
s = scatter(0,sinewave.wave(1),1000,'filled');
s.CData = [200, 16, 46]./255; % UH red
ax.YLim = [min(sinewave.wave)-5, max(sinewave.wave)+5];
ax.XLim = [-1 1];
ax.Color = f.Color;
ax.XColor = ax.Color;
ax.YColor = ax.Color;


s1 = scatter(0.2,sinewave.wave(1),500,'filled');
s1.CData = [246, 190, 0 ]./255; 
s1.Visible = 'off';
% % Top axes
% ax = gca; ax.Position = [.1 .55 .85 .4]; ax.Box = 'on';
% p  = plot(sinewave.wave,sinewave.wave,'linewidth',2); hold on;
% s  = scatter(0,0,125,'filled');
% 
% % Bottom axes
% ax1 = axes; ax1.Position = [.1 .05 .85 .4]; ax1.Box = 'on';
% p1  = plot(sinewave.time,sinewave.wave/max(sinewave.wave),'linewidth',2); hold on;
% s1  = scatter(sinewave.time(1),sinewave.wave(1)/max(sinewave.wave),125,'filled');
% xlim([sinewave.delay-.5, Tau + sinewave.delay + .5]);

% Store figure params
%fig = struct('f',f,'p',p,'s',s,'p1',p1,'s1',s1);
fig = struct('f',f,'p',p,'s',s,'s1',s1);

end