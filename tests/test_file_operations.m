function [passed, total, results] = test_file_operations()
% TEST_FILE_OPERATIONS - Tests for file I/O and data handling

results = {};
passed = 0;
total = 0;

% Test MAT file operations
try
    total = total + 1;

    % Create test data
    test_data = struct();
    test_data.detections = {'Ch1', [], [], [], 1000, 2000, 'test_comment'};
    test_data.subjName = 'TestSubject';
    test_data.mtgLabels = {'Ch1-Ch2', 'Ch3-Ch4'};

    % Create temporary file
    temp_file = fullfile(tempdir, 'test_detections.mat');

    % Save data
    detections = test_data.detections;
    subjName = test_data.subjName;
    mtgLabels = test_data.mtgLabels;
    save(temp_file, 'detections', 'subjName', 'mtgLabels');

    % Load data back
    loaded_data = load(temp_file);

    % Verify data integrity
    if isfield(loaded_data, 'detections') && ...
            isfield(loaded_data, 'subjName') && ...
            isfield(loaded_data, 'mtgLabels') && ...
            strcmp(loaded_data.subjName, test_data.subjName)
        passed = passed + 1;
        results{end+1} = struct('name', 'mat_file_save_load', 'passed', true, 'message', 'MAT file save/load successful');
    else
        results{end+1} = struct('name', 'mat_file_save_load', 'passed', false, 'message', 'MAT file save/load failed');
    end

    % Clean up
    if exist(temp_file, 'file')
        delete(temp_file);
    end

catch ME
    results{end+1} = struct('name', 'mat_file_save_load', 'passed', false, 'message', ME.message);
end

% Test directory creation and validation
try
    total = total + 1;

    test_dir = fullfile(tempdir, 'test_spindle_dir', 'subdir');

    % Test directory creation
    if ~exist(test_dir, 'dir')
        mkdir(test_dir);
    end

    if exist(test_dir, 'dir')
        passed = passed + 1;
        results{end+1} = struct('name', 'directory_creation', 'passed', true, 'message', 'Directory creation successful');

        % Clean up
        rmdir(fullfile(tempdir, 'test_spindle_dir'), 's');
    else
        results{end+1} = struct('name', 'directory_creation', 'passed', false, 'message', 'Directory creation failed');
    end

catch ME
    results{end+1} = struct('name', 'directory_creation', 'passed', false, 'message', ME.message);
end

% Test file path validation and parsing
try
    total = total + 1;

    % Test file path parsing
    test_filepath = 'C:\path\to\file\TestSubject.edf';
    [filepath, subjName, ext] = fileparts(test_filepath);

    if strcmp(subjName, 'TestSubject') && strcmp(ext, '.edf')
        passed = passed + 1;
        results{end+1} = struct('name', 'filepath_parsing', 'passed', true, 'message', 'File path parsing successful');
    else
        results{end+1} = struct('name', 'filepath_parsing', 'passed', false, 'message', 'File path parsing failed');
    end

catch ME
    results{end+1} = struct('name', 'filepath_parsing', 'passed', false, 'message', ME.message);
end

% Test CSV/Excel file handling simulation
try
    total = total + 1;

    % Create test table data
    test_table = table(...
        {'Group1'; 'Group2'; 'Group3'}, ...
        {'Subj1'; 'Subj2'; 'Subj3'}, ...
        [0.85; 0.92; 0.78], ...
        [0.90; 0.88; 0.82], ...
        [0.75; 0.85; 0.70], ...
        'VariableNames', {'AgeGroup', 'Subject', 'Sensitivity', 'Specificity', 'Kappa'});

    temp_csv = fullfile(tempdir, 'test_results.csv');

    % Test CSV writing
    writetable(test_table, temp_csv);

    if exist(temp_csv, 'file')
        % Test CSV reading
        loaded_table = readtable(temp_csv);

        if height(loaded_table) == height(test_table) && width(loaded_table) == width(test_table)
            passed = passed + 1;
            results{end+1} = struct('name', 'csv_file_operations', 'passed', true, 'message', 'CSV file operations successful');
        else
            results{end+1} = struct('name', 'csv_file_operations', 'passed', false, 'message', 'CSV data mismatch after read');
        end

        % Clean up
        delete(temp_csv);
    else
        results{end+1} = struct('name', 'csv_file_operations', 'passed', false, 'message', 'CSV file creation failed');
    end

catch ME
    results{end+1} = struct('name', 'csv_file_operations', 'passed', false, 'message', ME.message);
end

% Test file existence checking
try
    total = total + 1;

    % Test existing file
    temp_file = fullfile(tempdir, 'test_existence.txt');
    fid = fopen(temp_file, 'w');
    fprintf(fid, 'test content');
    fclose(fid);

    exists_check1 = exist(temp_file, 'file');
    delete(temp_file);
    exists_check2 = exist(temp_file, 'file');

    if exists_check1 && ~exists_check2
        passed = passed + 1;
        results{end+1} = struct('name', 'file_existence_check', 'passed', true, 'message', 'File existence checking works correctly');
    else
        results{end+1} = struct('name', 'file_existence_check', 'passed', false, 'message', 'File existence checking failed');
    end

catch ME
    results{end+1} = struct('name', 'file_existence_check', 'passed', false, 'message', ME.message);
end

% Test file copying operations
try
    total = total + 1;

    % Create source file
    source_file = fullfile(tempdir, 'source_test.mat');
    test_data = rand(10, 10);
    save(source_file, 'test_data');

    % Copy to destination
    dest_file = fullfile(tempdir, 'dest_test.mat');
    copyfile(source_file, dest_file);

    % Verify copy
    if exist(dest_file, 'file')
        loaded_data = load(dest_file);
        if isfield(loaded_data, 'test_data') && isequal(loaded_data.test_data, test_data)
            passed = passed + 1;
            results{end+1} = struct('name', 'file_copy_operation', 'passed', true, 'message', 'File copy operation successful');
        else
            results{end+1} = struct('name', 'file_copy_operation', 'passed', false, 'message', 'File copy data mismatch');
        end
    else
        results{end+1} = struct('name', 'file_copy_operation', 'passed', false, 'message', 'File copy failed');
    end

    % Clean up
    if exist(source_file, 'file'), delete(source_file); end
    if exist(dest_file, 'file'), delete(dest_file); end

catch ME
    results{end+1} = struct('name', 'file_copy_operation', 'passed', false, 'message', ME.message);
end

end
