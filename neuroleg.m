classdef neuroleg < handle
    properties (SetAccess = private, GetAccess = public)
        
        
    end
    
    properties (SetAccess = public, GetAccess = public)
        subject        % Subject name
        trial          % Trial name
        eeg            % EEG data in eeglab struct
        emg            % EMG data including muscle names and data
        opal           % OPAL data based on where sensor was placed
        gonio          % Gonio data including joint name and data
        jointangles    % Joint angles computed from Deeplabcut
        stimulus       % Psychtoolbox-based stimulus protocol
        chanlocs       % Channel locations structure
        impedance      % Channel impedance before and after
        experimentlog  % A PDF showing experiment notes
        datadir        % Directory for data
    end
    
    methods (Access = public)
        function self = neuroleg(varargin) % Constructor
            if length(varargin)>=2
                for ii = 1:2:length(varargin)
                    % Get param
                    param=varargin{ii};
                    % Get value
                    val=varargin{ii+1};
                    % switch parameters
                    switch lower(param)
                        case 'subject'
                            self.subject = val;
                        case 'trial'
                            self.trial = val;
                        case 'datadir'
                            self.datadir = val;
                        otherwise
                    end % end switch
                end % end for ii = 1:2:length(varargin)
            end % end if length(varargin)
            self.eeg = neuroleg_data
            
        end
        
    end
end


% For later source analysis:
% https://neuroimage.usc.edu/forums/t/fmri-constrained-eeg-source-analysis-by-brainstorm/1540/2
