function fig = build_movement_fig(sinewave)

% Time constant
Tau = sinewave.cycles*(1/sinewave.freq);

% Build figure
f  = figure('color','w'); 
f.Position = [962, 42, 958, 954];
%f = figure('color','w','units','inches','position',[-16.5 1.5 15.5 7.5]);

% Top axes
ax = gca; ax.Position = [.1 .55 .85 .4]; ax.Box = 'on';
p  = plot(sinewave.wave,sinewave.wave,'linewidth',2); hold on;
s  = scatter(0,0,125,'filled');

% Bottom axes
ax1 = axes; ax1.Position = [.1 .05 .85 .4]; ax1.Box = 'on';
p1  = plot(sinewave.time,sinewave.wave/max(sinewave.wave),'linewidth',2); hold on;
s1  = scatter(sinewave.time(1),sinewave.wave(1)/max(sinewave.wave),125,'filled');
xlim([sinewave.delay-.5, Tau + sinewave.delay + .5]);
% Store figure params
fig = struct('f',f,'p',p,'s',s,'p1',p1,'s1',s1);

end