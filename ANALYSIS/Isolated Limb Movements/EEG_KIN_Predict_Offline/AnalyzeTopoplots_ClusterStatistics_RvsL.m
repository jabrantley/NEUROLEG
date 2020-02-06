
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
addpath(genpath(fullfile(basepath,'Custom MATLAB Functions')));
%addpath(fullfile(basepath,'Custom MATLAB Functions','plot2svg-master\src'));
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
subs2 = {'TF01','TF02','TF03','ALLSUB'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        WHICH PROCESSES?          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
makesetdata = 0;
computeclusterstats = 0;
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
%           TOPOPLOT STATS USING FIELDTRIP           %
%                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if computeclusterstats
    % Loop through each subject, concatenate, and process
    movements = {'RK','RA','LK','LA'};
    all_psd = cell(length(subs),length(movements));
    rest_psd = cell(length(subs),1);
    foi = .5:.25:128;
    for aa = 1:length(subs2)
        
        % Loop through each movement
        for bb = 1:length(movements)
            limb = movements{bb};
            
            % Make fieltrip config file
            cfg = [];
            cfg.dataset = fullfile(datadir,'SET',[subs2{aa} '-' limb '-eeg.set']);
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
    
    sub_RK_minus_LK  = cell(length(subs2),1);
    sub_RA_minus_LA = cell(length(subs2),1);
    
    for aa = 1:length(subs2)
        % Initialize variables
        move_knee  = cell(1,length(BANDS));
        move_ankle = cell(1,length(BANDS));
        % Get data for testing
        RKdat  = all_psd{aa,1};
        RAdat  = all_psd{aa,2};
        LKdat  = all_psd{aa,3};
        LAdat  = all_psd{aa,4};
            % Loop through each band
            for cc = 1:length(BANDS)
                % Get frequency of interest
                foi = BANDS{cc};
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%
                %     COMPARE TO KNEE     %
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
                cfg.design           = cat(2,ones(1,size(RKdat.powspctrm,1)),2.*ones(1,size(LKdat.powspctrm,1)));
                %cfg.design           = cat(2,ones(1,size(movedat.powspctrm,1)),2.*ones(1,size(restdat.powspctrm,1)));
                cfg.ivar             = 1; % "condition" is the independent variable
                % Compute stats
                stat = ft_freqstatistics(cfg,RKdat,LKdat); % Compare independent conditions (not A-B)
                %stat = ft_freqstatistics(cfg,movedat,restdat); % Compare independent conditions (not A-B)
                move_knee{1,cc} = stat;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%
                %     COMPARE ANKLE     %
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
                cfg.design           = cat(2,ones(1,size(RAdat.powspctrm,1)),2.*ones(1,size(LAdat.powspctrm,1)));
                %cfg.design           = cat(2,ones(1,size(movedat.powspctrm,1)),2.*ones(1,size(restdat.powspctrm,1)));
                cfg.ivar             = 1; % "condition" is the independent variable
                % Compute stats
                stat = ft_freqstatistics(cfg,RAdat,LAdat); % Compare independent conditions (not A-B)
                %stat = ft_freqstatistics(cfg,movedat,restdat); % Compare independent conditions (not A-B)
                move_ankle{1,cc} = stat;
            end
        sub_RK_minus_LK{aa}  = move_knee;
        sub_RA_minus_LA{aa} = move_ankle;
    end
    save('TopoplotStats_Fieldtrip_RightVsLeft.mat','sub_RK_minus_LK','sub_RA_minus_LA');
else
    load('TopoplotStats_Fieldtrip_RightVsLeft.mat','sub_RK_minus_LK','sub_RA_minus_LA');
end % if computeclusterstats


%%
close all


% Get subject specific data
%fix_or_rest = '';
% allpsd = sub_fix_minus_move;
%allpsd = sub_rest_minus_move;
limb = 'Ankle';
% allpsd = sub_RK_minus_LK;
allpsd = sub_RA_minus_LA;
% allpsd = sub_hand_minus_move;
% movements = {'RK','RA','LK','LA','BH','FIX'};
% move_order = [5,1,2,3,4];
thisdir = cd;
cd('ALL_TOPOPLOTS_FIELDTRIPSTATS');
% Loop through each subject
for aa = 1:length(subs2)%1:length(subs2)
    
    % GET MAX AND MIN VALS FOR COLORBAR
    % Loop through each movement
    max_min_vals = cell(length(BANDS),1);
    
        % Loop through each band
        for cc = 1:length(BANDS)
            % Get stat
            stat = allpsd{aa}{1,cc};
            % Get all vals
            max_min_vals{cc} = cat(2,max_min_vals{cc},stat.stat);
        end
        
        % Create figure
        ftopo = figure('color','w','units','inches','position',[5 2 2.5 6.5]);
        axtopo= tight_subplot(length(BANDS),1,[.025 .025],[.05 .1],[.1 .1]);
        
        % Each movement
        axnum = reshape(1:length(BANDS),1,length(BANDS));
        axnum = axnum';
        %axnum = fliplr(axnum);
        move_order = 1:length(BANDS);
        axnum = axnum(:);
        cnt = 1;
        cnt1 = 1;
        cnt2 = 1;
        ylabels = {'\delta','\theta','\alpha','\beta','\gamma_{low}','\gamma_{high}'};
        xtitles = {'Both Hands','Knee','Ankle','Knee','Ankle'};
        xpos = [-.85 -.85 -.85 -.85 -1.15 -1.15];
            % Loop through each band
            for cc = 1:length(BANDS)
                % Get stat
                stat = allpsd{aa}{1,cc};
                stat.stat = -1.*stat.stat;
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
                cfgtopo.style = 'straight'; %'both' for contours
                cfgtopo.linewidth = 1;
                cfgtopo.contournum = 6;
                if any(stat.mask)
                    cfgtopo.highlight = {'on'};
                    cfgtopo.highlightsymbol = {'*'};
                    cfgtopo.highlightsize = {1};
                    cfgtopo.highlightfontsize = {1};
                    cfgtopo.highlightcolor = {[0 0 0]};
                    cfgtopo.xlim = [stat.freq stat.freq];
                    cfgtopo.highlightchannel = [];
                    cfgtopo.comment ='no';
                    cfgtopo.highlightsizeseries  = 2.*ones(1,5);
                    ft_clusterplot(cfgtopo, stat); % plot the significant channels on topoplot
                else
                    cfgtopo.markersize         = 0.1;
                    cfgtopo.highlight = {'off'};
                    figure;
                    ft_topoplotTFR(cfgtopo, stat);
                    drawnow;
                    pause(1);
                    
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
                
                axtemp = gca;
                axtemp.CLim = [-maxval maxval];
                axtemp.YLabel.String = ylabels{cc};
                axtemp.YLabel.FontSize = 16;
                axtemp.YLabel.Visible = 'on';
                axtemp.YLabel.Rotation = 0;
                axtemp.YLabel.FontWeight = 'bold';
                
                figtemp = gcf;
                figtemp.Color = 'w';
                figtemp.Units = 'inches';
                figtemp.Position(3) = 3;
                figtemp.Position(4) = 3;
                
                axtemp.Title.String = limb;
                axtemp.Title.FontSize = 12;
                axtemp.Title.Position(2) =.85;
%                 
%                 flname = [subs2{aa} '_RvsL_' limb '.png'];
%                 eval(['export_fig ' flname  ' -r300 -png'])
%                 cd(thisdir);
%                 close;
                
%                 
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                                                             %
                %   NOTE: I CHANGED LINES 215, 234 in ft_plot_lay to reduce   %
                %         thickness of head                                   %
                %                                                             %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                axes(axtopo(axnum(cnt)));
                copyobj(axtemp.Children,axtopo(axnum(cnt)))
                axis square
                clr = flipud(brewermap(100,'RdBu'));
                colormap(clr);
                axtopo(axnum(cnt)).CLim = [-maxval maxval];
                axtopo(axnum(cnt)).XColor = 'w';
                axtopo(axnum(cnt)).YColor = 'w';
                
                if cnt <= length(BANDS)
                    tt = text(xpos(cnt1),0,ylabels{cnt1});
                    tt.FontWeight = 'b';
                    tt.FontSize = 12;
                    cnt1 = cnt1 + 1;
                end
                
                if any(cnt == [1:length(BANDS):numel(axnum)])
                    thisval = find(cnt == [1:length(BANDS):numel(axnum)]);
                    title(limb);
                    axtopo(axnum(cnt)).Title.Position(2) = .75;
                    
                end
                delete(figtemp);
                cnt = cnt+1;
            end
        
        
        axcbar = tight_subplot(length(BANDS),1,[.01 .05],[.015 .1],[.915 .01]);
        for dd = 1:length(axcbar)
            maxval = ceil(max([abs(min(max_min_vals{dd}(:))),abs(max(max_min_vals{dd}(:)))]));
            axes(axcbar(dd));
            axcbar(dd).CLim = [-maxval maxval];
            axcbar(dd).XColor = 'w';
            axcbar(dd).YColor = 'w';
            cc = colorbar;
            cc.Position(1) = .8;
            cc.Location = 'west';
            cc.Label.String = '(dB)'
            cc.Label.Rotation = 0;
            cc.Label.VerticalAlignment = 'middle';
            cc.Label.Position(1) = 5;
            cc.Label.FontWeight = 'b';
            %         cc.Position(2) = .05;
            %         cc.Position(4) = .1;
            cc.Limits = [-maxval maxval];
            cc.Position(1) = .8;
            %axcbar(bb)
        end
        
        
        ftopo.Color = 'w';
%         axtop = tight_subplot(1,2,[.05 .1],[.95 .01],[.275 .135]);
%         axes(axtop(1));
%         txt1 = text(.55,.5,'Intact Limb','FontWeight','b','HorizontalAlignment','center');
%         txt1.Position(1) = .525;
%         %l1 = line([txt1.Position(1) txt1.Position(1)+txt1.Position(2)],[.15 .15])
%         axtop(1).XColor = 'w';
%         axtop(1).YColor = 'w';
%         
%         axes(axtop(2));
%         txt2 = text(.5,.5,'Phantom Limb','FontWeight','b','HorizontalAlignment','center');
%         txt2.Position(1) = .5;
%         axtop(2).XColor = 'w';
%         axtop(2).YColor = 'w';
       
    
    %pause(1);
%     cd('ALL_TOPOPLOTS_FIELDTRIPSTATS');
     flname = [subs2{aa} '_RvsL_' limb '.png'];
                eval(['export_fig ' flname  ' -r300 -png'])
%                 cd(thisdir);
                close;
    
    
end
cd(thisdir);

