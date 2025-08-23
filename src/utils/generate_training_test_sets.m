function generate_training_test_sets(cfg, train_test_ratio)

% delete train and test folders
robust_rmdir(fullfile(cfg.workspacePath, "Scalp_Detections_Pruned_Merged_Train"))
robust_rmdir(fullfile(cfg.workspacePath, "Scalp_Detections_Pruned_Merged_Test"))

for si = 1:size(cfg.all_eegDataPaths,1)
    age_group = cfg.all_eegDataPaths{si};
    eegDataPath = strcat(cfg.eegDataPathRoot, age_group);
    filesList = dir(strcat(eegDataPath, '\**\*.edf'));

    fprintf('Processing age group: %s (%d subjects)\n', age_group, size(filesList,1));

    % seed to obtain always the same random selection
    train_nr = round(train_test_ratio*size(filesList,1));
    rng(42);
    is_training = false(size(filesList,1),1);
    is_training(randperm(size(filesList,1), train_nr)) = true;

    for fi = 1:size(filesList,1)
        eegFilepath = strcat(filesList(fi).folder, '\', filesList(fi).name);
        [filepath,subjName,ext] = fileparts(eegFilepath);
        eegFilepathParts = strsplit(filepath, '\');
        group_name = eegFilepathParts(end);
        auto_events_dir = strcat(cfg.workspacePath, "Scalp_Detections_Merged\", group_name, '\');
        auto_events_fpath = strcat(auto_events_dir, subjName, '_MOSSDET_Scalp_Detections.mat');
        dataset_name = 'Train';
        if ~is_training(fi)
           dataset_name = 'Test';
        end
        % Copy file to training folder
        train_dest_dir = strcat(cfg.workspacePath, "Scalp_Detections_Pruned_Merged_", dataset_name, "\", group_name, '\');
        if ~exist(train_dest_dir, 'dir')
            mkdir(train_dest_dir);
        end
        train_dest_fpath = strcat(train_dest_dir, subjName, '_MOSSDET_Scalp_Detections.mat');
        copyfile(auto_events_fpath, train_dest_fpath);

    end
end
end