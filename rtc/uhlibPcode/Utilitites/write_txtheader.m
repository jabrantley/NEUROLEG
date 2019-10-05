function write_txtheader(fid,varargin)
info = get_varargin(varargin,'info','');
filename = fopen(fid);
if ~isempty(strfind(filename,'eeg'))
    fprintf(fid,'Brain Products: 64 Channel Active EEG data.\n');
elseif ~isempty(strfind(filename,'kinematics'))
    if isempty(info)
        fprintf(fid,'Biometrics Data: RH RK RA LH LK LA.\n');
    else
        fprintf(fid,'Biometrics Data: ');
        for i = 1:length(info.isused)
            if strcmpi(info.isused{i},'1');
                fprintf(fid,'%s ',info.label{i});
            end
        end
        fprintf('\n');
    end
end