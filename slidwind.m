function [avg_sig]=slidwind(sig,wind_width)

% Perform sliding window average of a vector of values

w=ones(1,wind_width)/wind_width;

avg_sig=conv(sig,w,'same');

end