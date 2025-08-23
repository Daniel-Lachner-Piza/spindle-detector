# Spindle Detector Test Suite

This directory contains comprehensive tests for the spindle detector project. The test suite covers configuration, utility functions, core algorithms, data processing, file operations, and integration testing.

## Running Tests

### Run All Tests
```matlab
cd tests
run_all_tests
```

### Run Individual Test Suites
```matlab
cd tests
[passed, total, results] = test_configuration();
[passed, total, results] = test_utility_functions();
[passed, total, results] = test_performance_metrics();
[passed, total, results] = test_data_processing();
[passed, total, results] = test_file_operations();
[passed, total, results] = test_montage_functions();
[passed, total, results] = test_integration();
```

## Test Coverage

### 1. Configuration Tests (`test_configuration.m`)
- **startup_cfg_fields**: Verifies all required configuration fields are present
- **workspace_path_exists**: Checks if workspace path exists
- **scalp_labels_format**: Validates bipolar montage label format
- **age_groups_config**: Verifies age group configuration
- **output_path_creation**: Tests output directory creation

### 2. Utility Function Tests (`test_utility_functions.m`)
- **extract_bp_power**: Tests bandpass power extraction from comments
- **extract_propagation_nr**: Tests propagation number extraction
- **robust_rmdir**: Tests robust directory removal
- **merge_events_basic**: Tests basic event merging functionality
- **fieldtrip_init**: Tests FieldTrip initialization
- **add_features_basic**: Tests feature addition to events

### 3. Performance Metrics Tests (`test_performance_metrics.m`)
- **kappa_perfect_agreement**: Tests Cohen's kappa for perfect agreement (κ = 1.0)
- **kappa_random_agreement**: Tests Cohen's kappa for random agreement (κ ≈ 0.0)
- **kappa_good_agreement**: Tests Cohen's kappa for good agreement (κ > 0.5)
- **performance_metrics_calculation**: Tests sensitivity, specificity, precision calculation
- **performance_metrics_edge_case**: Tests edge case handling (all zeros)
- **confusion_matrix_computation**: Tests confusion matrix computation with sample data

### 4. Data Processing Tests (`test_data_processing.m`)
- **training_test_split**: Tests 60/40 training/test data splitting
- **event_overlap_calculation**: Tests temporal overlap calculation between events
- **no_overlap_calculation**: Tests non-overlapping event detection
- **event_structure_validation**: Tests event data structure validation
- **power_thresholding**: Tests power-based filtering logic

### 5. File Operations Tests (`test_file_operations.m`)
- **mat_file_save_load**: Tests .mat file saving and loading integrity
- **directory_creation**: Tests directory creation and validation
- **filepath_parsing**: Tests file path parsing and name extraction
- **csv_file_operations**: Tests CSV file read/write operations
- **file_existence_check**: Tests file existence checking
- **file_copy_operation**: Tests file copying with data integrity verification

### 6. Montage Function Tests (`test_montage_functions.m`)
- **scalp_channel_labels**: Tests scalp EEG channel label retrieval
- **non_eeg_channel_labels**: Tests non-EEG channel label identification
- **scalp_montage_selection**: Tests scalp montage selection logic
- **montage_signal_generation**: Tests bipolar montage signal generation
- **bipolar_label_parsing**: Tests bipolar label parsing (e.g., "Fp1-F3")
- **channel_availability_check**: Tests channel availability for montage creation

### 7. Integration Tests (`test_integration.m`)
- **configuration_integration**: Tests complete configuration setup
- **data_flow_simulation**: Tests end-to-end data processing pipeline
- **empty_data_handling**: Tests graceful handling of empty datasets
- **performance_metrics_integration**: Tests metrics calculation across age groups
- **filesystem_integration**: Tests directory structure creation
- **parameter_validation_integration**: Tests parameter range validation

## Expected Test Results

When all components are functioning correctly, you should see:
- **Configuration tests**: 5/5 passed
- **Utility function tests**: 5-6/6 passed (FieldTrip may fail in test environment)
- **Performance metrics tests**: 6/6 passed
- **Data processing tests**: 5/5 passed
- **File operations tests**: 6/6 passed
- **Montage function tests**: 6/6 passed
- **Integration tests**: 6/6 passed

Total expected: ~38-39 tests passed

## Common Issues and Solutions

### FieldTrip Initialization Failure
If `fieldtrip_init` test fails, ensure:
- FieldTrip toolbox is installed
- FieldTrip path is correctly configured in `startup_cfg.m`
- Computer name matches expected values in configuration

### Path-Related Failures
If path tests fail:
- Check workspace permissions
- Verify drive availability
- Ensure MATLAB has write permissions to temporary directories

### Performance Metric Calculation Issues
If metric tests fail:
- Verify confusion matrix format: [TP, FP, FN, TN]
- Check for division by zero handling
- Ensure kappa calculation follows Cohen's formula

## Adding New Tests

To add new tests:

1. Create test function following the pattern:
```matlab
function [passed, total, results] = test_new_feature()
results = {};
passed = 0;
total = 0;

try
    total = total + 1;
    % Test logic here
    if (test_condition)
        passed = passed + 1;
        results{end+1} = struct('name', 'test_name', 'passed', true, 'message', 'Success message');
    else
        results{end+1} = struct('name', 'test_name', 'passed', false, 'message', 'Failure message');
    end
catch ME
    results{end+1} = struct('name', 'test_name', 'passed', false, 'message', ME.message);
end
end
```

2. Add the new test function to `run_all_tests.m` test_functions list

3. Document the new tests in this README

## Continuous Integration

These tests can be run automatically as part of a CI/CD pipeline to ensure code quality and catch regressions during development.
