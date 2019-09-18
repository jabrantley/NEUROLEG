classdef neuroleg_data < handle
    properties (SetAccess = private, GetAccess = public)
        
       
    end
    
    properties (SetAccess = public, GetAccess = public)
        data     % Data (chans x time) for consistency
        srate    % sampling rate in Hz
        filename  % filname using trial, subject, and type
    end
    
    methods (Access = public) 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                               %
        %          CONSTRUCTOR          %
        %                               %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function self = neuroleg_data(varargin) % Constructor
            if length(varargin)>=2
                for ii = 1:2:length(varargin)
                    % Get param
                    param=varargin{ii};
                    % Get value
                    val=varargin{ii+1};
                    % switch parameters
                    switch lower(param)
                        case 'subject'
                            subject = val;
                        case 'trial'
                            trial = val;
                        case 'datadir'
                            datadir = val;
                        otherwise
                    end % end switch
                    
                end % end for ii = 1:2:length(varargin)
                
            end % end if length(varargin)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                               %
        %          LOAD DATA            %
        %                               %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
                    case 'jointangles'
                        tempfile = fullfile(self.datadir,strjoin({self.subject,self.trial,'jointangles.mat'},'-'));
                        if exist(tempfile,'file')==2
                            load(tempfile)
                            self.jointangles = jointangles;
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
        
        
    end
end


% For later source analysis:
% https://neuroimage.usc.edu/forums/t/fmri-constrained-eeg-source-analysis-by-brainstorm/1540/2
