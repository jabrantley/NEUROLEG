function loaddata(self,varargin)
% If empty or all is specified, load all data
if any(strcmpi(varargin,'all')) || isempty(varargin)
    filetype = {'eeg','emg','opal','gonio','stimulus','chanlocs','impedance'};
else
    filetype = varargin;
end
% Check filetype for specified type
for ii = 1:length(filetype)
    % switch parameters
    switch lower(filetype{ii})
        case 'eeg'
            tempfile = fullfile(self.datadir,strjoin({self.subject,self.trial,'eeg.mat'},'-'));
            if exist(tempfile,'file')==2
                load(tempfile)
                self.eeg = EEG;
            end
        case 'emg'
            tempfile = fullfile(self.datadir,strjoin({self.subject,self.trial,'emg.mat'},'-'));
            if exist(tempfile,'file')==2
                load(tempfile)
                self.emg = EMG;
            end
        case 'opal'
            tempfile = fullfile(self.datadir,strjoin({self.subject,self.trial,'opal.mat'},'-'));
            if exist(tempfile,'file')==2
                load(tempfile)
                self.opal = OPAL;
            end
        case 'gonio'
            tempfile = fullfile(self.datadir,strjoin({self.subject,self.trial,'gonio.mat'},'-'));
            if exist(tempfile,'file')==2
                load(tempfile)
                self.gonio = GONIO;
            end
        case 'stimulus'
            tempfile = fullfile(self.datadir,strjoin({self.subject,self.trial,'stim.mat'},'-'));
            if exist(tempfile,'file')==2
                load(tempfile)
                self.stimulus = STIM;
            end
        case 'chanlocs'
            tempfile = fullfile(self.datadir,strjoin({self.subject,'chanlocs.mat'},'-'));
            if exist(tempfile,'file')==2
                load(tempfile)
                self.chanlocs = chanlocs;
            end
        case 'impedance'
            tempfile = fullfile(self.datadir,strjoin({self.subject,'impedance.mat'},'-'));
            if exist(tempfile,'file')==2
                load(tempfile)
                self.impedance = impedance;
            end
        case 'experimentlog'
            tempfile = fullfile(self.datadir,strjoin({self.subject,'experimentlog.pdf'},'-'));
            if exist(tempfile,'file')==2
                open(tempfile)
            end
        otherwise
    end % end switch
    
end % end for ii = 1:2:length(varargin)

end