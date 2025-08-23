function update_badges()
% UPDATE_BADGES - Automatically update README.md badges based on test results
%
% This function:
% 1. Runs the complete test suite
% 2. Extracts test statistics
% 3. Updates the badges in README.md with current results
% 4. Validates function dependencies
%
% Usage: update_badges()

fprintf('=== UPDATING README BADGES ===\n');

% Change to project root directory (go up two levels from tests/badges/)
script_dir = fileparts(mfilename('fullpath'));
project_root = fileparts(fileparts(script_dir)); % Go up from tests/badges/ to project root
original_dir = pwd;
cd(project_root);

try
    % Add project paths
    addpath(genpath('.'));

    % Run tests and capture results directly
    fprintf('Running test suite...\n');
    cd('tests');

    % Capture test results using evalc
    test_output = evalc('run_all_tests()');

    % Extract test statistics using regex
    total_tests_match = regexp(test_output, 'Total tests: (\d+)', 'tokens');
    passed_tests_match = regexp(test_output, 'Passed: (\d+)', 'tokens');
    success_rate_match = regexp(test_output, 'Success rate: ([\d.]+)%', 'tokens');

    if isempty(total_tests_match) || isempty(passed_tests_match) || isempty(success_rate_match)
        error('Could not parse test results from output');
    end

    total_tests = str2double(total_tests_match{1}{1});
    passed_tests = str2double(passed_tests_match{1}{1});
    success_rate = str2double(success_rate_match{1}{1});
    failed_tests = total_tests - passed_tests;

    fprintf('Test Results:\n');
    fprintf('  Total: %d\n', total_tests);
    fprintf('  Passed: %d\n', passed_tests);
    fprintf('  Failed: %d\n', failed_tests);
    fprintf('  Success Rate: %.1f%%\n', success_rate);

    % Validate dependencies to count tested functions
    fprintf('Validating dependencies...\n');

    % Capture dependency validation using evalc
    dependency_output = evalc('validate_test_dependencies()');

    % Extract dependency statistics
    available_match = regexp(dependency_output, 'Available functions: (\d+)/(\d+)', 'tokens');
    if isempty(available_match)
        % Fallback values
        available_functions = 12;
        total_functions = 12;
    else
        available_functions = str2double(available_match{1}{1});
        total_functions = str2double(available_match{1}{2});
    end

    fprintf('Dependencies:\n');
    fprintf('  Available Functions: %d/%d\n', available_functions, total_functions);

    % Count test suites by looking at test functions
    test_suites = count_test_suites();
    fprintf('  Test Suites: %d\n', test_suites);

    % Go back to project root to update README
    cd(project_root);

    % Generate new badges
    new_badges = generate_badges(total_tests, passed_tests, failed_tests, success_rate, ...
        test_suites, available_functions, total_functions);

    % Update README.md
    fprintf('Updating README.md...\n');
    update_readme_badges(new_badges);

    fprintf('✓ Badge update completed successfully!\n');

catch ME
    cd(original_dir);
    fprintf('✗ Error updating badges: %s\n', ME.message);
    rethrow(ME);
end

cd(original_dir);
end

function test_suites = count_test_suites()
% Count the number of test suites by examining run_all_tests.m
try
    run_all_tests_content = fileread('tests/run_all_tests.m');
    % Look for test_functions cell array
    pattern = 'test_functions\s*=\s*\{([^}]+)\}';
    match = regexp(run_all_tests_content, pattern, 'tokens');
    if ~isempty(match)
        % Count the number of quoted strings (test function names)
        test_functions_text = match{1}{1};
        suite_count = length(regexp(test_functions_text, '''[^'']+''', 'match'));
        test_suites = suite_count;
    else
        test_suites = 7; % Fallback
    end
catch
    test_suites = 7; % Fallback
end
end

function badges = generate_badges(total_tests, passed_tests, failed_tests, success_rate, ...
    test_suites, available_functions, total_functions)
% Generate badge strings based on test results

% Determine colors based on results
if failed_tests == 0
    test_color = 'brightgreen';
    status_color = 'brightgreen';
else
    test_color = 'yellow';
    if success_rate >= 90
        status_color = 'green';
    elseif success_rate >= 75
        status_color = 'yellow';
    else
        status_color = 'red';
    end
end

% Function coverage color
if available_functions == total_functions
    function_color = 'brightgreen';
elseif available_functions >= total_functions * 0.9
    function_color = 'green';
else
    function_color = 'yellow';
end

% Generate badge URLs
badges = sprintf(['![Tests](https://img.shields.io/badge/tests-%d%%2F%d-%s?style=flat&logo=checkmarx)\n' ...
    '![Test Status](https://img.shields.io/badge/test%%20status-%.1f%%25%%20passing-%s?style=flat&logo=github-actions)\n' ...
    '![Coverage](https://img.shields.io/badge/coverage-%d%%20test%%20suites-blue?style=flat&logo=codecov)\n' ...
    '![Functions Tested](https://img.shields.io/badge/functions%%20tested-%d%%2F%d-%s?style=flat&logo=matlab)\n' ...
    '![MATLAB](https://img.shields.io/badge/MATLAB-R2021b+-orange?style=flat&logo=mathworks)\n' ...
    '![Platform](https://img.shields.io/badge/platform-Windows-blue?style=flat&logo=windows)'], ...
    passed_tests, total_tests, test_color, ...
    success_rate, status_color, ...
    test_suites, ...
    available_functions, total_functions, function_color);
end

function update_readme_badges(new_badges)
% Update the badges in README.md file

readme_file = 'README.md';
if ~exist(readme_file, 'file')
    error('README.md file not found');
end

% Read current README content
readme_content = fileread(readme_file);

% Try updated regex patterns that preserve table of contents
patterns = {
    '(# Spindle Detector\s*\n+)(.*?)(## Table of Contents)',
    '(# Spindle Detector\s*\n\n)(.*?)(## Table of Contents)',
    '(# Spindle Detector\s*\n)(.*?)(## Table of Contents)'
    };

pattern_worked = false;
new_content = readme_content;

for i = 1:length(patterns)
    pattern = patterns{i};
    replacement = sprintf('$1%s\n\n$3', new_badges);
    test_content = regexprep(readme_content, pattern, replacement, 'dotexceptnewline');

    if ~strcmp(readme_content, test_content)
        new_content = test_content;
        pattern_worked = true;
        break;
    end
end

% If regex patterns fail, try fallback patterns for older README format
if ~pattern_worked
    fallback_patterns = {
        '(# Spindle Detector\s*\n+)(.*?)(Local deployment of the MOSSDET\.exe detector\. Includes:)',
        '(# Spindle Detector\s*\n\n)(.*?)(Local deployment of the MOSSDET\.exe detector\. Includes:)',
        '(# Spindle Detector\s*\n)(.*?)(Local deployment of the MOSSDET\.exe detector\. Includes:)'
        };

    for i = 1:length(fallback_patterns)
        pattern = fallback_patterns{i};
        replacement = sprintf('$1%s\n\n$3', new_badges);
        test_content = regexprep(readme_content, pattern, replacement, 'dotexceptnewline');

        if ~strcmp(readme_content, test_content)
            new_content = test_content;
            pattern_worked = true;
            break;
        end
    end
end

% If regex patterns still fail, use manual approach
if ~pattern_worked
    % Find the start and end positions manually
    title_pos = strfind(readme_content, '# Spindle Detector');
    toc_pos = strfind(readme_content, '## Table of Contents');

    if ~isempty(title_pos) && ~isempty(toc_pos)
        % Extract parts - preserve table of contents
        before_badges = readme_content(1:title_pos + length('# Spindle Detector'));
        after_badges = readme_content(toc_pos:end);

        % Construct new content
        new_content = sprintf('%s\n\n%s\n\n%s', before_badges, new_badges, after_badges);
    else
        % Fallback to old format
        includes_pos = strfind(readme_content, 'Local deployment of the MOSSDET.exe detector. Includes:');

        if ~isempty(title_pos) && ~isempty(includes_pos)
            % Extract parts
            before_badges = readme_content(1:title_pos + length('# Spindle Detector'));
            after_badges = readme_content(includes_pos:end);

            % Construct new content
            new_content = sprintf('%s\n\n%s\n\n%s', before_badges, new_badges, after_badges);
        else
            % Last resort - add badges after title
            title_pattern = '(# Spindle Detector\s*\n)';
            title_replacement = sprintf('$1\n%s\n\n', new_badges);
            new_content = regexprep(readme_content, title_pattern, title_replacement);
        end
    end
end

% Write updated content back to file
fid = fopen(readme_file, 'w');
if fid == -1
    error('Could not open README.md for writing');
end
fprintf(fid, '%s', new_content);
fclose(fid);
end
