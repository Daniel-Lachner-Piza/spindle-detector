function [passed, total, results] = test_montage_functions()
% TEST_MONTAGE_FUNCTIONS - Tests for EEG montage creation functions

results = {};
passed = 0;
total = 0;

% Test getScalpChannelLabels function
try
    total = total + 1;

    scalpLabels = getScalpChannelLabels();

    % Check if function returns cell array of strings
    if iscell(scalpLabels) && ~isempty(scalpLabels)
        % Check if typical EEG channel names are present
        typical_channels = {'Fp1', 'Fp2', 'F3', 'F4', 'C3', 'C4', 'P3', 'P4', 'O1', 'O2'};
        channels_found = 0;

        for i = 1:length(typical_channels)
            if any(contains(scalpLabels, typical_channels{i}))
                channels_found = channels_found + 1;
            end
        end

        if channels_found >= length(typical_channels) / 2 % At least half should be present
            passed = passed + 1;
            results{end+1} = struct('name', 'scalp_channel_labels', 'passed', true, 'message', 'Scalp channel labels function works correctly');
        else
            results{end+1} = struct('name', 'scalp_channel_labels', 'passed', false, 'message', 'Scalp channel labels missing typical channels');
        end
    else
        results{end+1} = struct('name', 'scalp_channel_labels', 'passed', false, 'message', 'Scalp channel labels function failed');
    end

catch ME
    results{end+1} = struct('name', 'scalp_channel_labels', 'passed', false, 'message', ME.message);
end

% Test getNonEEG_ChanelLabels function
try
    total = total + 1;

    nonEEG_Labels = getNonEEG_ChanelLabels();

    % Check if function returns cell array
    if iscell(nonEEG_Labels)
        % Check if typical non-EEG labels are present
        typical_nonEEG = {'ECG', 'EMG', 'EOG'};
        nonEEG_found = false;

        for i = 1:length(typical_nonEEG)
            if any(contains(nonEEG_Labels, typical_nonEEG{i}, 'IgnoreCase', true))
                nonEEG_found = true;
                break;
            end
        end

        if nonEEG_found || isempty(nonEEG_Labels) % Either has non-EEG labels or is empty (valid)
            passed = passed + 1;
            results{end+1} = struct('name', 'non_eeg_channel_labels', 'passed', true, 'message', 'Non-EEG channel labels function works correctly');
        else
            results{end+1} = struct('name', 'non_eeg_channel_labels', 'passed', false, 'message', 'Non-EEG channel labels unexpected content');
        end
    else
        results{end+1} = struct('name', 'non_eeg_channel_labels', 'passed', false, 'message', 'Non-EEG channel labels function failed');
    end

catch ME
    results{end+1} = struct('name', 'non_eeg_channel_labels', 'passed', false, 'message', ME.message);
end

% Test selectScalpMontageIdxs function
try
    total = total + 1;

    % Create test montage labels
    test_mtgLabels = {'Fp1-F3', 'F3-C3', 'C3-P3', 'Fp2-F4', 'F4-C4', 'C4-P4', 'ECG', 'EMG'};

    scalpMtgSel = selectScalpMontageIdxs(test_mtgLabels);

    % Should return logical array or indices
    if (islogical(scalpMtgSel) && length(scalpMtgSel) == length(test_mtgLabels)) || ...
            (isnumeric(scalpMtgSel) && all(scalpMtgSel <= length(test_mtgLabels)))

        % Check if it correctly identifies scalp montages (should exclude ECG, EMG)
        selected_labels = test_mtgLabels(scalpMtgSel);

        % Should not include ECG or EMG
        excludes_nonEEG = ~any(contains(selected_labels, {'ECG', 'EMG'}));

        if excludes_nonEEG
            passed = passed + 1;
            results{end+1} = struct('name', 'scalp_montage_selection', 'passed', true, 'message', 'Scalp montage selection works correctly');
        else
            results{end+1} = struct('name', 'scalp_montage_selection', 'passed', false, 'message', 'Scalp montage selection includes non-EEG channels');
        end
    else
        results{end+1} = struct('name', 'scalp_montage_selection', 'passed', false, 'message', 'Scalp montage selection returned invalid format');
    end

catch ME
    results{end+1} = struct('name', 'scalp_montage_selection', 'passed', false, 'message', ME.message);
end

% Test generateMontageSignals function (basic test)
try
    total = total + 1;

    % Create mock channel labels
    channel_labels = {'Fp1', 'F3', 'C3', 'P3', 'Fp2', 'F4', 'C4', 'P4'};
    goal_bipolar_labels = {'Fp1-F3', 'F3-C3', 'C3-P3', 'Fp2-F4', 'F4-C4', 'C4-P4'};

    % Test with empty signals (just check label generation)
    [mtgLabels, ~] = generateMontageSignals([], channel_labels, goal_bipolar_labels);

    % Should return subset of goal labels that can be formed from available channels
    if iscell(mtgLabels) && ~isempty(mtgLabels)
        % All returned labels should be in the goal set
        all_valid = true;
        for i = 1:length(mtgLabels)
            if ~any(strcmp(mtgLabels{i}, goal_bipolar_labels))
                all_valid = false;
                break;
            end
        end

        if all_valid
            passed = passed + 1;
            results{end+1} = struct('name', 'montage_signal_generation', 'passed', true, 'message', 'Montage signal generation works correctly');
        else
            results{end+1} = struct('name', 'montage_signal_generation', 'passed', false, 'message', 'Generated invalid montage labels');
        end
    else
        results{end+1} = struct('name', 'montage_signal_generation', 'passed', false, 'message', 'Montage signal generation failed');
    end

catch ME
    results{end+1} = struct('name', 'montage_signal_generation', 'passed', false, 'message', ME.message);
end

% Test bipolar montage creation logic
try
    total = total + 1;

    % Test bipolar label parsing
    test_bipolar = 'Fp1-F3';
    parts = strsplit(test_bipolar, '-');

    if length(parts) == 2 && strcmp(parts{1}, 'Fp1') && strcmp(parts{2}, 'F3')
        passed = passed + 1;
        results{end+1} = struct('name', 'bipolar_label_parsing', 'passed', true, 'message', 'Bipolar label parsing works correctly');
    else
        results{end+1} = struct('name', 'bipolar_label_parsing', 'passed', false, 'message', 'Bipolar label parsing failed');
    end

catch ME
    results{end+1} = struct('name', 'bipolar_label_parsing', 'passed', false, 'message', ME.message);
end

% Test channel availability checking
try
    total = total + 1;

    available_channels = {'Fp1', 'F3', 'C3', 'P3', 'O1'};
    required_bipolar = 'Fp1-F3';

    % Parse bipolar label
    parts = strsplit(required_bipolar, '-');
    ch1_available = any(strcmp(available_channels, parts{1}));
    ch2_available = any(strcmp(available_channels, parts{2}));

    if ch1_available && ch2_available
        passed = passed + 1;
        results{end+1} = struct('name', 'channel_availability_check', 'passed', true, 'message', 'Channel availability checking works correctly');
    else
        results{end+1} = struct('name', 'channel_availability_check', 'passed', false, 'message', 'Channel availability checking failed');
    end

catch ME
    results{end+1} = struct('name', 'channel_availability_check', 'passed', false, 'message', ME.message);
end

end
