function obj = make_ss_filter(filt_order,filt_freq,srate,filttype)
[z,p,k] = butter(filt_order,filt_freq/(srate/2),filttype);
[sos,g] = zp2sos(z,p,k);
h = dfilt.df2sos(sos,g);
[A,B,C,D] = ss(h);
obj = struct('A',A,'B',B,'C',C,'D',D,'filt',h);
end