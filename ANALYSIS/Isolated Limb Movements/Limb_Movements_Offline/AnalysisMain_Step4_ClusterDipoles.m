%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                       CLUSTER DIPFIT RESULTS                            %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

% Clean up
clearvars -except drive datadir rawdir savedir basepath EEG movedir setdir

% Get files for each subject
subs = {'TF01','TF02','TF03'};

% Get all mat files
eegfiles = dir(fullfile(datadir, '*DIPFIT-eeg.mat'));

% Get variable names
vars = who;
cnt = 1;
for ii = 1:length(eegfiles)
    
    % Get variable names
    vars = who;
    
    % Get file
    thisfile   = eegfiles(ii).name;
    splitname  = strsplit(thisfile,'-');
    splitname2 = strsplit(thisfile,'.');
    % Load EEG
    load(fullfile(datadir,eegfiles(ii).name));
    
    % Check to make sure the EEG struct is complete
    [EEG,~] = eeg_checkset(EEG); % EEGORIG = EEG;
    EEG.data = double(EEG.data);
    
    % Save as set
    if exist(fullfile(setdir,[splitname2{1} '.set']))~=2
        pop_saveset(EEG,'filename',[splitname2{1} '.set'],'filepath',setdir);
    end
    
    % Save file name w/directory; subject name including trial; and
    % condition
    
    datasets{cnt,1}  = fullfile(setdir,[splitname2{1} '.set']);
    subjects{cnt,1}  = splitname{1};
    condition{cnt,1} = 'ALLTRIALS';
    cnt              = cnt + 1;
    
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        %
%                       Cluster Independent Components                   %
%                                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
reject_outlier = 0;
numclusts= 8;
rvThreshold = 0.16;
conditionname = 'ISOLATEDLIMB';
filepath = cd;

filename= ['NEUROLEG-' conditionname '-' num2str(numclusts) 'Clusters'];
% Open eeglab
[ALLEEG EEG CURRRENTSET ALLCOM] =  eeglab;

% Set memory options
pop_editoptions( 'option_storedisk', 1, 'option_savematlab', 1,...
    'option_computeica', 0, 'option_rememberfolder', 1);

% Initialize STUDY:
STUDY = []; CURRENTSTUDY = 0; ALLEEG=[]; EEG=[]; CURRENTSET=[];

for ii = 1:length(datasets)
    [STUDY ALLEEG] = std_editset( STUDY, ALLEEG,...
        'commands',{'index',ii, 'load', datasets{ii},...
        'subject', subjects{ii},'condition',condition{ii}...
        'dipselect',rvThreshold/100,'inbrain','off'});%,'condition',condition{ii},...
end

% Name the study
[STUDY ALLEEG] = std_editset( STUDY, ALLEEG, 'name',...
    filename, 'task', ['NEUROLEG-' conditionname]);

% Update the GUI
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
[STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);
eeglab redraw;

CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
STUDY = std_makedesign(STUDY, ALLEEG, 1, 'variable1','condition',...
    'defaultdesign','off','subjselect',subjects);

% Save the study
[STUDY EEG] = pop_savestudy( STUDY, EEG,...
    'filename', filename,'filepath', filepath);

% Precompute all measures
[STUDY ALLEEG] = std_precomp(STUDY, ALLEEG, 'components','recompute','on',...
    'scalp','on');%,...
    %'spec','on', 'specparams',{'freqrange',[1, 50]});%,...
%'ersp','on','erspparams',{'cycles' [3 0.5] 'freqs' [1 50]},...
%'itc','on');
% 'erp','on','rmbase',[-200,0],...


% Precluster data
[STUDY ALLEEG] = std_preclust(STUDY, ALLEEG, 1,...
    {'dipoles' 'norm' 1 });%'weight' 10},...
%     {'scalp','npca',10,'norm',1,'weight',1,'abso',1},...
%     {'spec','npca',10,'norm',1,'weight',1,'freqrange',[1 50]});
%{'ersp', 'npca', 10, 'freqrange', [1 50], 'timewindow' ,[],'norm',1,'weight',1},...
%{'itc','npca',10,'freqrange',[1 50],'norm',1,'weight',1},...
%{'erp','npca',10,'norm',1,'weight',1,'abso',1},...


% Perform clustering
if reject_outlier == 1
    [STUDY] = pop_clust(STUDY, ALLEEG, 'algorithm',...
        'kmeans', 'clus_num', numclusts , 'outliers', stdcutoff );
elseif reject_outlier == 0
    [STUDY] = pop_clust(STUDY, ALLEEG, 'algorithm',...
        'kmeans', 'clus_num', numclusts);
end

% Compute centroid for each cluster
[STUDY, centroid] = std_centroid(STUDY, ALLEEG, [] ,'dipole', 'scalp');
STUDY.centroids = centroid;


% Calculate talairach coordinates
% icbm2tal may perform better than mni2tal
% reference: http://www.brainmap.org/icbm2tal/
clearvars talairach_coord
count = 1;

% The first cluster is the parent and the second one is the outliers.
% If reject_outlier == 1, start on third cluster.  Otherwise, start on
% second (i.e., skip parent only).
if reject_outlier == 1
    first_idx = 2;
elseif reject_outlier == 0
    first_idx = 1;
end

% Convert MNI to Talairach coordinates
for ii = first_idx:length(centroid) % ignore the first
    if reject_outlier == 1
        tal_coord{ii-1,:} = icbm_spm2tal(centroid{ii}.dipole.posxyz);
    elseif reject_outlier == 0
        tal_coord{ii,:} = icbm_spm2tal(centroid{ii}.dipole.posxyz);
    end
    % if there's more than two locations identified, separate them and
    % identify talairach in each
    if size(centroid{ii}.dipole.posxyz,1) > 1
        computed = icbm_spm2tal(centroid{ii}.dipole.posxyz);
        talairach_coord(count,:) = computed(1,:);
        count = count + 1;
        talairach_coord(count,:) = computed(2,:);
        count = count + 1;
    else
        talairach_coord(count,:) = icbm_spm2tal(centroid{ii}.dipole.posxyz);
        count = count + 1;
    end
end


% Update the GUI
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = 1:length(EEG);
[STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);
eeglab redraw

% Save the study
[STUDY EEG] = pop_savestudy( STUDY, EEG,...
    'filename',filename,'filepath',filepath);

% Extract information for plotting
% The first two clusters are parents and outliers
lencluster = length(STUDY.cluster);
lenshift = lencluster - numclusts;

% sort based on the number of ICs (just for plotting purposes, you could
% skip this part)
clearvars numOfICs ii
for ii = 1:numclusts
    numOfICs(ii) = length(STUDY.cluster(ii+lenshift).comps);
end
clearvars sort_idx ii
[numICs_sort,sort_idx] = sort(numOfICs,'descend');

% calculate talairach coordinates
% the one Luu used: mni2tal is not good...
% reference: http://www.brainmap.org/icbm2tal/
clearvars tal_coord tal_sorted
%for ii = first_idx : length(centroid) % ignore the first one since it's outlier
for ii = first_idx : length(centroid) % ignore the first one since it's outlier
    if reject_outlier == 1
        tal_coord{ii-1,:} = icbm_spm2tal(centroid{ii}.dipole.posxyz);
    elseif reject_outlier == 0
        tal_coord{ii,:} = icbm_spm2tal(centroid{ii}.dipole.posxyz);
    end
end
clearvars ii

% sort
for ii = 1:numclusts
    tal_sorted{ii,:} = tal_coord{sort_idx(ii)};
end
clearvars ii

% make tal_sorted into normal array to export into txt
count = 1;
for ii = 1:numclusts
    if size(tal_sorted{ii,:},1) > 1
        tal_sort(count,:) = tal_sorted{ii,:}(1,:);
        count = count + 1;
        tal_sort(count,:) = tal_sorted{ii,:}(2,:);
        count = count + 1;
    else
        tal_sort(count,:) = tal_sorted{ii,:};
        count = count + 1;
    end
end
clearvars ii

% save the sorted talairach coordinates to the STUDY
STUDY.tal_sort = tal_sort;

% Identify Brodmann Area
ba_obj = class_getBA('input',tal_sort,'search_spacing',5);
process(ba_obj);
sorted_info = getSortedBA(ba_obj, numclusts, tal_sorted);

STUDY.sorted_info = sorted_info;
STUDY.sort_idx = sort_idx;
STUDY.ba_info = ba_obj;

% update the GUI
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
[STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);
eeglab redraw

% put all the info into STUDY
STUDY.tal_sort = tal_sorted;
STUDY.numclusts = numclusts;

% Save the study
[STUDY EEG] = pop_savestudy( STUDY, EEG,...
    'filename', filename,'filepath',filepath);

