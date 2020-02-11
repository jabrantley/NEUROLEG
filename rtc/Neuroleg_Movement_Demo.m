 function Neuroleg_Movements_Demo

% Clear the workspace
clc
clear;
close all;


%% Set Variables
useKneeData  = 1; % 1 = use knee angles, 0 = sinewave
write2teensy = 1;
UPDATE_RATE = 1/20;
JOINT_ANGLES = [1 60];

% Generate sine wave for following pattern
numCycles = 1;   % number of cycles
move_freq = .25; % speed of moving dot in hz
Tau = numCycles*(1/move_freq); % time constant

if useKneeData
    % Actual knee data
    load(fullfile(pwd,'demo_data','kneeAngles.mat'));
    sinwave = meanKneeLW;
    timevec = 1:length(sinwave);
else
    % Variable velocity - smoother and more natural
    timevec = 0:UPDATE_RATE:Tau; % time vector
    sinwave = (JOINT_ANGLES(2)/2) + (JOINT_ANGLES(2)/2)*cos(move_freq*2*pi*timevec+pi);
end


%% Setup serial object

% Delete any existing serial objects
if ~isempty(instrfind)
    fclose(instrfind);
end

% Open teensy connection
if write2teensy
    try
        teensy = serial('COM32','BaudRate',115200);
        fopen(teensy);
    catch err
        disp(err.message);
        fprintf(['\n-------------------------------',...
            '\n\n   Is the teensy plugged in? \n\n',...
            '-------------------------------\n'])
        return;
    end
end

%% Create movement pattern

% Generate figure for following moving dot
f = figure('color','w'); f.Units = 'normalized';
f.Position = [.075 .075 .825 .825];
ax = gca; ax.Box = 'on';
p = plot(timevec,sinwave,'color',0.5.*ones(1,3),'linewidth',2); hold on;
s = scatter(0,0,100,'filled','MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5);
ylabel('Joint Angle');

% Start control
StartButton = questdlg('Ready to start?','Movement Demo','Start','Stop','Stop');
switch StartButton
    case 'Start'
        % Write to teensy
        if write2teensy
            fprintf(teensy,'%.2f',JOINT_ANGLES(1))
            fprintf(teensy,'%s','\n')
        end
    otherwise
        close all;
        return;
end

% Initialize
fs = stoploop('Stop movement...');
count_direction = 'forward';
count           = 1;
start_time      = tic;
last_time        = toc(start_time);

% Now loop until button is pressed
while ~fs.Stop()
    if ge(toc(start_time) - last_time,UPDATE_RATE)
        % Get angle
        angle = sinwave(count);
        % Write to teensy
        if write2teensy
            %ang = 30;fprintf(teensy,'%.2f',ang); fprintf(teensy,'%s','\n')
            fprintf(teensy,'%.2f',angle)
            fprintf(teensy,'%s','\n')
        end
        % Update plot
        s.XData = timevec(count);
        s.YData = angle;
        % Store time
        last_time = toc(start_time);
        % Start over if end is reached
        count = count + 1;
        if count == length(timevec)
            count = 1;
        end
    end % end time check
end % end while ~fs.Stop()


if write2teensy
    fprintf(teensy,'%.2f',0)
    fprintf(teensy,'%s','\n')
    fclose(teensy);
end
close all;
% fs.Clear();

end