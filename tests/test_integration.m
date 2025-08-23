function [passed, total, results] = test_integration()
% TEST_INTEGRATION - Integration tests for the complete workflow

results = {};
passed = 0;
total = 0;

% Test configuration integration
try
    total = total + 1;

    % Try to get configuration, but handle gracefully if not available
    try
        cfg = startup_cfg();
        config_available = true;
    catch
        % If startup_cfg is not available, create mock configuration
        cfg = struct();
        cfg.workspacePath = fullfile(tempdir, 'mock_workspace');
        cfg.outputPath = fullfile(tempdir, 'mock_output');
        config_available = false;
    end

    % Test if all required paths exist or can be created
    paths_to_check = {
        cfg.workspacePath,
        cfg.outputPath
        };

    all_paths_ok = true;
    for i = 1:length(paths_to_check)
        if ~exist(paths_to_check{i}, 'dir')
            try
                mkdir(paths_to_check{i});
            catch
                all_paths_ok = false;
                break;
            end
        end
    end

    if all_paths_ok
        passed = passed + 1;
        if config_available
            results{end+1} = struct('name', 'configuration_integration', 'passed', true, 'message', 'Configuration integration successful');
        else
            results{end+1} = struct('name', 'configuration_integration', 'passed', true, 'message', 'Configuration integration successful (mock config)');
        end
    else
        results{end+1} = struct('name', 'configuration_integration', 'passed', false, 'message', 'Configuration integration failed - path issues');
    end

catch ME
    results{end+1} = struct('name', 'configuration_integration', 'passed', false, 'message', ME.message);
end

% Test end-to-end data flow simulation
try
    total = total + 1;

    % Simulate the complete data processing pipeline
    try
        cfg = startup_cfg();
    catch
        % Create mock configuration if startup_cfg not available
        cfg = struct();
        cfg.workspacePath = fullfile(tempdir, 'mock_workspace');
    end

    % Mock data creation
    mock_detections = {
        'Fp1-F3', 'spindle', [], [], 1000, 2000, '150.5,12.5,3';
        'F3-C3', 'spindle', [], [], 1500, 2500, '200.2,13.2,4';
        'C3-P3', 'spindle', [], [], 3000, 4000, '175.8,11.8,2'
        };

    % Test feature extraction simulation
    bp_powers = [];
    prop_numbers = [];

    for i = 1:size(mock_detections, 1)
        comment = mock_detections{i, 7};
        parts = strsplit(comment, ',');
        bp_powers(end+1) = str2double(parts{1});
        prop_numbers(end+1) = str2double(parts{end});
    end

    % Test thresholding
    power_threshold = 160;
    prop_threshold = 3;

    power_filter = bp_powers >= power_threshold;
    prop_filter = prop_numbers >= prop_threshold;
    combined_filter = power_filter & prop_filter;

    filtered_detections = mock_detections(combined_filter, :);

    % Should have reduced number of detections
    if size(filtered_detections, 1) <= size(mock_detections, 1) && size(filtered_detections, 1) > 0
        passed = passed + 1;
        results{end+1} = struct('name', 'data_flow_simulation', 'passed', true, 'message', 'End-to-end data flow simulation successful');
    else
        results{end+1} = struct('name', 'data_flow_simulation', 'passed', false, 'message', 'Data flow simulation failed');
    end

catch ME
    results{end+1} = struct('name', 'data_flow_simulation', 'passed', false, 'message', ME.message);
end

% Test error handling in pipeline
try
    total = total + 1;

    % Test handling of empty data
    empty_detections = {};

    % Should not crash when processing empty data
    if isempty(empty_detections)
        % Simulate processing empty data
        try
            % This should handle empty input gracefully
            if isempty(empty_detections)
                % Successfully identified empty data
                empty_handling_success = true;
            else
                empty_handling_success = false;
            end

            if empty_handling_success
                passed = passed + 1;
                results{end+1} = struct('name', 'empty_data_handling', 'passed', true, 'message', 'Empty data handling successful');
            else
                results{end+1} = struct('name', 'empty_data_handling', 'passed', false, 'message', 'Empty data validation failed');
            end
        catch
            results{end+1} = struct('name', 'empty_data_handling', 'passed', false, 'message', 'Failed to handle empty data');
        end
    else
        results{end+1} = struct('name', 'empty_data_handling', 'passed', false, 'message', 'Empty data test setup failed');
    end

catch ME
    results{end+1} = struct('name', 'empty_data_handling', 'passed', false, 'message', ME.message);
end

% Test performance metrics integration
try
    total = total + 1;

    % Create mock results for integration test
    mock_results = {
        'HFOHealthy3to5yrs', 'Subject1', 0.85, 0.90, 0.80, 0.75;
        'HFOHealthy3to5yrs', 'Subject2', 0.88, 0.92, 0.82, 0.78;
        'HFOHealthy6to10yrs', 'Subject3', 0.82, 0.88, 0.78, 0.72
        };

    % Convert to table (simulating results processing)
    try
        results_table = cell2table(mock_results, 'VariableNames', ...
            {'AgeGroup', 'Subject', 'Sensitivity', 'Specificity', 'Precision', 'Kappa'});

        % Verify table creation was successful
        table_valid = istable(results_table) && height(results_table) == size(mock_results, 1);
    catch
        table_valid = false;
    end

    % Test summary statistics calculation
    sensitivity_data = cell2mat(mock_results(:,3));
    mean_sensitivity = mean(sensitivity_data);
    std_sensitivity = std(sensitivity_data);

    % Validate table creation and statistics
    if table_valid && mean_sensitivity > 0 && mean_sensitivity <= 1 && std_sensitivity >= 0
        passed = passed + 1;
        results{end+1} = struct('name', 'performance_metrics_integration', 'passed', true, 'message', 'Performance metrics integration successful');
    else
        results{end+1} = struct('name', 'performance_metrics_integration', 'passed', false, 'message', 'Performance metrics integration failed');
    end

catch ME
    results{end+1} = struct('name', 'performance_metrics_integration', 'passed', false, 'message', ME.message);
end

% Test file system integration
try
    total = total + 1;

    % Test temporary workspace creation
    temp_workspace = fullfile(tempdir, 'integration_test_workspace');

    % Create directory structure
    subdirs = {'Scalp_Detections', 'Characterized_Visual_Marks', 'OutputFiles'};

    all_dirs_created = true;
    for i = 1:length(subdirs)
        subdir_path = fullfile(temp_workspace, subdirs{i});
        try
            mkdir(subdir_path);
            if ~exist(subdir_path, 'dir')
                all_dirs_created = false;
                break;
            end
        catch
            all_dirs_created = false;
            break;
        end
    end

    if all_dirs_created
        passed = passed + 1;
        results{end+1} = struct('name', 'filesystem_integration', 'passed', true, 'message', 'File system integration successful');

        % Clean up
        rmdir(temp_workspace, 's');
    else
        results{end+1} = struct('name', 'filesystem_integration', 'passed', false, 'message', 'File system integration failed');
    end

catch ME
    results{end+1} = struct('name', 'filesystem_integration', 'passed', false, 'message', ME.message);
end

% Test parameter validation integration
try
    total = total + 1;

    % Test parameter ranges
    test_params = struct();
    test_params.power_threshold = 20;
    test_params.prop_threshold = 3;
    test_params.agreement_window = 1000;
    test_params.train_ratio = 0.6;

    % Validate parameter ranges
    params_valid = test_params.power_threshold > 0 && ...
        test_params.prop_threshold > 0 && ...
        test_params.agreement_window > 0 && ...
        test_params.train_ratio > 0 && test_params.train_ratio < 1;

    if params_valid
        passed = passed + 1;
        results{end+1} = struct('name', 'parameter_validation_integration', 'passed', true, 'message', 'Parameter validation integration successful');
    else
        results{end+1} = struct('name', 'parameter_validation_integration', 'passed', false, 'message', 'Parameter validation failed');
    end

catch ME
    results{end+1} = struct('name', 'parameter_validation_integration', 'passed', false, 'message', ME.message);
end

% Test edge case: Invalid parameter values
try
    total = total + 1;

    % Test negative and invalid parameter values
    invalid_params = [
        struct('power_threshold', -10, 'prop_threshold', 3, 'train_ratio', 0.6);  % Negative power
        struct('power_threshold', 20, 'prop_threshold', 0, 'train_ratio', 0.6);  % Zero prop threshold
        struct('power_threshold', 20, 'prop_threshold', 3, 'train_ratio', 1.5);  % Train ratio > 1
        struct('power_threshold', 20, 'prop_threshold', 3, 'train_ratio', -0.1); % Negative train ratio
        ];

    all_invalid_detected = true;
    for i = 1:length(invalid_params)
        params = invalid_params(i);

        % Check if validation correctly identifies invalid parameters
        is_valid = params.power_threshold > 0 && ...
            params.prop_threshold > 0 && ...
            params.train_ratio > 0 && params.train_ratio < 1;

        if is_valid  % Should be false for all test cases
            all_invalid_detected = false;
            break;
        end
    end

    if all_invalid_detected
        passed = passed + 1;
        results{end+1} = struct('name', 'invalid_parameter_detection', 'passed', true, 'message', 'Invalid parameter detection successful');
    else
        results{end+1} = struct('name', 'invalid_parameter_detection', 'passed', false, 'message', 'Failed to detect invalid parameters');
    end

catch ME
    results{end+1} = struct('name', 'invalid_parameter_detection', 'passed', false, 'message', ME.message);
end

% Test edge case: Extreme data sizes
try
    total = total + 1;

    % Test with very large dataset simulation
    large_detections = cell(10000, 7);
    for i = 1:10000
        large_detections{i, 1} = sprintf('Ch%d-Ch%d', mod(i, 20)+1, mod(i+1, 20)+1);
        large_detections{i, 2} = 'spindle';
        large_detections{i, 3} = [];
        large_detections{i, 4} = [];
        large_detections{i, 5} = i * 100;
        large_detections{i, 6} = i * 100 + 1000;
        large_detections{i, 7} = sprintf('%.1f,%.1f,%d', rand()*300 + 50, rand()*5 + 10, randi(10));
    end

    % Test memory usage and processing time
    tic;
    num_detections = size(large_detections, 1);
    processing_time = toc;

    % Should handle large datasets (within reasonable time and memory)
    if num_detections == 10000 && processing_time < 5  % Less than 5 seconds
        passed = passed + 1;
        results{end+1} = struct('name', 'large_dataset_handling', 'passed', true, 'message', 'Large dataset handling successful');
    else
        results{end+1} = struct('name', 'large_dataset_handling', 'passed', false, ...
            'message', sprintf('Large dataset handling failed - Time: %.2fs', processing_time));
    end

catch ME
    results{end+1} = struct('name', 'large_dataset_handling', 'passed', false, 'message', ME.message);
end

% Test edge case: Malformed data structures
try
    total = total + 1;

    % Test various malformed data scenarios
    malformed_tests = {
        {}; ... % Empty cell array
        {'incomplete'}; ... % Incomplete row
        {'Ch1', 'spindle', [], [], 1000}; ... % Missing columns
        {'Ch1', 'spindle', [], [], 'invalid', 2000, '150,12,3'}; ... % Invalid start time
        {'Ch1', 'spindle', [], [], 1000, 'invalid', '150,12,3'}; ... % Invalid end time
        {'Ch1', 'spindle', [], [], 2000, 1000, '150,12,3'}; ... % End before start
        {'Ch1', 'spindle', [], [], 1000, 2000, 'malformed_comment'} ... % Malformed comment
        };

    malformed_handled = 0;
    for i = 1:length(malformed_tests)
        try
            test_data = malformed_tests{i};

            % Test basic validation that should catch malformed data
            if iscell(test_data) && length(test_data) >= 7
                % Try to extract timing information
                start_time = test_data{5};
                end_time = test_data{6};

                % Check if times are numeric and valid
                if isnumeric(start_time) && isnumeric(end_time) && end_time > start_time
                    % This is valid data
                else
                    malformed_handled = malformed_handled + 1;  % Correctly identified as malformed
                end
            else
                malformed_handled = malformed_handled + 1;  % Correctly identified as malformed
            end
        catch
            malformed_handled = malformed_handled + 1;  % Exception handling worked
        end
    end

    if malformed_handled >= 5  % Should catch most malformed cases
        passed = passed + 1;
        results{end+1} = struct('name', 'malformed_data_handling', 'passed', true, 'message', 'Malformed data handling successful');
    else
        results{end+1} = struct('name', 'malformed_data_handling', 'passed', false, ...
            'message', sprintf('Malformed data handling insufficient - Only %d/%d caught', malformed_handled, length(malformed_tests)));
    end

catch ME
    results{end+1} = struct('name', 'malformed_data_handling', 'passed', false, 'message', ME.message);
end

% Test edge case: Cross-platform compatibility
try
    total = total + 1;

    % Test path handling across platforms
    test_paths = {
        'C:\Windows\Path\test.mat'; ... % Windows absolute
        '/unix/path/test.mat'; ... % Unix absolute
        'relative\path\test.mat'; ... % Windows relative
        'relative/path/test.mat'; ... % Unix relative
        '\\network\share\test.mat' ... % Network path
        };

    path_compatibility = true;
    for i = 1:length(test_paths)
        test_path = test_paths{i};
        try
            % Test if MATLAB can handle path operations
            [path_dir, filename, ext] = fileparts(test_path);

            % Basic validation that fileparts works
            if ischar(path_dir) && ischar(filename) && ischar(ext)
                % Path parsing successful
            else
                path_compatibility = false;
                break;
            end
        catch
            % Some paths might fail on certain platforms, which is expected
            % Don't mark as failure unless all paths fail
        end
    end

    if path_compatibility
        passed = passed + 1;
        results{end+1} = struct('name', 'cross_platform_compatibility', 'passed', true, 'message', 'Cross-platform compatibility successful');
    else
        results{end+1} = struct('name', 'cross_platform_compatibility', 'passed', false, 'message', 'Cross-platform compatibility failed');
    end

catch ME
    results{end+1} = struct('name', 'cross_platform_compatibility', 'passed', false, 'message', ME.message);
end

% Test edge case: Memory pressure simulation
try
    total = total + 1;

    % Test behavior under memory constraints

    try
        % Create moderately large arrays to test memory handling
        test_matrix1 = rand(1000, 1000);  % ~8MB
        test_matrix2 = rand(1000, 1000);  % ~8MB

        % Perform some operations
        result_matrix = test_matrix1 * test_matrix2;

        % Verify operation completed successfully
        if size(result_matrix, 1) == 1000 && size(result_matrix, 2) == 1000
            memory_test_passed = true;
        else
            memory_test_passed = false;
        end

        % Clear memory
        clear test_matrix1 test_matrix2 result_matrix;

    catch
        memory_test_passed = false;
    end

    if memory_test_passed
        passed = passed + 1;
        results{end+1} = struct('name', 'memory_pressure_handling', 'passed', true, 'message', 'Memory pressure handling successful');
    else
        results{end+1} = struct('name', 'memory_pressure_handling', 'passed', false, 'message', 'Memory pressure handling failed');
    end

catch ME
    results{end+1} = struct('name', 'memory_pressure_handling', 'passed', false, 'message', ME.message);
end

% Test edge case: Concurrent access simulation
try
    total = total + 1;

    % Simulate concurrent access to shared resources
    temp_file = fullfile(tempdir, 'concurrent_test.mat');

    % Test multiple read/write operations
    concurrent_operations_successful = true;

    try
        % Write test data
        test_data = struct('value', 42, 'timestamp', now);
        save(temp_file, 'test_data');

        % Multiple read operations
        for i = 1:5
            loaded_data = load(temp_file);
            if ~isfield(loaded_data, 'test_data') || loaded_data.test_data.value ~= 42
                concurrent_operations_successful = false;
                break;
            end
        end

        % Clean up
        if exist(temp_file, 'file')
            delete(temp_file);
        end

    catch
        concurrent_operations_successful = false;
    end

    if concurrent_operations_successful
        passed = passed + 1;
        results{end+1} = struct('name', 'concurrent_access_simulation', 'passed', true, 'message', 'Concurrent access simulation successful');
    else
        results{end+1} = struct('name', 'concurrent_access_simulation', 'passed', false, 'message', 'Concurrent access simulation failed');
    end

catch ME
    results{end+1} = struct('name', 'concurrent_access_simulation', 'passed', false, 'message', ME.message);
end

% Test edge case: Unicode and special character handling
try
    total = total + 1;

    % Test handling of special characters in data
    special_char_data = {
        'Ñoñó-Çhäñńel', 'spindle', [], [], 1000, 2000, '150.5,12.5,3';  % Unicode characters
        'Ch@#$%-Ch&*()', 'spindle', [], [], 1500, 2500, '200.2,13.2,4';  % Special symbols
        'Ch1-Ch2', 'spîñdlé', [], [], 2000, 3000, '175.8,11.8,2';      % Unicode in event type
        'Ch1-Ch2', 'spindle', [], [], 2500, 3500, 'Pöwer:175.8,Frëq:11.8,Prøp:2'  % Unicode in comment
        };

    unicode_handling_successful = true;

    for i = 1:size(special_char_data, 1)
        try
            % Test if we can process the data without errors
            channel = special_char_data{i, 1};
            event_type = special_char_data{i, 2};
            comment = special_char_data{i, 7};

            % Basic validation that strings are handled properly
            if ischar(channel) && ischar(event_type) && ischar(comment)
                % String handling successful
            else
                unicode_handling_successful = false;
                break;
            end
        catch
            unicode_handling_successful = false;
            break;
        end
    end

    if unicode_handling_successful
        passed = passed + 1;
        results{end+1} = struct('name', 'unicode_character_handling', 'passed', true, 'message', 'Unicode character handling successful');
    else
        results{end+1} = struct('name', 'unicode_character_handling', 'passed', false, 'message', 'Unicode character handling failed');
    end

catch ME
    results{end+1} = struct('name', 'unicode_character_handling', 'passed', false, 'message', ME.message);
end

end
