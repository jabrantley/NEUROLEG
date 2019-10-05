function [opal,conductor]=GaitCycleSegmentFcn(opal,conductor,varargin)
global gvar
gvar=def_gvar;
selleg = get_varargin(varargin,'leg','both');
%=================================GAIT SEGMENTATION===============
useopal=0;
kinematics=evalin('base','kinematics');
if isfield(opal,'opalTrig') && useopal==1 %If opal data recorded. Some exps failed recording opal
    opaltime=uint64(opal.opalTime);
    opaltrig=uint64(opal.opalTrig);
    opalmark=markerpos_def(opaltrig(1:2:end),opaltime);
    opaltrigtime=opal.TriggerTime;
    %     if length(opaltrig)>4
    %         opalmark(end)=[];
    %         opaltrigtime(end)=[];
    %     else
    %     end
    if numel(find(opalmark==0))>=1
        fprintf('Missing Opal data. Skip Gait Segmentation. \n');
        opal.opalLeft=[];
        opal.opalRight=[];
        conductor.timelineOpal=[];
        conductor.rfullgctime=[];
        conductor.lfullgctime=[];
    elseif numel(opalmark)==1
        fprintf('Missing Opal Trigger. Skip Gait Segmentation. \n');
        opal.opalLeft=[];
        opal.opalRight=[];
        conductor.timelineOpal=[];
        conductor.rfullgctime=[];
        conductor.lfullgctime=[];
    else
        if opaltrigtime(end-1)==opaltrigtime(end)
            opalmark(end)=[];
        else
        end
        timelineOpal=linspace(opaltrigtime(1),opaltrigtime(end),...
            opalmark(end)-opalmark(1)+1);
        for i=1:size(opal.opalRight,1)
            %bandpass filter to remove drift
            opalrighti=butterfilt(2,100,[0.1 10],'bandpass',opal.opalRight(i,:));
            opallefti=butterfilt(2,100,[0.1 10],'bandpass',opal.opalLeft(i,:));
            if i==2
                opalrighti=-opalrighti;
                opallefti=-opallefti;
            end
            opalRight(i,:)=opalrighti;
            opalLeft(i,:)=opallefti;
        end
        opalLeft=opalLeft(:,opalmark(1):opalmark(end));
        opalRight=opalRight(:,opalmark(1):opalmark(end));
        % Compute velocity profile
        rvecy=100*cumtrapz(detrend(opalRight(2,:),'constant'))/gvar.Fs;
        rvecz=100*cumtrapz(detrend(opalRight(3,:),'constant'))/gvar.Fs;
        lvecy=100*cumtrapz(detrend(opalLeft(2,:),'constant'))/gvar.Fs;
        lvecz=100*cumtrapz(detrend(opalLeft(3,:),'constant'))/gvar.Fs;
        rheelstrike=uh_windowpeak(rvecz,'winsize',10*gvar.Fs,'minpeakopt','meanpeak');
        rtoeoff=uh_windowpeak(rvecy,'winsize',10*gvar.Fs,'minpeakopt','meanpeak');
        lheelstrike=uh_windowpeak(lvecz,'winsize',10*gvar.Fs,'minpeakopt','meanpeak');
        ltoeoff=uh_windowpeak(lvecy,'winsize',10*gvar.Fs,'minpeakopt','meanpeak');
        %         fidltoeoff=1; %start search values for ltoeoff, lheelstrike and rtoeoff
        %         fidlheelstrike=1;
        %         fidrtoeoff=1;
        fullgc=[];
        gcid=1;
        for gc=1:length(rheelstrike)-1
            thisltoeoff=find(ltoeoff>=rheelstrike(gc),1,'first');
            thislheelstrike=find(lheelstrike>=rheelstrike(gc),1,'first');
            thisrtoeoff=find(rtoeoff>=rheelstrike(gc),1,'first');
            thisfullgc=[rheelstrike(gc) ltoeoff(thisltoeoff) lheelstrike(thislheelstrike) rtoeoff(thisrtoeoff) rheelstrike(gc+1)];
            %test sequence condition rhs lto lhs rto rhs
            seqtest=diff(thisfullgc);
            if ~isempty(find(seqtest<=0)) || length(seqtest) ~=4
                % Gait sequence failed
                fprintf('Failed at GC: %d. Time: %.2f\n',gc,timelineOpal(rheelstrike(gc)));
                seqtest
            else
                fullgc(gcid,:)=thisfullgc;
                gcid=gcid+1;
            end
            if mod(gc,100)==0
                fprintf('Processing Right Gait Segmentation: %.2f %%.\n',gc*100/length(rheelstrike))
            end
        end
        % test cadence outlier
        cadence=fullgc(:,end)-fullgc(:,1); %from rhs to rhs;
        %         fullgc(uh_getoutlierwindow(cadence,'winsoze',10,'Fs',1),:)=[];
        rfullgctime=[];
        for gc=1:size(fullgc,1)
            for s=1:size(fullgc,2)
                rfullgctime(gc,s)=timelineOpal(fullgc(gc,s));
            end
        end
        % Remove mis detection during rest periods.
        firstrest=find(rfullgctime(:,1)<=120);
        secondrest=find(rfullgctime(:,end)>=timelineOpal(end)-120);
        rfullgctime([firstrest;secondrest],:)=[];
        % for left leg
        fullgc=[];
        gcid=1;
        for gc=1:length(lheelstrike)-1
            thisrtoeoff=find(rtoeoff>=lheelstrike(gc),1,'first');
            thisrheelstrike=find(rheelstrike>=lheelstrike(gc),1,'first');
            thisltoeoff=find(ltoeoff>=lheelstrike(gc),1,'first');
            thisfullgc=[lheelstrike(gc) rtoeoff(thisrtoeoff) rheelstrike(thisrheelstrike) ltoeoff(thisltoeoff) lheelstrike(gc+1)];
            %test sequence condition rhs lto lhs rto rhs
            seqtest=diff(thisfullgc);
            if ~isempty(find(seqtest<=0)) || length(seqtest) ~=4
                % Gait sequence failed
            else
                fullgc(gcid,:)=thisfullgc;
                gcid=gcid+1;
            end
            if mod(gc,100)==0
                fprintf('Processing Left Gait Segmentation: %.2f %%.\n',gc*100/length(rheelstrike))
            end
        end
        % test cadence outlier
        cadence=fullgc(:,end)-fullgc(:,1); %from rhs to rhs;
        %         fullgc(uh_getoutlierwindow(cadence,'winsoze',10,'Fs',1),:)=[];
        lfullgctime=[];
        for gc=1:size(fullgc,1)
            for s=1:size(fullgc,2)
                lfullgctime(gc,s)=timelineOpal(fullgc(gc,s));
            end
        end
        firstrest=find(lfullgctime(:,1)<=120);
        secondrest=find(lfullgctime(:,end)>=timelineOpal(end)-120);
        lfullgctime([firstrest;secondrest],:)=[];
        
        opal.rheelstrike=timelineOpal(rheelstrike);
        opal.rtoeoff=timelineOpal(rtoeoff);
        opal.lheelstrike=timelineOpal(lheelstrike);
        opal.ltoeoff=timelineOpal(ltoeoff);
        opal.rvecy=rvecy;opal.rvecz=rvecz;
        opal.lvecy=lvecy;opal.lvecz=lvecz;
        conductor.timelineOpal=timelineOpal;
        conductor.rfullgctime=rfullgctime;
        conductor.lfullgctime=lfullgctime;        
    end
else
    if strcmpi(selleg,'both')
        timelineOpal=conductor.timelineKin;
        rz=kinematics.rheelpos.subject(:,1);rvecz=[0; diff(rz)]*gvar.Fs/10;
        ry=kinematics.rheelpos.subject(:,2);rvecy=[0; diff(ry)]*gvar.Fs/10;
        lz=kinematics.lheelpos.subject(:,1);lvecz=[0; diff(lz)]*gvar.Fs/10;
        ly=kinematics.lheelpos.subject(:,2);lvecy=[0; diff(ly)]*gvar.Fs/10;
        rtoeoff = uh_windowpeak(rvecy,'winsize',10*gvar.Fs,'minpeakopt','meanpeak');
        ltoeoff = uh_windowpeak(lvecy,'winsize',10*gvar.Fs,'minpeakopt','meanpeak');
        rheelstrike = uh_dynamicwindowpeak(-rvecz,'winref',rtoeoff,'minpeakopt','zero','selpeak',1);
        lheelstrike = uh_dynamicwindowpeak(-lvecz,'winref',ltoeoff,'minpeakopt','zero','selpeak',1);
        
        fullgc=[];
        gcid=1;
        for gc=1:length(rheelstrike)-1
            thisltoeoff=find(ltoeoff>=rheelstrike(gc),1,'first');
            thislheelstrike=find(lheelstrike>=rheelstrike(gc),1,'first');
            thisrtoeoff=find(rtoeoff>=rheelstrike(gc),1,'first');
            thisfullgc=[rheelstrike(gc) ltoeoff(thisltoeoff) lheelstrike(thislheelstrike) rtoeoff(thisrtoeoff) rheelstrike(gc+1)];
            %test sequence condition rhs lto lhs rto rhs
            seqtest=diff(thisfullgc);
            if ~isempty(find(seqtest<=0)) || length(seqtest) ~=4
                % Gait sequence failed
                fprintf('Failed at GC: %d. Time: %.2f\n',gc,timelineOpal(rheelstrike(gc)));
                seqtest
            else
                fullgc(gcid,:)=thisfullgc;
                gcid=gcid+1;
            end
            if mod(gc,100)==0
                fprintf('Processing Right Gait Segmentation: %.2f %%.\n',gc*100/length(rheelstrike))
            end
        end
        % test cadence outlier
        rfullgctime=[];
        for gc=1:size(fullgc,1)
            for s=1:size(fullgc,2)
                rfullgctime(gc,s)=timelineOpal(fullgc(gc,s));
            end
        end
        % Remove mis detection during rest periods.
        firstrest=find(rfullgctime(:,1)<=120);
        secondrest=find(rfullgctime(:,end)>=timelineOpal(end)-120);
        rfullgctime([firstrest;secondrest],:)=[];
        % for left leg
        fullgc=[];
        gcid=1;
        for gc=1:length(lheelstrike)-1
            thisrtoeoff=find(rtoeoff>=lheelstrike(gc),1,'first');
            thisrheelstrike=find(rheelstrike>=lheelstrike(gc),1,'first');
            thisltoeoff=find(ltoeoff>=lheelstrike(gc),1,'first');
            thisfullgc=[lheelstrike(gc) rtoeoff(thisrtoeoff) rheelstrike(thisrheelstrike) ltoeoff(thisltoeoff) lheelstrike(gc+1)];
            %test sequence condition rhs lto lhs rto rhs
            seqtest=diff(thisfullgc);
            if ~isempty(find(seqtest<=0)) || length(seqtest) ~=4
                % Gait sequence failed
            else
                fullgc(gcid,:)=thisfullgc;
                gcid=gcid+1;
            end
            if mod(gc,100)==0
                fprintf('Processing Left Gait Segmentation: %.2f %%.\n',gc*100/length(lheelstrike))
            end
        end
        % test cadence outlier
        lfullgctime=[];
        for gc=1:size(fullgc,1)
            for s=1:size(fullgc,2)
                lfullgctime(gc,s)=timelineOpal(fullgc(gc,s));
            end
        end
        firstrest=find(lfullgctime(:,1)<=120);
        secondrest=find(lfullgctime(:,end)>=timelineOpal(end)-120);
        lfullgctime([firstrest;secondrest],:)=[];
        opal.rheelstrike=timelineOpal(rheelstrike);
        opal.rtoeoff=timelineOpal(rtoeoff);
        opal.lheelstrike=timelineOpal(lheelstrike);
        opal.ltoeoff=timelineOpal(ltoeoff);
        opal.rz=rz;opal.ry=ry;
        opal.lz=lz;opal.ly=ly;
        opal.rvecy=rvecy;opal.rvecz=rvecz;
        opal.lvecy=lvecy;opal.lvecz=lvecz;
        conductor.timelineOpal=timelineOpal;
        conductor.rfullgctime=rfullgctime;
        conductor.lfullgctime=lfullgctime;
    elseif strcmpi(selleg,'right')
        timelineOpal=conductor.timelineKin;
        rz=kinematics.rheelpos.subject(:,1);rvecz=[0; diff(rz)]*gvar.Fs/10;
        ry=kinematics.rheelpos.subject(:,2);rvecy=[0; diff(ry)]*gvar.Fs/10;
       
        rtoeoff = uh_windowpeak(rvecy,'winsize',10*gvar.Fs,'minpeakopt','meanpeak');
        rheelstrike = uh_dynamicwindowpeak(-rvecz,'winref',rtoeoff,'minpeakopt','zero','selpeak',1);
        
        fullgc=[];
        gcid=1;
        for gc=1:length(rheelstrike)-1
            
            thisrtoeoff=find(rtoeoff>=rheelstrike(gc),1,'first');
            thisfullgc=[rheelstrike(gc) rtoeoff(thisrtoeoff) rheelstrike(gc+1)];
            %test sequence condition rhs lto lhs rto rhs
            seqtest=diff(thisfullgc);
            if ~isempty(find(seqtest<=0)) || length(seqtest) ~=2
                % Gait sequence failed
                fprintf('Failed at GC: %d. Time: %.2f\n',gc,timelineOpal(rheelstrike(gc)));
                seqtest
            else
                fullgc(gcid,:)=thisfullgc;
                gcid=gcid+1;
            end
            if mod(gc,100)==0
                fprintf('Processing Right Gait Segmentation: %.2f %%.\n',gc*100/length(rheelstrike))
            end
        end
        % test cadence outlier
        rfullgctime=[];
        for gc=1:size(fullgc,1)
            for s=1:size(fullgc,2)
                rfullgctime(gc,s)=timelineOpal(fullgc(gc,s));
            end
        end
        % Remove mis detection during rest periods.
        firstrest=find(rfullgctime(:,1)<=120);
        secondrest=find(rfullgctime(:,end)>=timelineOpal(end)-120);
        rfullgctime([firstrest;secondrest],:)=[];
            
        opal.rheelstrike=timelineOpal(rheelstrike);
        opal.rtoeoff=timelineOpal(rtoeoff);        
        opal.rz=rz;opal.ry=ry;        
        opal.rvecy=rvecy;opal.rvecz=rvecz;        
        conductor.timelineOpal=timelineOpal;
        conductor.rfullgctime=rfullgctime;        
    end
end

function [heelLocation, toeLocation]=findheeltoe(opalLeg, opalindex)
global gvar;
indexOpalSample=opalindex;
heelLocation = uh_windowpeak(-opalLeg(3,indexOpalSample(1):indexOpalSample(2)),'winsize',20*gvar.Fs,'minpeakopt','meanpeak');
toeLocation = uh_windowpeak(opalLeg(2,indexOpalSample(1):indexOpalSample(2)),'winsize',20*gvar.Fs,'minpeakopt','meanpeak');
toeLocation = toeLocation + indexOpalSample(1,1);
heelLocation = heelLocation + indexOpalSample(1,1);
%Find Peaks- Gait Phase Markers
%Identifiers for peaks - RIGHT: The const values are subject-specific
% toePhase = 150;         %Number of data points between peaks.           Sub2: 150
% toeAmplitude = 5;       %Threshold for minimum peak height in m/s^2.    Sub2: 5
% heelPhase = 40;         %Number of data points between peaks.           Sub2: 30
% heelAmplitude = 2.0;    %Threshold for minimum peak height in m/s^2.   Sub2: 1.65
% heelRangeTop = 75;      %Top of toe-off buffer range in data points.    Sub2: 75
% heelRangeBottom = 40;   %Bottom of toe-off buffer range in data points. Sub2: 35

% [toePeak,toeLocation]= findpeaks(opalLeg(2,indexOpalSample(1):indexOpalSample(2)),'MinPeakDistance',toePhase,'MinPeakHeight',toeAmplitude);
% toeLocation = toeLocation - 1; %shift by one to account for index starting at 0.
% [heelPeak_temp, heelLocation_temp] = findpeaks(-opalLeg(3,indexOpalSample(1):indexOpalSample(2)),'MinPeakDistance',heelPhase,'MinPeakHeight',heelAmplitude);
%Fine tune
%Determine if heel or toe comes first in the data set, check to see if it
%falls outside of the toe-off buffer zone.
% for n=1:length(heelPeak_temp)
%     if toeLocation(1)>heelLocation_temp(n)
%         if ((toeLocation(1)-heelLocation_temp(n))>heelRangeBottom)&&((-toeLocation(2)+heelRangeTop)<heelLocation_temp(n))
%             heelLocation = heelLocation_temp(n);
%             heelPeak = heelPeak_temp(n);
%             n=n+1;
%             break;
%         end
%     elseif (heelLocation_temp(n)-toeLocation(1))>heelRangeTop
%         heelLocation = heelLocation_temp(n);
%         heelPeak = heelPeak_temp(n);
%         n=n+1;
%         break;
%     end
% end
% %Check if detected heel strike peaks fall outside of the toe-off buffer
% %zone.
% for m=n:length(heelPeak_temp)
%     minPosition = heelLocation_temp(m)-heelRangeBottom;
%     maxPosition = heelLocation_temp(m)+heelRangeTop;
%     index = find(toeLocation>minPosition & toeLocation<maxPosition);
%     if (isempty(index)== true)|| (index == 0)
%         heelLocation = [heelLocation (heelLocation_temp(m)-1)];
%         heelPeak = [heelPeak heelPeak_temp(m)];
%     end
%     index = 0;
% end
% toeLocation = toeLocation + indexOpalSample(1,1);
% heelLocation = heelLocation + indexOpalSample(1,1);