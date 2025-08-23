function bp_power = extract_bp_power(comments)
% The comments contain feature values characterizing each event. Each feature values is separated by a comma.
% The bp-power is the first numeric value.

% Vectorized approach using cellfun and string operations
% Split all comments at once and extract first numeric value
split_comments = cellfun(@(x) strsplit(x, ','), comments, 'UniformOutput', false);
first_values = cellfun(@(x) x{1}, split_comments, 'UniformOutput', false);
bp_power = str2double(first_values);
bp_power = bp_power(:); % Ensure column vector

assert(sum(isnan(bp_power))==0, "Found NaN values in bp_power");
end