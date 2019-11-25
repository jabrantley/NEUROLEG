
close all;
clear;
clc;


% Define directory
thisdir = pwd;
idcs = strfind(pwd,filesep);
parentdir = thisdir(1:idcs(end-2));
addpath(genpath(fullfile(parentdir)));

% Define drive
if strcmpi(getenv('username'),'justi')% WHICHPC == 1
    drive = 'D:';
elseif strcmpi(getenv('username'),'jabrantl') %WHICHPC == 2
    drive = 'E:';
end

% Add paths
basepath = [drive '\Dropbox\Research\Analysis\MATLAB FUNCTIONS'];
addpath(fullfile(basepath,'Custom MATLAB Functions'));
addpath(fullfile(basepath,'Custom MATLAB Functions','plot2svg-master\src'));
addpath(fullfile(basepath,'eeglab'));
addpath(fullfile(basepath,'fieldtrip-20181210'))
ft_defaults
eeglab;
EEGEMPTY = EEG;
close all;
clc;

% Define directories
datadir  = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_PROCESS_SYNCHRONIZED_EEG_FMRI_DATA');
rawdir   = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_RAW_SYNCHRONIZED_EEG_FMRI_DATA');

% Get channel locations
allchanlocs = readlocs([drive,'\Dropbox\Research\Data\UH-NEUROLEG\EEG Montage & Location Files\1020_64chan_Brainvision_EarGndRef.ced']);
allchanlocs([17,22,28,32]) = [];

% Get files for each subject
subs = {'TF01','TF02','TF03'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        WHICH PROCESSES?          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
makesetdata = 0;
computeclusterstats = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Define frequency bands
delta   = [.5 4];
theta   = [4 8];
alpha   = [8 13];
himu    = [10 12];
beta    = [15 30];
gamma   = [30 55];
higamma = [65 90];
BANDS   = {delta,theta,alpha,beta,gamma,higamma};
BANDNAMES = {'delta','theta','alpha','beta','gamma','higamma'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                    %
%        SEGMENT MOVE WINDOW AND SAVE TO SET FILE    %
%                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if makesetdata
    all_movetimes = cell(length(subs),1);
    all_movedata  = cell (length(subs),1);
    all_basedata  = cell (length(subs),1);
    % Loop through each subject, concatenate, and process
    for aa = 1:length(subs)
        
        % Get variables
        vars = who;
        
        % Get eeg files for each subject
        load(fullfile(datadir, [subs{aa}, '-ALLTRIALS-DIPFIT-eeg.mat'   ]));
        load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-stim.mat'  ]));
        % Load movement data
        load(fullfile(rawdir, [subs{aa}, '-ALLTRIALS-gonio.mat' ]));
        
        % Get trial information
        trialbreaks = EEG.trialbreaks;
        stimpattern = cell(size(STIM,1),1);
        movements = {'RK','RA','LK','LA','BH','FIX'};
        movetimes = cell(length(movements),2);
        movedata  = cell(length(movements),1);
        
        
        basetemp = EEG.data(:,EEG.trialbreaks==0);
        basewin  = floor(size(EEG.data(:,EEG.trialbreaks==0),2)/EEG.srate/12);
        %basedata = zeros(size(EEG.data,1),12*EEG.srate,basewin);
        basedata = cell(1,basewin);
        t1 = 1;
        t2 = t1 + 12*EEG.srate-1;
        for bb = 1:basewin
            %basedata(:,:,bb) = EEG.data(:,t1:t2);
            basedata{bb} = EEG.data(:,t1:t2);
            t1 = t2;
            t2 = t1 + 12*EEG.srate-1;
        end
        all_basedata{aa} = basedata;
        
        TEMP = EEGEMPTY;
        TEMP.data = cat(3,basedata{:});
        TEMP.srate = EEG.srate;
        TEMP.chanlocs = EEG.chanlocs;
        TEMP.filename = [subs{aa} '-REST-eeg.set'];
        TEMP = eeg_checkset(TEMP);
        pop_saveset(TEMP,'filename',TEMP.filename,'filepath',fullfile(datadir,'SET'));
        
        % Loop through each movement
        for aaa = 1:length(movements)
            limb = movements{aaa};
            movetimes{aaa,1} = cell(size(STIM,1),2);
            movetimes{aaa,2} = movements{aaa};
            temp = cell(size(STIM,1),1);
            
            % Loop through each trial
            for bb = 1:size(STIM,1)
                trialdata = EEG.data(:,EEG.trialbreaks==bb);
                switch limb
                    case 'FIX'
                        % Times when movements are happening
                        whenmoving = (STIM(bb).initialDelay + [STIM(bb).onsets' STIM(bb).onsets'+12]).*1000;
                        t_moving = [];
                        % Create single vector of movement times
                        for cc = 1:size(whenmoving,1)
                            t_moving = cat(2,t_moving,whenmoving(cc,1):whenmoving(cc,2));
                        end
                        clear cc
                        % Get fixation times
                        fixtimes = setdiff(STIM(bb).initialDelay*EEG.srate:length(trialdata),t_moving);
                        % figure; scatter(t_moving,zeros(1,length(t_moving))); hold on; scatter(fixtimes,zeros(1,length(fixtimes)))
                        
                        wm = whenmoving';
                        fixvec = [1500 wm(:)' wm(end)+12*EEG.srate];
                        fixmat = transpose(reshape(fixvec,2,numel(fixvec)/2));
                        fixmat(:,2) = fixmat(:,2)-1;
                        %tempdat = zeros(size(trialdata,1),12*EEG.srate,size(fixmat,1));
                        tempdat = cell(1,size(fixmat,1));
                        for cc = 1:size(fixmat,1)
                            %tempdat(:,:,cc) = trialdata(:,fixmat(cc,1):fixmat(cc,2));
                            tempdat{cc} = trialdata(:,fixmat(cc,1):fixmat(cc,2));
                        end
                        
                    otherwise
                        % Get movement times from STIM
                        idx      = find(strcmpi(STIM(bb).states,limb)); % Get movements of right knee
                        onset    = STIM(bb).initialDelay + STIM(bb).onsets(idx); % seconds
                        duration = 12;%STIM(bb).Duration(idx); % seconds
                        time     = [onset; onset + duration]'; % seconds [onset, offset]
                        samples  = floor(time .* EEG.srate); % sample points
                        
                        % Store movement times
                        %movetimes{aaa}{bb,1} = find(EEG.trialbreaks==bb);
                        movetimes{aaa}{bb,2} = samples;
                        %tempdat = zeros(size(trialdata,1),(samples(1,2) - samples(1,1)),size(samples,1));
                        tempdat = cell(1,size(samples,1));
                        for cc = 1:size(samples,1)
                            %tempdat(:,:,cc) = trialdata(:,samples(cc,1):(samples(cc,2)-1));
                            tempdat{cc} = trialdata(:,samples(cc,1):(samples(cc,2)-1));
                        end
                end
                temp{bb} = tempdat;
                
            end % bb = 1:size(STIM,1)
            movedata{aaa} = cat(3,[temp{:}]);
            TEMP = EEGEMPTY;
            TEMP.data = cat(3,movedata{aaa}{:});
            TEMP.srate = EEG.srate;
            TEMP.chanlocs = EEG.chanlocs;
            TEMP.filename = [subs{aa} '-' limb '-eeg.set'];
            TEMP = eeg_checkset(TEMP);
            pop_saveset(TEMP,'filename',TEMP.filename,'filepath',fullfile(datadir,'SET'));
        end
        
        all_movedata{aa} = movedata;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                    %
%           TOPOPLOT STATS USING FIELDTRIP           %
%                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if computeclusterstats
    % Loop through each subject, concatenate, and process
    movements = {'RK','RA','LK','LA','BH','FIX'};
    all_psd = cell(length(subs),length(movements));
    rest_psd = cell(length(subs),1);
    foi = .5:.25:128;
    for aa = 1:length(subs)
        
        cfg = [];
        cfg.dataset = fullfile(datadir,'SET', [subs{aa} '-REST-eeg.set']);
        data = ft_preprocessing(cfg);
        
        % Compute PSD
        cfg           = [];
        cfg.method    = 'mtmfft';
        cfg.taper        = 'dpss';
        cfg.tapsmofrq=1;
        cfg.channel = 'all';
        cfg.output    = 'pow';
        cfg.pad         = 'nextpow2';
        cfg.keeptrials  = 'yes';
        cfg.foi       = foi;
        A=ft_freqanalysis(cfg, data);
        rest_psd{aa} = A;
        clear A;
        
        % Loop through each movement
        for bb = 1:length(movements)
            limb = movements{bb};
            
            % Make fieltrip config file
            cfg = [];
            cfg.dataset = fullfile(datadir,'SET',[subs{aa} '-' limb '-eeg.set']);
            data = ft_preprocessing(cfg);
            
            % Compute PSD
            cfg           = [];
            cfg.method    = 'mtmfft';
            cfg.taper        = 'dpss';
            cfg.tapsmofrq=1;
            cfg.channel = 'all';
            cfg.output    = 'pow';
            cfg.pad         = 'nextpow2';
            cfg.keeptrials  = 'yes';
            cfg.foi       = foi;
            A=ft_freqanalysis(cfg, data);
            
            % Store psds
            all_psd{aa,bb} = A;
        end
    end
    
    sub_fix_minus_move  = cell(length(subs),1);
    sub_rest_minus_move = cell(length(subs),1);
    for aa = 1:length(subs)
        % Initialize variables
        move_fix = cell(length(movements)-1,length(BANDS));
        move_rest = cell(length(movements)-1,length(BANDS));
        % Get data for testing
        fixdat  = all_psd{aa,end};
        restdat = rest_psd{aa};
        % Loop through each movement
        for bb = 1:length(movements)-1
            % Get movement condition
            movedat = all_psd{aa,bb};
            % Loop through each band
            for cc = 1:length(BANDS)
                % Get frequency of interest
                foi = BANDS{cc};
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%
                %     COMPARE TO REST     %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Generate configuration for stats
                cfg = [];
                cfg.avgoverfreq      = 'yes';
                cfg.method           = 'montecarlo';       % use the Monte Carlo Method to calculate the significance probability
                cfg.statistic        = 'ft_statfun_indepsamplesT'; % use the independent samples T-statistic as a measure to
                cfg.correctm         = 'cluster';
                cfg.clusterstatistic = 'maxsum'; % test statistic that will be evaluated under the
                cfg.numrandomization = 2000;      % number of draws from the permutation distribution
                cfg.alpha            = 0.05;
                cfg_neighb           = [];
                cfg_neighb.method    = 'triangulation';
                neighbours           = ft_prepare_neighbours(cfg_neighb, all_psd{1,1});
                cfg.neighbours       = neighbours;  % the neighbours specify for each sensor with           which other sensors it can form clusters
                cfg.frequency        = foi;
                cfg.avgoverfreq      = 'yes';
                cfg.design           = cat(2,ones(1,size(movedat.powspctrm,1)),2.*ones(1,size(restdat.powspctrm,1)));
                cfg.ivar             = 1; % "condition" is the independent variable
                % Compute stats
                stat = ft_freqstatistics(cfg,movedat,restdat); % Compare independent conditions (not A-B)
                move_rest{bb,cc} = stat;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%
                %     COMPARE TO FIX     %
                %%%%%%%%%%%%%%%%%%%%%%%%%%
                % Generate configuration for stats
                cfg = [];
                cfg.avgoverfreq      = 'yes';
                cfg.method           = 'montecarlo';       % use the Monte Carlo Method to calculate the significance probability
                cfg.statistic        = 'ft_statfun_indepsamplesT'; % use the independent samples T-statistic as a measure to
                cfg.correctm         = 'cluster';
                cfg.clusterstatistic = 'maxsum'; % test statistic that will be evaluated under the
                cfg.numrandomization = 2000;      % number of draws from the permutation distribution
                cfg.alpha            = 0.05;
                cfg_neighb           = [];
                cfg_neighb.method    = 'triangulation';
                neighbours           = ft_prepare_neighbours(cfg_neighb, all_psd{1,1});
                cfg.neighbours       = neighbours;  % the neighbours specify for each sensor with           which other sensors it can form clusters
                cfg.frequency        = foi;
                cfg.avgoverfreq      = 'yes';
                cfg.design           = cat(2,ones(1,size(movedat.powspctrm,1)),2.*ones(1,size(fixdat.powspctrm,1)));
                cfg.ivar             = 1; % "condition" is the independent variable
                % Compute stats
                stat = ft_freqstatistics(cfg,movedat,fixdat); % Compare independent conditions (not A-B)
                move_fix{bb,cc} = stat;
            end
        end
        sub_fix_minus_move{aa}  = move_fix;
        sub_rest_minus_move{aa} = move_rest;
    end
else
    load('TopoplotStats_Fieldtrip_MovevsRest.mat','sub_fix_minus_move','sub_rest_minus_move');
end % if computeclusterstats





% Get subject specific data
fix_or_rest = 'fix';
allpsd = sub_fix_minus_move;
% allpsd = sub_rest_minus_move;
movements = {'RK','RA','LK','LA','BH','FIX'};
thisdir = cd;
% Loop through each subject
for aa = 1:length(subs)
    
    % GET MAX AND MIN VALS FOR COLORBAR
    % Loop through each movement
    max_min_vals = cell(length(BANDS),1);
    for bb = 1:length(movements)-1
        % Loop through each band
        for cc = 1:length(BANDS)
            % Get stat
            stat = allpsd{aa}{bb,cc};
            % Get all vals
            max_min_vals{cc} = cat(2,max_min_vals{cc},stat.stat);
        end
    end
    
    
    % Create figure
    %ff = figure('color','w','units','inches','position',[5 2 6.5 6.5]);
    %ax = tight_subplot(size(allpsd{aa},1),length(BANDS),[.001 .001],[.01 .1],[.075 .1]);
    
    % Each movement
    axnum = reshape(1:length(allpsd{aa})*length(BANDS),length(allpsd{aa}),length(BANDS));
    axnum = axnum';
    axnum = axnum(:);
    cnt = 1;
    cnt1 = 1;
    cnt2 = 1;
    ylabels = {'\delta','\theta','\alpha','\beta','\gamma_{low}','\gamma_{high}'};
    xtitles = {'Knee','Ankle','Knee','Ankle','Both Hands'};
    
    % Loop through each movement
    for bb = 1:length(movements)-1
        % Loop through each band
        for cc = 1:length(BANDS)
            % Get stat
            stat = allpsd{aa}{bb,cc};
            
            % Get axis
            %             axes(ax(axnum(cnt)));
            
            % Set configuration for fieldtrip topoplot
            cfgtopo = [];
            cfgtopo.parameter = 'stat';
            cfg.marker = 'no';
            cfgtemp = [];
            cfgtemp.elec = stat.elec; cfgtemp.rotate = 90;
            cfgtopo.layout = ft_prepare_layout(cfgtemp, stat);
            cfgtopo.showcallinfo = 'no';
            cfgtopo.feedback = 'no';
            cfgtopo.xlim = [stat.freq stat.freq];
            
            cfgtopo.comment ='no';
            %             cfgtopo.comment = []; %strcat('freq: ', num2str(stat.freq), ' Hz');
            %             cfgtopo.commentpos = 'title';
            cfgtopo.alpha  = 0.05;
            cfgtopo.subplotsize=[1 1];
            cfgtopo.rotate=90;
            cfgtopo.gridscale = 300;
            cfgtopo.style = 'both';
            %cfgtopo.contournum = 10;
            try
                
                cfgtopo.highlight = {'on'};
                cfgtopo.highlightsymbol = {'*'};
                cfgtopo.highlightsize = {10};
                cfgtopo.highlightfontsize = {10};
                cfgtopo.highlightcolor = {[0 0 0]};
                cfgtopo.xlim = [stat.freq stat.freq];
                cfgtopo.highlightchannel = [];
                cfgtopo.comment ='no';
                cfgtopo.highlightsizeseries  = 5.*ones(1,5);
                ft_clusterplot(cfgtopo, stat); % plot the significant channels on topoplot
            catch err
                disp(err.message)
                %cfg.markercolor        = channel marker color (default = [0 0 0] (black))
                cfgtopo.markersize         = 0.1;
                
                
                
                cfgtopo.highlight = {'on'};
                cfgtopo.highlightsymbol = {[]};
                cfgtopo.highlightsize = {[8]};
                cfgtopo.highlightfontsize = {[8]};
                cfgtopo.highlightcolor = {[0 0 0]};
                ft_topoplotTFR(cfgtopo, stat);
            end
            
            ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
            maxval = ceil(max([abs(min(max_min_vals{cc}(:))),abs(max(max_min_vals{cc}(:)))]));
            cb = colorbar('Limits',[-maxval,maxval]);
            colormap(flipud(brewermap(100,'RdBu')));
            cb.Label.String = '(dB)';
            cb.Label.Rotation = 0;
            cb.Label.VerticalAlignment = 'middle';
            cb.Label.HorizontalAlignment = 'left';
            cb.FontWeight = 'b';
            cb.FontSize = 8;

            ax = gca;
            ax.CLim = [-maxval maxval];
            ax.YLabel.String = ylabels{cc};
            ax.YLabel.FontSize = 16;
            ax.YLabel.Visible = 'on';
            ax.YLabel.Rotation = 0;
            ax.YLabel.FontWeight = 'bold';
            
            ff = gcf;
            ff.Color = 'w';
            ff.Units = 'inches';
            ff.Position(3) = 3;
            ff.Position(4) = 3;
            
            ax.Title.String = xtitles{bb};
            ax.Title.FontSize = 12;
            ax.Title.Position(2) =.85;
            
            flname = [subs{aa} '_' fix_or_rest '_' movements{bb} '_' BANDNAMES{cc} '.svg']
            flname2 = [subs{aa} '_' fix_or_rest '_' movements{bb} '_' BANDNAMES{cc} '.png']
           
            if cnt <= length(allpsd{aa})
                %tt = text(xpos(cnt1),0,ylabels{cnt1});
                %tt.FontWeight = 'b';
                %tt.Interpreter = 'latex';
                %ylabel(ylabels{cnt1});
                cnt1 = cnt1 + 1;
            end
            
            if cc ~= 1
                ax.Title.Visible = 'off';
            end
            
            if ~strcmpi(movements{bb},'BH')
                ax.YLabel.Visible = 'off';
            end
            
            if ~strcmpi(movements{bb},'LA')
                cb.Visible = 'off';
            end
            
            
            pause(1);
            cd('ALL_TOPOPLOTS_FIELDTRIPSTATS');
            eval(['export_fig ' flname2  ' -r300 -png'])
            %plot2svg(flname);
            cd(thisdir);
            close;
            cnt = cnt+1;
        end
    end
end


