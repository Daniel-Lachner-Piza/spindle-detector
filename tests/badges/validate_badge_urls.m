% BADGE_URL_VALIDATOR - Test script to validate badge URL formatting
%
% This script validates that badge URLs are properly formatted for GitHub display

function validate_badge_urls()
fprintf('=== BADGE URL VALIDATION ===\n');

% Test badge generation
test_badges = generate_test_badges();

% Parse badges to extract URLs
badge_lines = strsplit(test_badges, '\n');

for i = 1:length(badge_lines)
    line = badge_lines{i};
    if contains(line, 'img.shields.io')
        % Extract URL
        url_start = strfind(line, 'https://');
        url_end = strfind(line, '?style=');
        if ~isempty(url_start) && ~isempty(url_end)
            base_url = line(url_start:url_end-1);

            fprintf('Badge %d: %s\n', i, base_url);

            % Check for common encoding issues
            if contains(base_url, '%%')
                fprintf('  ⚠️  WARNING: Double percent encoding detected\n');
            else
                fprintf('  ✓ URL encoding looks correct\n');
            end
        end
    end
end

fprintf('\n=== VALIDATION COMPLETE ===\n');
end

function badges = generate_test_badges()
% Generate test badges with current formatting

badges = sprintf(['![Tests](https://img.shields.io/badge/tests-47%%2F47-brightgreen?style=flat&logo=checkmarx)\n' ...
    '![Test Status](https://img.shields.io/badge/test%%20status-100.0%%25%%20passing-brightgreen?style=flat&logo=github-actions)\n' ...
    '![Coverage](https://img.shields.io/badge/coverage-7%%20test%%20suites-blue?style=flat&logo=codecov)\n' ...
    '![Functions Tested](https://img.shields.io/badge/functions%%20tested-12%%2F12-brightgreen?style=flat&logo=matlab)\n' ...
    '![MATLAB](https://img.shields.io/badge/MATLAB-R2021b+-orange?style=flat&logo=mathworks)\n' ...
    '![Platform](https://img.shields.io/badge/platform-Windows-blue?style=flat&logo=windows)']);
end
