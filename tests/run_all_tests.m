function run_all_tests()
% RUN_ALL_TESTS - Comprehensive test suite for the spindle detector project
%
% This function runs all test suites and provides a summary of results.
% Tests cover configuration, utility functions, core algorithms, and integration.

clc;
fprintf('=== SPINDLE DETECTOR TEST SUITE ===\n');
fprintf('Starting comprehensive testing...\n\n');

% Add project paths
addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..')));

% Initialize test results
total_tests = 0;
passed_tests = 0;
failed_tests = 0;
test_results = {};

% List of test functions to run
test_functions = {
    'test_configuration',
    'test_utility_functions',
    'test_performance_metrics',
    'test_data_processing',
    'test_file_operations',
    'test_montage_functions',
    'test_integration'
    };

% Run each test suite
for i = 1:length(test_functions)
    fprintf('Running %s...\n', test_functions{i});
    try
        [suite_passed, suite_total, suite_results] = feval(test_functions{i});
        total_tests = total_tests + suite_total;
        passed_tests = passed_tests + suite_passed;
        failed_tests = failed_tests + (suite_total - suite_passed);

        % Properly concatenate cell arrays
        if iscell(suite_results)
            test_results = [test_results; suite_results(:)];
        end

        fprintf('  %d/%d tests passed\n', suite_passed, suite_total);
    catch ME
        fprintf('  ERROR: %s failed to run: %s\n', test_functions{i}, ME.message);
        failed_tests = failed_tests + 1;
        total_tests = total_tests + 1;
    end
    fprintf('\n');
end

% Print summary
fprintf('=== TEST SUMMARY ===\n');
fprintf('Total tests: %d\n', total_tests);
fprintf('Passed: %d\n', passed_tests);
fprintf('Failed: %d\n', failed_tests);
fprintf('Success rate: %.1f%%\n', (passed_tests/total_tests)*100);

% Print failed tests details
if failed_tests > 0
    fprintf('\n=== FAILED TESTS ===\n');
    for i = 1:length(test_results)
        if ~test_results{i}.passed
            fprintf('FAIL: %s - %s\n', test_results{i}.name, test_results{i}.message);
        end
    end
end

fprintf('\nTesting completed.\n');
end
