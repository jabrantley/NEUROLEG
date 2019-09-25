% This function is used to align the data based on trigger pulse train
%
% University of Houston, Non-Invasive Brain Machine Interfaces Laboratory
% Written by: Justin Brantley - justin.a.brantley@gmail.com
% 09/24/2019: Date created
function [out1, out2] = align_data(in1,marker1,in2,marker2,other_data)

% Rescale marker data
marker1 = rescale_data(marker1);
marker2 = rescale_data(marker2);

% Get length of shorter vector
minPoints =  min([length(marker1),length(marker2)]);

% Compute cross correlation
[xcvalue,xclag] = xcorr(marker1,marker2)

end