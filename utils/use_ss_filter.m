function [filt_mat,xn_out] = use_ss_filter(obj,dataIn,Xn0)
A = obj.A;
B = obj.B;
C = obj.C;
D = obj.D;

filt_mat = zeros(length(dataIn),1);
for ii = 1 : length(dataIn)
    u = dataIn(ii);
    Xn1 = A*Xn0+B*u;
    ytemp = C*Xn0+D*u;
    filt_mat(ii) = ytemp;
    Xn0 = Xn1;
end
xn_out = Xn0;

end