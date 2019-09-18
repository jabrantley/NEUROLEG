function [sh,zh,Pt,WH]=uhbmi_HinfFilter(Yf, Rf, gamma, Pt, wh, q)

%#codegen

%warning off all
%Atilla Kilicarslan - 2014, 
%University of Houston, Non-Invasive Brain Machine Interfaces Laboratory



numTP  = size(Rf,1);
numDat = size(Yf,2);
numRef = size(Rf,2);

zh     = zeros(numTP,numDat);
sh     = zeros(numTP,numDat);
g      = zeros(numRef,1);

for n=1:numTP         
    r  = Rf(n,:)';
    Ptemp  = inv(Pt) - (gamma^(-2))*(r*r');    
    g(:,1) = (Ptemp\r)/(1+(r'/Ptemp)*r);
    for m=1:numDat          
        y           = Yf(n,m);
        zh(n,m)     = r'*wh(:,m);   
        sh(n,m)     = y-zh(n,m);   
        wh(:,m)     = wh(:,m) + g(:,1)*sh(n,m);        
    end 
    Pt          = inv (  (inv(Pt))+ ((1-gamma^(-2))*(r*r')) ) + q*eye(size(Rf,2));
    WH          = wh;
end

end





















    
    
        