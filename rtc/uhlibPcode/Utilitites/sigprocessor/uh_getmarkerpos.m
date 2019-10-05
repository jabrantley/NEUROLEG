function markerpos = uh_getmarkerpos(markertime,timeline)
markerpos=zeros(1,length(markertime));
k=1;
for i=1:length(markertime)
    for j=k:length(timeline)
        if timeline(j)>=markertime(i)                     
            markerpos(i)=j;
            k=j;
            break;        
        end
    end
end
% if markerpos(end)==0
%     markerpos(end) = [];    %Last markertime > timeline(end)
% end