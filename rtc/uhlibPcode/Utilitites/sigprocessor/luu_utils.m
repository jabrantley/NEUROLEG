%% luu_utils.m
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
% * *MATLAB Ver :* 9.3.0.713579 (R2017b)
% * *Date Created :* 30-Jan-2019 20:47:00
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
classdef luu_utils < hgsetget;
    %======================
    methods (Static)
        function output = is_var_exist(varname)
            cmdstr = sprintf('evalin(''base'',''exist(''''%s'''')'')',varname);
            output = eval(cmdstr);
        end
        function output = get_last(a)
            output = a(end);
        end
        function output = replace_nan(inputMat,varargin)
            [stacktrace, ~]=dbstack;
            thisFuncName = stacktrace(1).name;
            fprintf('====Running: %s \n', thisFuncName);
            method = get_varargin(varargin,'method','linear');
            % Input is a matrix with column format
            nb_col = size(inputMat,2);
            output = nan(size(inputMat));
            for i = 1 : nb_col
                thisCol = inputMat(:,i);
                output(:,i) = fillmissing(thisCol, method);
            end            
        end        
        function plt_trigger(xdata, varargin)
            [stacktrace, ~]=dbstack;
            thisFuncName = stacktrace(1).name;
            fprintf('====Running: %s \n', thisFuncName);
            ax = get_varargin(varargin,'axes',gca);
            linestyle = get_varargin(varargin,'linestyle','-');
            linecolor = get_varargin(varargin,'linecolor','r');
            linewidth = get_varargin(varargin,'linewidth',0.5);            
            for i = 1 : length(xdata)                                         
                line('XData',xdata(i).*[1 1], 'YData', get(gca,'ylim'),...
                    'linestyle',linestyle,'color',linecolor,'linewidth',linewidth);
            end
        end
        function output = lowpass(signal, varargin)
            [stacktrace, ~]=dbstack;
            thisFuncName = stacktrace(1).name;
            fprintf('====Running: %s \n', thisFuncName);
            Fs = get_varargin(varargin,'fs',100);
            cutoff = get_varargin(varargin,'cutoff',6);
            fn = Fs/2;
            [A,B,C,D] = butter(4,cutoff/fn,'low'); %Define butter filter
            [b,a] = ss2tf(A,B,C,D);
            output = filtfilt(b,a,signal);       
            fprintf('DONE: %s \n', thisFuncName);
        end
        function HC_event = detect_heelcontact(inputData, varargin)
            [stacktrace, ~]=dbstack;
            thisFuncName = stacktrace(1).name;
            fprintf('====Running: %s \n', thisFuncName);
            buffer_size = get_varargin(varargin, 'buffersize',4);
            threshold = get_varargin(varargin, 'threshold',20);
            feature = get_varargin(varargin, 'feature','kneeangles');
            buff = cirBuffer('size', buffer_size);
            HC_catch = false;
            k = 1;
            HC_event = [];
            if strcmpi(feature,'kneeangles')
                for i = 1 : length(inputData)
                    sample = inputData(i);
                    buff.append(sample)
                    if HC_catch == false
                        if (buff.meanVal > threshold && buff.isDescend)
                            HC_catch = true;
                        end
                    else
                        if (buff.isAscend)
                            HC_event(k) = i;
                            k = k + 1;
                            HC_catch = false;
                        end
                    end
                end
            end
            fprintf('DONE: %s \n', thisFuncName);
        end
        function output = gait_segment(inputData,hc_event,varargin)
            [stacktrace, ~]=dbstack;
            thisFuncName = stacktrace(1).name;
            fprintf('====Running: %s \n', thisFuncName);
            sync_event = get_varargin(varargin,'sync',[]);
            % InputData in column format
            [npts, nb_chans] = size(inputData);            
            output = {};
            if isempty(sync_event)
                for i = 1 : nb_strides-1                    
                    output{i} = inputData(hc_event(i):hc_event(i+1),:);
                end
            else
                for i = 1 : length(sync_event)-1                    
                    step = 1;
                    fprintf('Group GC between frames: %.0f - %.0f \n',...
                        sync_event(i), sync_event(i+1));
                    for j = 1 : length(hc_event)-1
                        if hc_event(j) > sync_event(i) && hc_event(j+1) < sync_event(i+1)
                            fprintf('Heel contact step %d: %.0f-%.0f \n',step, hc_event(j),hc_event(j));
                            output{i}{step} = inputData(hc_event(j):hc_event(j+1),:);
                            step = step + 1;
                        else                                                        
                        end
                    end
                end
            end                                    
            fprintf('DONE: %s \n', thisFuncName);
        end
        function output = compute_ROM(cellData,varargin)            
            [stacktrace, ~]=dbstack;
            thisFuncName = stacktrace(1).name;
            fprintf('====Running: %s \n', thisFuncName);
            % ====START====
            sel_col = get_varargin(varargin, 'idx',1);
            % Input CellData comprise data of n-steps in the trial
            romVal = [];
            for i = 1 : length(cellData)
                matData = cellData{i};
                colData = matData(:,sel_col);
                romVal(i) = max(colData) - min(colData);
            end
            output = romVal;
        end
    end
end
