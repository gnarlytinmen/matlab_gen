function [out]=breakstring(string_in,num_char)

% Splits an input string into a 1xn cell array where 
% n=(characters in string)/(num_char)

out = regexp(string_in, sprintf('\\w{1,%d}', num_char), 'match');
out{1,1} = out{1,1}'

end