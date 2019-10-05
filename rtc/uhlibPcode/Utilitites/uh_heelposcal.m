function rheel = uh_heelposcal(kindata)
l1=332;
l2=391;
xp4=50;xp5=xp4;
yp4=-50;yp5=100;
h=deg2rad(kindata(:,1));
k=deg2rad(kindata(:,2));
a=deg2rad(kindata(:,3));
rheel=zeros(length(h),3);
for i=1:length(h)
    rheel(i,1)=yp4*cos(a(i) + h(i) + k(i)) + xp4*sin(a(i) + h(i) + k(i)) + l1*sin(h(i)) + l2*sin(h(i) + k(i));   %No changing sign of knee angles
    rheel(i,2)=yp4*sin(a(i) + h(i) + k(i)) - xp4*cos(a(i) + h(i) + k(i)) - l1*cos(h(i)) - l2*cos(h(i) + k(i));
    if rem(i,50000)==0
        fprintf('Heel Pos processing...%.2f...\n',i/length(h)*100);
    end
end