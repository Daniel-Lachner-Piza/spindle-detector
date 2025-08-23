function propagation_nr = extract_propagation_nr(comments)
% The comments contain feature values characterizing each event. Each feature values is separated by a comma.
% The propagation_nr is the last numeric value.

% Vectorized approach using cellfun and string operations
% Split all comments at once and extract last numeric value
split_comments = cellfun(@(x) strsplit(x, ','), comments, 'UniformOutput', false);
last_values = cellfun(@(x) x{end}, split_comments, 'UniformOutput', false);
propagation_nr = str2double(last_values);
propagation_nr = propagation_nr(:); % Ensure column vector

assert(sum(isnan(propagation_nr))==0, "Found NaN values in propagation_nr");
end