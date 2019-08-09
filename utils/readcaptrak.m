% Parse XML format .bvct channel locations file
% This is specific to the neuroleg project and should be modified for other
% montages
%
% Adapted from code provided by Trieu Phat Luu and Atilla Kilicarslan
% Laboratory for Non Invasive Brain Machine Interface Systems
% University of Houston
% Written by: Justin Brantley
% 08/07/2019
function chanlocs = readcaptrak(filename)
% Parse xml
locs = [];
% Read xml file
xDoc = xmlread(filename);
% Get items based on tag
allListItems = xDoc.getElementsByTagName('CapTrakElectrode');
% Loop through all items
for ii=0:allListItems.getLength-1
    friendlyInfo = allListItems.item(ii).getChildNodes;
    childNode = friendlyInfo.getFirstChild;
    while ~isempty(childNode)
        nodename = childNode.getNodeName;
        nodename = nodename.toCharArray';
        if ~strcmp(nodename,'#text')
            val = childNode.getTextContent;
            if ~strcmp(nodename,'Name')
                val = str2double(childNode.getTextContent);
            else
                val = char(val);
            end
            locs(ii+1).(nodename) = val;
        end
        childNode = childNode.getNextSibling;
    end
end

% Modify structure to eeglab style
chanlocs(1:length(locs)) = struct('labels',[],'sph_theta_besa',[],...
                                  'sph_radius',[],'sph_phi_besa',[]);%,...
                                  %'X',[],'Y',[],'Z',[]);
% Loop through locs structure                              
for ii = 1:length(locs)
    % Find channel in neuroleg montage
    if strcmpi(locs(ii).Name,'Nasion')
        elecname = 'Nz';
    else
        elecname = locs(ii).Name;
    end
    idx = neuroleg_cap(elecname);
    % Sort by standard order
    chanlocs(idx).sph_theta_besa = locs(ii).Theta;
    chanlocs(idx).sph_radius = locs(ii).Radius;
    chanlocs(idx).sph_phi_besa = locs(ii).Phi;
    chanlocs(idx).labels = elecname;
    %chanlocs(idx).X = locs(ii).X;
    %chanlocs(idx).Y = locs(ii).Y;
    %chanlocs(idx).Y = locs(ii).Z;
end
% Convert  - can be changed to use whichever coordinate transform is
% preferred
chanlocs = convertlocs(chanlocs,'sphbesa2all');
chanlocs = rmfield(chanlocs,{'sph_phi_besa','sph_theta_besa'});
end

function idx = neuroleg_cap(label)
% Ref:
% actiCap montage: http://www.brainproducts.com/downloads.php?kid=8
% FT9 move to GND, AFz and FT10 move to Ref, FCz; ?? Check with Justin
% Captrack file didn't change FT9 to AFz and FT10 to FCz.
% Remove 4 channels for EOG in Captrak: PO9, PO10, TP9, TP10
actiCaplabel = {'Fp1','Fp2',...                 % Green label channel
    'F7','F3','Fz','F4','F8',...
    'FC5','FC1','FC2','FC6',...
    'T7','C3','Cz','C4','T8',...
    'CP5','CP1','CP2','CP6',...
    'P7','P3','Pz','P4','P8',...
    'O1','Oz','O2',...
    'AF7','AF3','AF4','AF8',...                 % Yellow label channel
    'F5','F1','F2','F6',...
    'FT9','FT7','FC3','FC4','FT8','FT10'...
    'C5','C1','C2','C6',...
    'TP7','CP3','CPz','CP4','TP8',...
    'P5','P1','P2','P6',...
    'PO7','PO3','POz','PO4','PO8',...
    'LPA','RPA','Nz'};                          % fiducial;
idx = find(ismember(lower(actiCaplabel),lower(label)));
end