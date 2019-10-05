function color=str2color(str)
if strcmpi(str,'r')
    color=[1 0 0];
elseif strcmpi(str,'g')
    color=[0 1 0];
elseif strcmpi(str,'b')
    color=[0 0 1];
elseif strcmpi(str,'c')
    color=[0 1 1];
elseif strcmpi(str,'y')
    color=[1 1 0];
elseif strcmpi(str,'m')
    color=[1 0 1];
elseif strcmpi(str,'k')
    color=[0 0 0];
elseif strcmpi(str,'w')
    color=[1 1 1];
end