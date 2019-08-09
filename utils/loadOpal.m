function opaldata = loadOpal(filename)
% Get case ID
caseIdList = hdf5read(filename, '/CaseIdList');
% Get time vector
time = hdf5read(filename, [caseIdList(1).data, '/Time']);
% Get triggers
annotations = hdf5read(filename, '/Annotations');
triggers(1:length(annotations)) = struct('label',[],'time',[]);
for ii = 1:length(annotations)
    triggers(ii).label = annotations(ii).data{1,3}.Data;
    triggers(ii).time  = double(annotations(ii).data{1,1});
end
% Preallocate
acc = cell(length(caseIdList),1); 
gyr = cell(length(caseIdList),1); 
mag = cell(length(caseIdList),1); 
id =  cell(length(caseIdList),1);
% Get data
for ii = 1:length(caseIdList)
    acc{ii} = hdf5read(filename, [caseIdList(ii).data, '/Calibrated', '/Accelerometers'])';
    gyr{ii} = hdf5read(filename, [caseIdList(ii).data, '/Calibrated', '/Gyroscopes'])';
    mag{ii} = hdf5read(filename, [caseIdList(ii).data, '/Calibrated', '/Magnetometers'])';
    id{ii}  =  caseIdList(ii).data;
end
% Output opal data
opaldata = struct('time',[],'acc',[],'gyr',[],'mag',[],'id',[],...
                  'triggers',[]);
% Cast to structure
opaldata.time     = double(time);
opaldata.acc      = acc;
opaldata.gyr      = gyr;
opaldata.mag      = mag;
opaldata.id       = id;
opaldata.triggers = triggers;
end