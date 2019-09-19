function [ Yn, Xnn ] = uhbmi_StateSpaceFilter( inData, A,B,C,D, Xnn )

%#codegen

[numDataPoints,numDataChannels] = size(inData);
Yn = zeros(size(inData));


for ti=1:numDataChannels
    for to=1:numDataPoints
        U=inData(to,ti);
        Xn1=A*Xnn(:,ti) + B*U;
        Yn(to,ti)=(C*Xnn(:,ti)+D*U)';
        Xnn(:,ti)=Xn1;
    end
end


end

