function [passed, total, results] = test_performance_metrics()
% TEST_PERFORMANCE_METRICS - Tests for performance metric calculation functions

results = {};
passed = 0;
total = 0;

% Test compute_kappa_score function
try
    total = total + 1;

    % Test case 1: Perfect agreement
    confusion_matrix_perfect = [10, 0, 0, 10]; % [TP, FP, FN, TN]
    kappa_perfect = compute_kappa_score(confusion_matrix_perfect);

    if abs(kappa_perfect - 1.0) < 1e-10
        passed = passed + 1;
        results{end+1} = struct('name', 'kappa_perfect_agreement', 'passed', true, 'message', 'Perfect agreement kappa = 1.0');
    else
        results{end+1} = struct('name', 'kappa_perfect_agreement', 'passed', false, ...
            'message', sprintf('Perfect agreement kappa should be 1.0, got %.6f', kappa_perfect));
    end
catch ME
    results{end+1} = struct('name', 'kappa_perfect_agreement', 'passed', false, 'message', ME.message);
end

% Test case 2: No agreement (random)
try
    total = total + 1;

    confusion_matrix_random = [5, 5, 5, 5]; % [TP, FP, FN, TN]
    kappa_random = compute_kappa_score(confusion_matrix_random);

    if abs(kappa_random - 0.0) < 1e-6
        passed = passed + 1;
        results{end+1} = struct('name', 'kappa_random_agreement', 'passed', true, 'message', 'Random agreement kappa ≈ 0.0');
    else
        results{end+1} = struct('name', 'kappa_random_agreement', 'passed', false, ...
            'message', sprintf('Random agreement kappa should be ≈ 0.0, got %.6f', kappa_random));
    end
catch ME
    results{end+1} = struct('name', 'kappa_random_agreement', 'passed', false, 'message', ME.message);
end

% Test case 3: Good agreement
try
    total = total + 1;

    confusion_matrix_good = [8, 2, 1, 9]; % [TP, FP, FN, TN]
    kappa_good = compute_kappa_score(confusion_matrix_good);

    if kappa_good > 0.5 && kappa_good < 1.0
        passed = passed + 1;
        results{end+1} = struct('name', 'kappa_good_agreement', 'passed', true, ...
            'message', sprintf('Good agreement kappa = %.3f', kappa_good));
    else
        results{end+1} = struct('name', 'kappa_good_agreement', 'passed', false, ...
            'message', sprintf('Expected kappa > 0.5, got %.6f', kappa_good));
    end
catch ME
    results{end+1} = struct('name', 'kappa_good_agreement', 'passed', false, 'message', ME.message);
end

% Test compute_performance_metrics function
try
    total = total + 1;

    confusion_matrix = [8, 2, 3, 7]; % [TP, FP, FN, TN]
    metrics = compute_performance_metrics(confusion_matrix);

    % Expected values
    expected_sensitivity = 8 / (8 + 3); % TP / (TP + FN)
    expected_specificity = 7 / (7 + 2); % TN / (TN + FP)
    expected_precision = 8 / (8 + 2);   % TP / (TP + FP)

    % Check required fields
    required_fields = {'sensitivity', 'specificity', 'precision', 'kappa', 'fOneScore'};
    fields_ok = true;
    for i = 1:length(required_fields)
        if ~isfield(metrics, required_fields{i})
            fields_ok = false;
            break;
        end
    end

    if fields_ok && ...
            abs(metrics.sensitivity - expected_sensitivity) < 1e-10 && ...
            abs(metrics.specificity - expected_specificity) < 1e-10 && ...
            abs(metrics.precision - expected_precision) < 1e-10
        passed = passed + 1;
        results{end+1} = struct('name', 'performance_metrics_calculation', 'passed', true, 'message', 'Performance metrics calculated correctly');
    else
        results{end+1} = struct('name', 'performance_metrics_calculation', 'passed', false, 'message', 'Performance metrics calculation error');
    end
catch ME
    results{end+1} = struct('name', 'performance_metrics_calculation', 'passed', false, 'message', ME.message);
end

% Test edge case: All zeros
try
    total = total + 1;

    confusion_matrix_zeros = [0, 0, 0, 0];
    metrics_zeros = compute_performance_metrics(confusion_matrix_zeros);

    % Should handle division by zero gracefully
    if isfield(metrics_zeros, 'sensitivity') && ...
            isfield(metrics_zeros, 'specificity') && ...
            isfield(metrics_zeros, 'precision') && ...
            isfield(metrics_zeros, 'kappa')
        passed = passed + 1;
        results{end+1} = struct('name', 'performance_metrics_edge_case', 'passed', true, 'message', 'Edge case (all zeros) handled correctly');
    else
        results{end+1} = struct('name', 'performance_metrics_edge_case', 'passed', false, 'message', 'Edge case not handled properly');
    end
catch ME
    results{end+1} = struct('name', 'performance_metrics_edge_case', 'passed', false, 'message', ME.message);
end

% Test confusion matrix computation with simple data
try
    total = total + 1;

    % Create simple test data
    fs = 1000; % 1000 Hz sampling rate
    nrSamples = 10000; % 10 seconds
    agreement_wdw_ms = 1000; % 1 second windows

    % Visual events: one event from 2-3 seconds
    visual_events = {'Ch1', [], [], [], 2000, 3000, 'test_comment'};

    % Auto events: one event from 2.5-3.5 seconds (partial overlap)
    auto_events = {'Ch1', [], [], [], 2500, 3500, 'test_comment'};

    confusion_matrix = compute_confusion_matrix(agreement_wdw_ms, visual_events, auto_events, fs, nrSamples);

    % Should have 4 elements: [TP, FP, FN, TN]
    if length(confusion_matrix) == 4 && all(confusion_matrix >= 0)
        passed = passed + 1;
        results{end+1} = struct('name', 'confusion_matrix_computation', 'passed', true, 'message', 'Confusion matrix computed successfully');
    else
        results{end+1} = struct('name', 'confusion_matrix_computation', 'passed', false, 'message', 'Confusion matrix computation failed');
    end
catch ME
    results{end+1} = struct('name', 'confusion_matrix_computation', 'passed', false, 'message', ME.message);
end

end

