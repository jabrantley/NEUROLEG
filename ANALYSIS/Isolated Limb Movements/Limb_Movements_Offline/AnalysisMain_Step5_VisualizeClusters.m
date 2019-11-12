close all;
clear;
clc;

% Define drive
if strcmpi(getenv('username'),'justi')% WHICHPC == 1
    drive = 'D:';
elseif strcmpi(getenv('username'),'jabrantl') %WHICHPC == 2
    drive = 'E:';
elseif strcmpi(computer,'MACI64') % macbook
    drive = '/Volumes/STORAGE/';
end

% Define directories
filepath = cd;
datadir  = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_PROCESS_SYNCHRONIZED_EEG_FMRI_DATA');
setdir   = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_PROCESS_SYNCHRONIZED_EEG_FMRI_DATA','SET');
rawdir   = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_RAW_SYNCHRONIZED_EEG_FMRI_DATA');
movedir  = fullfile(drive,'Dropbox','Research','Data','UH-NEUROLEG','_PROCESS_SYNCHRONIZED_EEG_FMRI_DATA','MOVEMENT_WINDOW');
basepath = fullfile(drive,'Dropbox','Research','Analysis','MATLAB FUNCTIONS');

% Add paths
addpath(genpath(fullfile(basepath,'Brainstorm','brainstorm3','toolbox')));
addpath(genpath(fullfile(basepath,'Custom MATLAB Functions')));
addpath(genpath(fullfile(basepath,'shoeeg')));
addpath(fullfile(basepath,'eeglab'));
eeglab;
close all;
clc;

STUDY = []; CURRENTSTUDY = 0; ALLEEG=[]; EEG=[]; CURRENTSET=[];
% eeglab;
close all;
clc;


% Clean up
%clearvars -except drive datadir rawdir savedir basepath EEG movedir setdir

numclusts = 9;%4:9;
% numclusts = 4:9;

for aa =1:length(numclusts)
    
    % Get STUDY
    studyName = ['NEUROLEG-ISOLATEDLIMB-' num2str(numclusts(aa)) 'Clusters.study'];
    savedir = fullfile(cd,['DIPPLOT_' num2str(numclusts(aa)) 'Clusters']);
    
    % Define cluster structure
    cls(1:length(numclusts(aa))) = struct('sets',[],'comps',[],'trial',[],...
        'activations',[],'setname',[],'tf_file',[]);
    cnt = 1;
    
    % Make directory if doesnt already exist
    if exist(savedir,'dir') == 7
        %do nothing
    elseif exist(savedir,'dir') ==0
        SUCCESS = mkdir(savedir);
        if ~SUCCESS
            error('Directory unsuccesfully created.');
        end
    end
    
    % Load study
    STUDY = []; CURRENTSTUDY = 0; ALLEEG=[]; EEG=[]; CURRENTSET=[];
    [ALLEEG EEG CURRRENTSET ALLCOM] =  eeglab;
    %STUDY = []; CURRENTSTUDY = 0; ALLEEG=[]; EEG=[]; CURRENTSET=[];
    [STUDY ALLEEG] =  pop_loadstudy('filename',studyName,'filepath',filepath);
    
    sort_idx = STUDY.sort_idx;
    clustdata(1:length(STUDY.sort_idx)) = struct('subjects',[],'trials',[],'BA',[],'Gyrus',[],'numICs',[]);
    for ii = 1:length(STUDY.sort_idx)
        clustinfo = STUDY.cluster(sort_idx(ii)+1);
        setnums =  clustinfo.sets;
        subnum = zeros(length(setnums),1);
        trialnum = zeros(length(setnums),1);
        for jj = 1:length(setnums)
            subid = STUDY.subject{setnums(jj)};
            splitname = strsplit(subid,'-');
            subnum(jj) = str2num(splitname{1}(3:4));
        end
        clustdata(ii).subjects = subnum;
        clustdata(ii).BA       = STUDY.sorted_info.sorted_BAs{ii};
        clustdata(ii).Gyrus    = STUDY.sorted_info.sorted_Gyrus{ii};
        clustdata(ii).numICs   = length(clustinfo.comps);
    end
    
    % Define diplot object
    color_obj = class_colors;
    % Define dipplot class parameters
    dip_obj = class_dipplot('STUDY',STUDY,'ALLEEG',ALLEEG,...
        'numclusts',numclusts(aa),'first_idx',2,'sort_idx',sort_idx,...
        'color_matrix',color_obj.blind_friendly.color,...
        'endcolor_matrix',color_obj.blind_friendly.color,...
        'dipsize',[25,60]);
    % Evaluate
    process(dip_obj);
    
    % Convert mri file to standard MRI template from dipfit toolbox
    dipfitdefs;
    old_options = dip_obj.options;
    mrifile = template_models(2).mrifile;
    for jj = 1:length(dip_obj.options)
       isMRI = find(strcmpi(dip_obj.options{jj},'mri'));
       dip_obj.options{jj}{isMRI+1} = template_models(2).mrifile;
    end
    
    % Generate figure
    % figure('color','w','units','inches','position',figpos);
    for jj = 1:3 %number of views
        for ii = 1:numclusts(aa)
            fig = figure('color','w','units','inches','position',[5, 1, 5, 3]);
            visualize(dip_obj, ii, jj); % first cluster, top view
            % Generate filename
            if jj == 1
                viewname = 'top';
            elseif jj == 2
                viewname = 'sagittal';
            elseif jj == 3
                viewname = 'coronal';
            end
            clustnum = num2str(ii);
            % Save figure
            figname = fullfile(savedir,['Cls' clustnum '_' viewname '.tif']);
            export_fig(figname,'-tif','-r300');
            close;
        end
    end
    
    
end