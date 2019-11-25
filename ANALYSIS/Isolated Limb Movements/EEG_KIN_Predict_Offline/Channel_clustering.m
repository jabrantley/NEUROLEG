ll=1;ul=128;
A=[];
% Generate the study prior
Indexes=grp2idx({STUDY.datasetinfo.condition}); % corresponds to 3 separate conditions
Indexes(1:2:31)=3;
GP=grp2idx({STUDY.datasetinfo.group});% corresponds to 4 separate groups
locationsF=find(Indexes==3); 

for gp=1:4
    loc=find(GP(locationsF)==gp);
	% compute the features for each subject in each of the groups foe a
	% particular condition 
    for person=1:length(loc)
        % load the data
        cfg = [];
        %test = pop_loadset(fullfile('D:\Dropbox\Research\Data\UH-NEUROLEG\PROCESS INFOMAX\SET CONCATENATED TRIALS FOR EACH SUBJECT','AB_UH_01-ALLTRIALS-eeg.set'))
        cfg.dataset = fullfile('D:\Dropbox\Research\Data\UH-NEUROLEG\PROCESS INFOMAX\SET CONCATENATED TRIALS FOR EACH SUBJECT','AB_UH_01-ALLTRIALS-eeg.set');
        [data] = ft_preprocessing(cfg)

        % segment the first minute of data
        cfg.begsample = 256*1;
        cfg.endsample = 256*60;
        data = ft_redefinetrial(cfg, data);
        
        % segment into 6 second window with zero overlap
        cfg = [];
        cfg.length  = 6;
        cfg.overlap = 0;
        data_segmented = ft_redefinetrial(cfg, data);
        
        %% Compute band power
        cfg           = [];
        cfg.method    = 'mtmfft';
        cfg.taper        = 'dpss';
        cfg.tapsmofrq=1;
        cfg.channel = 'all';
        cfg.output    = 'pow';        
        cfg.pad         = 'nextpow2'
        cfg.keeptrials  = 'yes'  
        cfg.foi       = ll:0.5:ul;    
        A=ft_freqanalysis(cfg, data_segmented);       
        
        % Compute median power
        A.powspctrm=squeeze(median((A.powspctrm)));
        A=rmfield(A,'cumsumcnt');
        A=rmfield(A,'cumtapcnt');
        A.dimord='chan_freq';
        A.cfg.keeptrials='no';        
        PSD{person}          = A; 
        clearvars -except person Group STUDY Indexes GP locationsF loc PSD DATA gp x
    end
    DATA{gp}=PSD;
    PSD={};
end

%g et channel labels
Ch=DATA{1}{1}.label

%% Statistical Analysis
cfg = [];
cfg.avgoverfreq = 'yes' 
cfg.method = 'montecarlo';       % use the Monte Carlo Method to calculate the significance probability
cfg.statistic = 'ft_statfun_indepsamplesT'; % use the independent samples T-statistic as a measure to
%                                % evaluate the effect at the sample level
cfg.correctm = 'cluster';
cfg.clusterstatistic = 'maxsum'; % test statistic that will be evaluated under the
%                                permutation distribution.
cfg.numrandomization = 2000;      % number of draws from the permutation distribution
cfg.alpha            = 0.025;

cfg_neighb        = [];
cfg_neighb.method = 'triangulation';
neighbours        = ft_prepare_neighbours(cfg_neighb, DATA{1,1}{1});
cfg.neighbours    = neighbours;  % the neighbours specify for each sensor with
% %                                  which other sensors it can form clusters
cfg.frequency = [30 45]
cfg.avgoverfreq = 'yes' 
design = zeros(1,32);
design(1,1:16) = 1;
design(1,17:32) = 2;
cfg.design           = design;
cfg.design           = [
  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1  2 2 2 2 2 2 2 2   2 2 2 2 2 2 2 2  ];  % condition number
% cfg.uvar = 1;                                   % "subject" is unit of observation
cfg.ivar = 1;                                   % "condition" is the independent variable


[stat] = ft_freqstatistics(cfg,DATA{4}{:},DATA{1}{:}) % Compare independent conditions (not A-B)
Ch(find(stat.mask))' % find the significant features

cfg = [];
cfg.alpha  = 0.05;
cfg.subplotsize=[1 1];    
cfg.parameter = 'stat';
cfg.rotate=90;
ft_clusterplot(cfg, stat); % plot the significant channels on topoplot
