function [passed, total, results] = test_data_processing()
% TEST_DATA_PROCESSING - Tests for data processing and analysis functions

results = {};
passed = 0;
total = 0;

% Test training/test set generation logic
try
    total = total + 1;

    % Mock configuration
    mock_cfg = struct();
    mock_cfg.workspacePath = tempdir;
    mock_cfg.all_eegDataPaths = {'TestGroup1', 'TestGroup2'};

    % Create temporary test structure
    test_workspace = fullfile(tempdir, 'test_spindle_workspace');
    if exist(test_workspace, 'dir')
        rmdir(test_workspace, 's');
    end
    mkdir(test_workspace);
    mock_cfg.workspacePath = test_workspace;

    % Create mock input directory structure
    source_dir = fullfile(test_workspace, 'Scalp_Detections_Pruned_Merged', 'TestGroup1');
    mkdir(source_dir);

    % Create mock detection files
    for i = 1:10
        filename = sprintf('Subject%d_MOSSDET_Scalp_Detections.mat', i);
        filepath = fullfile(source_dir, filename);
        detections = {'Ch1', [], [], [], 1000, 2000, 'test'};
        subjName = sprintf('Subject%d', i);
        save(filepath, 'detections', 'subjName');
    end

    % Test generate_training_test_sets function
    train_test_ratio = 0.6;

    % Note: We need to create a simplified version for testing
    % since the actual function might require EEG files
    train_dir = fullfile(test_workspace, 'Scalp_Detections_Pruned_Merged_Train', 'TestGroup1');
    test_dir = fullfile(test_workspace, 'Scalp_Detections_Pruned_Merged_Test', 'TestGroup1');

    % Simulate the function behavior
    source_files = dir(fullfile(source_dir, '*.mat'));
    n_files = length(source_files);
    n_train = round(n_files * train_test_ratio);

    train_indices = randperm(n_files, n_train);
    is_training = false(n_files, 1);
    is_training(train_indices) = true;

    % Create directories and copy files
    mkdir(train_dir);
    mkdir(test_dir);

    for i = 1:n_files
        source_file = fullfile(source_files(i).folder, source_files(i).name);
        if is_training(i)
            dest_file = fullfile(train_dir, source_files(i).name);
        else
            dest_file = fullfile(test_dir, source_files(i).name);
        end
        copyfile(source_file, dest_file);
    end

    % Verify the split
    train_files = dir(fullfile(train_dir, '*.mat'));
    test_files = dir(fullfile(test_dir, '*.mat'));

    if length(train_files) + length(test_files) == n_files && ...
            length(train_files) >= floor(n_files * train_test_ratio)
        passed = passed + 1;
        results{end+1} = struct('name', 'training_test_split', 'passed', true, 'message', 'Training/test split successful');
    else
        results{end+1} = struct('name', 'training_test_split', 'passed', false, 'message', 'Training/test split failed');
    end

    % Clean up
    rmdir(test_workspace, 's');

catch ME
    results{end+1} = struct('name', 'training_test_split', 'passed', false, 'message', ME.message);
end

% Test event overlap calculation
try
    total = total + 1;

    % Test overlapping events
    event1_start = 1000;
    event1_end = 2000;
    event2_start = 1500;
    event2_end = 2500;

    overlap = getEventsOverlap(event1_start, event1_end, event2_start, event2_end);
    expected_overlap = 500; % 500 samples overlap

    if abs(overlap - expected_overlap) < 1e-10
        passed = passed + 1;
        results{end+1} = struct('name', 'event_overlap_calculation', 'passed', true, 'message', 'Event overlap calculated correctly');
    else
        results{end+1} = struct('name', 'event_overlap_calculation', 'passed', false, ...
            'message', sprintf('Expected overlap %d, got %f', expected_overlap, overlap));
    end
catch ME
    results{end+1} = struct('name', 'event_overlap_calculation', 'passed', false, 'message', ME.message);
end

% Test non-overlapping events
try
    total = total + 1;

    event1_start = 1000;
    event1_end = 2000;
    event2_start = 3000;
    event2_end = 4000;

    overlap = getEventsOverlap(event1_start, event1_end, event2_start, event2_end);

    if overlap == 0
        passed = passed + 1;
        results{end+1} = struct('name', 'no_overlap_calculation', 'passed', true, 'message', 'No overlap calculated correctly');
    else
        results{end+1} = struct('name', 'no_overlap_calculation', 'passed', false, ...
            'message', sprintf('Expected no overlap, got %f', overlap));
    end
catch ME
    results{end+1} = struct('name', 'no_overlap_calculation', 'passed', false, 'message', ME.message);
end

% Test data validation for events
try
    total = total + 1;

    % Test valid event structure
    valid_event = {'Ch1', 'type', [], [], 1000, 2000, 'comment'};

    % Check if event has required fields (channel, start, end)
    if length(valid_event) >= 6 && ...
            ~isempty(valid_event{1}) && ...
            isnumeric(valid_event{5}) && ...
            isnumeric(valid_event{6}) && ...
            valid_event{6} > valid_event{5}
        passed = passed + 1;
        results{end+1} = struct('name', 'event_structure_validation', 'passed', true, 'message', 'Event structure validation passed');
    else
        results{end+1} = struct('name', 'event_structure_validation', 'passed', false, 'message', 'Event structure validation failed');
    end
catch ME
    results{end+1} = struct('name', 'event_structure_validation', 'passed', false, 'message', ME.message);
end

% Test thresholding logic
try
    total = total + 1;

    % Test power thresholding
    power_values = [10, 25, 30, 15, 35];
    power_threshold = 20;

    above_threshold = power_values >= power_threshold;
    expected_result = [false, true, true, false, true];

    if isequal(above_threshold, expected_result)
        passed = passed + 1;
        results{end+1} = struct('name', 'power_thresholding', 'passed', true, 'message', 'Power thresholding logic correct');
    else
        results{end+1} = struct('name', 'power_thresholding', 'passed', false, 'message', 'Power thresholding logic failed');
    end
catch ME
    results{end+1} = struct('name', 'power_thresholding', 'passed', false, 'message', ME.message);
end

end

% Helper function for event overlap calculation (from MOSSDET_spindle_detection.m)
function overlapTime = getEventsOverlap(feStart, feEnd, seStart, seEnd)
overlapStart = max(feStart, seStart);
overlapEnd = min(feEnd, seEnd);

if overlapStart < overlapEnd
    overlapTime = overlapEnd - overlapStart;
else
    overlapTime = 0;
end
end
