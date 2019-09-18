classdef eeg_data < neuroleg_data
    properties (SetAccess = private, GetAccess = public)
        
       
    end
    
    properties (SetAccess = public, GetAccess = public)
        chanlocs % chanloc structure
        event    % 
        eogdata
    end
    
    methods (Access = public) 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                               %
        %          CONSTRUCTOR          %
        %                               %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function self = eeg_data(varargin) % Constructor
            
        end
        
    end
end


% For later source analysis:
% https://neuroimage.usc.edu/forums/t/fmri-constrained-eeg-source-analysis-by-brainstorm/1540/2
