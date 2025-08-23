function validate_test_dependencies()
% VALIDATE_TEST_DEPENDENCIES - Check if all required functions are available

fprintf('=== VALIDATING TEST DEPENDENCIES ===\n');

% Add project paths
addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..')));

% List of functions that should be available
required_functions = {
    'startup_cfg',
    'compute_kappa_score',
    'compute_performance_metrics',
    'compute_confusion_matrix',
    'robust_rmdir',
    'merge_events',
    'fieldtrip_init',
    'add_features',
    'getScalpChannelLabels',
    'getNonEEG_ChanelLabels',
    'selectScalpMontageIdxs',
    'generateMontageSignals'
    };

missing_functions = {};
available_count = 0;

for i = 1:length(required_functions)
    func_name = required_functions{i};
    if exist(func_name, 'file') == 2 % Function file exists
        fprintf('✓ %s - Available\n', func_name);
        available_count = available_count + 1;
    else
        fprintf('✗ %s - MISSING\n', func_name);
        missing_functions{end+1} = func_name;
    end
end

fprintf('\n=== SUMMARY ===\n');
fprintf('Available functions: %d/%d\n', available_count, length(required_functions));

if ~isempty(missing_functions)
    fprintf('\nMissing functions:\n');
    for i = 1:length(missing_functions)
        fprintf('  - %s\n', missing_functions{i});
    end
    fprintf('\nNote: Some functions may be embedded within scripts and not directly callable.\n');
    fprintf('This is expected for helper functions within larger scripts.\n');
else
    fprintf('All required functions are available!\n');
end

fprintf('\nValidation complete.\n');
end
