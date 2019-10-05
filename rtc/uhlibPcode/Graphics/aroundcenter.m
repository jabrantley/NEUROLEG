function xposout=aroundcenter(xcenterin,numcols,dx)
% This function generate n pos around center with the gap dx;
% check number of columns is odd;
xposout=[];
for ncenter=1:length(xcenterin)
    xcenter=xcenterin(ncenter);
    xid=[];
    if mod(numcols,2)==1        % If number of columns is odd number
        idcenter=ceil(numcols/2);
        k=0;                    % Left side;
        for i=idcenter:-1:1
            xid(i)=xcenter-k*dx;k=k+1;
        end
        k=1;                    % Right side
        for i=idcenter+1:numcols
            xid(i)=xcenter+k*dx;k=k+1;
        end
    else
        idcenterlow=numcols/2;idcenterhigh=idcenterlow+1;
        k=0;
        for i=idcenterlow:-1:1
            xid(i)=xcenter-1/2*dx-k*dx;k=k+1;
        end
        k=0;
        for i=idcenterhigh:numcols
            xid(i)=xcenter+1/2*dx+k*dx;k=k+1;
        end
    end
    xposout=[xposout xid];
end