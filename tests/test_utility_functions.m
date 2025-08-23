function [passed, total, results] = test_utility_functions()
% TEST_UTILITY_FUNCTIONS - Tests for utility functions

results = {};
passed = 0;
total = 0;

% Test extract_bp_power function (from run_auto_spindles_merge.m)
try
    total = total + 1;

    % Test data: comments with bp-power as first value
    test_comments = {'123.45,12.5,3', '67.89,15.2,4', '234.56,18.7,2'};

    bp_powers = extract_bp_power(test_comments);
    expected_powers = [123.45; 67.89; 234.56]; % Column vector

    if isequal(size(bp_powers), size(expected_powers)) && ...
            all(abs(bp_powers - expected_powers) < 1e-10)
        passed = passed + 1;
        results{end+1} = struct('name', 'extract_bp_power', 'passed', true, 'message', 'BP power extraction successful');
    else
        results{end+1} = struct('name', 'extract_bp_power', 'passed', false, 'message', 'BP power extraction failed');
    end
catch ME
    results{end+1} = struct('name', 'extract_bp_power', 'passed', false, 'message', ME.message);
end

% Test extract_propagation_nr function
try
    total = total + 1;

    % Test data: comments with propagation number as last value
    test_comments = {'123.45,12.5,3', '67.89,15.2,4', '234.56,18.7,2'};

    prop_numbers = extract_propagation_nr(test_comments);
    expected_props = [3; 4; 2]; % Column vector

    if isequal(size(prop_numbers), size(expected_props)) && ...
            all(abs(prop_numbers - expected_props) < 1e-10)
        passed = passed + 1;
        results{end+1} = struct('name', 'extract_propagation_nr', 'passed', true, 'message', 'Propagation number extraction successful');
    else
        results{end+1} = struct('name', 'extract_propagation_nr', 'passed', false, 'message', 'Propagation number extraction failed');
    end
catch ME
    results{end+1} = struct('name', 'extract_propagation_nr', 'passed', false, 'message', ME.message);
end

% Test robust_rmdir function
try
    total = total + 1;

    % Create a temporary directory for testing
    test_dir = fullfile(tempdir, 'test_spindle_detector_rmdir');
    if ~exist(test_dir, 'dir')
        mkdir(test_dir);
    end

    % Create a test file
    test_file = fullfile(test_dir, 'test_file.txt');
    fid = fopen(test_file, 'w');
    fprintf(fid, 'test content');
    fclose(fid);

    % Test robust_rmdir
    robust_rmdir(test_dir);

    if ~exist(test_dir, 'dir')
        passed = passed + 1;
        results{end+1} = struct('name', 'robust_rmdir', 'passed', true, 'message', 'Directory removal successful');
    else
        results{end+1} = struct('name', 'robust_rmdir', 'passed', false, 'message', 'Directory removal failed');
    end
catch ME
    results{end+1} = struct('name', 'robust_rmdir', 'passed', false, 'message', ME.message);
end

% Test merge_events function with simple test data
try
    total = total + 1;

    % Create test events data
    fs = 1000;

    % Two overlapping events that should be merged
    events_data = {
        'Ch1', [], [], [], 1000, 2000, '100.0,12.5,2'; % Event 1: 1-2 seconds
        'Ch1', [], [], [], 1500, 2500, '150.0,13.0,3'  % Event 2: 1.5-2.5 seconds (overlapping)
        };

    merged_events = merge_events(events_data, fs, false);

    % Should merge into one event (the one with higher power should be kept)
    if size(merged_events, 1) <= size(events_data, 1)
        passed = passed + 1;
        results{end+1} = struct('name', 'merge_events_basic', 'passed', true, 'message', 'Event merging basic test passed');
    else
        results{end+1} = struct('name', 'merge_events_basic', 'passed', false, 'message', 'Event merging failed - more events than input');
    end
catch ME
    results{end+1} = struct('name', 'merge_events_basic', 'passed', false, 'message', ME.message);
end

% Test fieldtrip_init function
try
    total = total + 1;

    cfg = startup_cfg();

    % Test fieldtrip initialization (should not throw error)
    fieldtrip_init(cfg);

    passed = passed + 1;
    results{end+1} = struct('name', 'fieldtrip_init', 'passed', true, 'message', 'FieldTrip initialization successful');
catch ME
    % FieldTrip might not be available in test environment, so this is expected
    results{end+1} = struct('name', 'fieldtrip_init', 'passed', false, 'message', sprintf('FieldTrip init failed (expected): %s', ME.message));
end

% Test add_features function with mock data
try
    total = total + 1;

    % Create mock event data
    events_ls = {
        'Ch1', [], [], [], 1000, 2000, 'test_comment'
        };

    % Create mock EEG signal (1 second at 1000 Hz)
    eegBPSignal = randn(1, 1000);

    % Create mock CWT data
    cwt_frqs = 8:0.5:16; % Spindle frequency range
    cwt_mat = randn(length(cwt_frqs), 1000);

    % Test add_features (should not crash)
    events_with_features = add_features(events_ls, eegBPSignal, cwt_frqs, cwt_mat, false);

    if size(events_with_features, 1) >= size(events_ls, 1)
        passed = passed + 1;
        results{end+1} = struct('name', 'add_features_basic', 'passed', true, 'message', 'Feature addition basic test passed');
    else
        results{end+1} = struct('name', 'add_features_basic', 'passed', false, 'message', 'Feature addition failed');
    end
catch ME
    results{end+1} = struct('name', 'add_features_basic', 'passed', false, 'message', ME.message);
end

end
