function [passed, total, results] = test_configuration()
% TEST_CONFIGURATION - Tests for configuration and setup functions

results = {};
passed = 0;
total = 0;

% Test startup_cfg function
try
    total = total + 1;
    cfg = startup_cfg();

    % Check required fields exist
    required_fields = {'workspacePath', 'eegType', 'goalScalpBipLabels', 'ftPath', ...
        'detectionsPath', 'eegDataPathRoot', 'all_eegDataPaths', 'outputPath'};

    all_fields_present = true;
    missing_fields = {};
    for i = 1:length(required_fields)
        if ~isfield(cfg, required_fields{i})
            all_fields_present = false;
            missing_fields{end+1} = required_fields{i};
        end
    end

    if all_fields_present
        passed = passed + 1;
        results{end+1} = struct('name', 'startup_cfg_fields', 'passed', true, 'message', 'All required fields present');
    else
        results{end+1} = struct('name', 'startup_cfg_fields', 'passed', false, ...
            'message', sprintf('Missing fields: %s', strjoin(missing_fields, ', ')));
    end
catch ME
    results{end+1} = struct('name', 'startup_cfg_fields', 'passed', false, 'message', ME.message);
end

% Test workspace path validity
try
    total = total + 1;
    cfg = startup_cfg();

    if exist(cfg.workspacePath, 'dir')
        passed = passed + 1;
        results{end+1} = struct('name', 'workspace_path_exists', 'passed', true, 'message', 'Workspace path exists');
    else
        results{end+1} = struct('name', 'workspace_path_exists', 'passed', false, 'message', 'Workspace path does not exist');
    end
catch ME
    results{end+1} = struct('name', 'workspace_path_exists', 'passed', false, 'message', ME.message);
end

% Test goal scalp bipolar labels format
try
    total = total + 1;
    cfg = startup_cfg();

    % Check if goalScalpBipLabels is a cell array of strings with proper format
    labels_valid = true;
    if ~iscell(cfg.goalScalpBipLabels)
        labels_valid = false;
        error_msg = 'goalScalpBipLabels should be a cell array';
    else
        for i = 1:length(cfg.goalScalpBipLabels)
            label = cfg.goalScalpBipLabels{i};
            if ~ischar(label) && ~isstring(label)
                labels_valid = false;
                error_msg = 'All labels should be strings';
                break;
            end
            if ~contains(label, '-')
                labels_valid = false;
                error_msg = 'Labels should contain bipolar format (e.g., Fp1-F7)';
                break;
            end
        end
    end

    if labels_valid
        passed = passed + 1;
        results{end+1} = struct('name', 'scalp_labels_format', 'passed', true, 'message', 'Scalp labels properly formatted');
    else
        results{end+1} = struct('name', 'scalp_labels_format', 'passed', false, 'message', error_msg);
    end
catch ME
    results{end+1} = struct('name', 'scalp_labels_format', 'passed', false, 'message', ME.message);
end

% Test age groups configuration
try
    total = total + 1;
    cfg = startup_cfg();

    expected_groups = {'HFOHealthy1monto2yrs', 'HFOHealthy3to5yrs', 'HFOHealthy6to10yrs', ...
        'HFOHealthy11to13yrs', 'HFOHealthy14to17yrs'};

    if iscell(cfg.all_eegDataPaths) && length(cfg.all_eegDataPaths) == length(expected_groups)
        groups_match = true;
        for i = 1:length(expected_groups)
            % Convert string arrays to char for comparison
            group_found = false;
            for j = 1:length(cfg.all_eegDataPaths)
                if isstring(cfg.all_eegDataPaths{j})
                    actual_group = char(cfg.all_eegDataPaths{j});
                else
                    actual_group = cfg.all_eegDataPaths{j};
                end
                if strcmp(actual_group, expected_groups{i})
                    group_found = true;
                    break;
                end
            end
            if ~group_found
                groups_match = false;
                break;
            end
        end

        if groups_match
            passed = passed + 1;
            results{end+1} = struct('name', 'age_groups_config', 'passed', true, 'message', 'Age groups properly configured');
        else
            results{end+1} = struct('name', 'age_groups_config', 'passed', false, 'message', 'Age groups do not match expected values');
        end
    else
        results{end+1} = struct('name', 'age_groups_config', 'passed', false, 'message', 'Age groups not properly configured');
    end
catch ME
    results{end+1} = struct('name', 'age_groups_config', 'passed', false, 'message', ME.message);
end

% Test output path creation
try
    total = total + 1;
    cfg = startup_cfg();

    if exist(cfg.outputPath, 'dir')
        passed = passed + 1;
        results{end+1} = struct('name', 'output_path_creation', 'passed', true, 'message', 'Output path exists or was created');
    else
        results{end+1} = struct('name', 'output_path_creation', 'passed', false, 'message', 'Output path could not be created');
    end
catch ME
    results{end+1} = struct('name', 'output_path_creation', 'passed', false, 'message', ME.message);
end

end
