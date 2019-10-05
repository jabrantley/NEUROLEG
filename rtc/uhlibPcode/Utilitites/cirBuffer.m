%% cirBuffer.m
%% *Description:*
%% *Usages:*
%
% *Inputs:*
% 
% *Outputs:*
% 
% *Options:*
% 
% *Notes:*
%
%% *Authors:*
% * *MATLAB Ver :* 9.0.0.341360 (R2016a)
% * *Date Created :* 31-Jul-2017 15:11:05
% * *Author:* Phat Luu. ptluu2@central.uh.edu
%
% _Laboratory for Noninvasive Brain Machine Interface Systems._
% 
% _University of Houston_
% 

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%%
classdef cirBuffer < hgsetget;
    properties (SetAccess = public, GetAccess = public)
        size;
        data;
        meanVal;        
        currVal;
    end
    methods (Access = public) %Constructor
        function this = cirBuffer(varargin)
            this.size = get_varargin(varargin,'size',4);
            this.data = zeros(1,this.size);
            this.getMean;
        end
        function getMean(this)
            this.meanVal = mean(this.data);
        end
        function append(this,newSample)
            temp = this.data;
            this.data(1:end-1) = temp(2:end);            
            this.data(end) = newSample; % append to the last data.
            this.getMean;
        end
        function getLast(this)
            this.currVal = this.data(end);
        end
        function checkval = isAscend(this)
            % Check if all of the elements in the buffer is ascending
            checkval = 1;
            for i = 1 : length(this.data)-1
                if this.data(i) >= this.data(i+1)
                    checkval = 0;
                    break;
                end                
            end            
        end
        function checkval = isDescend(this)            
            checkval = 1;
            for i = 1: length(this.data)-1
                if this.data(i) <= this.data(i+1)
                    checkval = 0;
                    break;
                end                
            end            
        end
        function checkval = isZeroCros(this)
            checkval = 0;
            if this.data(end-1)*this.data(end) <=0
                checkval = 1;
            end
        end
    end
    methods (Static)
    end
    methods (Access = private) %Destructor
        function delete(this) % Delete obj.
        end
    end
end
