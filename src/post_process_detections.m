function post_process_detections(cfg, eeg_datapath_root, eeg_data_subfolders, OPTIMIZED_POWER_TH, OPTIMIZED_EXTENT_TH)

fprintf('best_auto_events_bppow_th:       %.3f\n', OPTIMIZED_POWER_TH);
fprintf('best_auto_events_prop_th:       %.3f\n', OPTIMIZED_EXTENT_TH);

for si = 1:size(eeg_data_subfolders,1)
    age_group = eeg_data_subfolders{si};
    eegDataPath = strcat(eeg_datapath_root, age_group);
    filesList = dir(strcat(eegDataPath, '\**\*.edf'));

    fprintf('Processing age group: %s (%d subjects)\n', age_group, size(filesList,1));

    for fi = 1:size(filesList,1)
        eegFilepath = strcat(filesList(fi).folder, '\', filesList(fi).name);

        [filepath,subjName,ext] = fileparts(eegFilepath);
        eegFilepathParts = strsplit(filepath, '\');
        group_name = eegFilepathParts(end);

        hdr = ft_read_header(eegFilepath);
        try
            %% Get auto-detect events
            auto_events_dir = strcat(cfg.workspacePath, "Scalp_Detections\", group_name, '\');
            auto_events_fpath = strcat(auto_events_dir, subjName, '_MOSSDET_Scalp_Detections.mat');

            if ~exist(auto_events_fpath, 'file')
                fprintf('  WARNING: Auto events file not found for %s\n', subjName);
                continue;
            end

            loaded_events = load(auto_events_fpath);
            auto_events = loaded_events.detections;

            % remove auto events with bp-power below threshold
            auto_events = auto_events(extract_bp_power(auto_events(:, 7))>=OPTIMIZED_POWER_TH, :);

            auto_events = merge_events(auto_events, hdr.Fs, false());

            % remove auto events with bp-power below threshold
            auto_events = auto_events(extract_propagation_nr(auto_events(:, 7))>=OPTIMIZED_EXTENT_TH, :);

            auto_events_dir = strcat(cfg.workspacePath, "Post_Processed_Scalp_SleepSpindle_Detections\", group_name, '\');mkdir(auto_events_dir)
            auto_events_fpath = strcat(auto_events_dir, subjName, '_post-processed_MOSSDET_Scalp_Detections.mat');

            subjName = loaded_events.subjName;
            mtgLabels = loaded_events.mtgLabels;
            detections = auto_events;
            save(auto_events_fpath, 'detections', 'mtgLabels', 'subjName');


        catch ME
            fprintf('  ERROR processing %s: %s\n', subjName, ME.message);
        end
    end
end
end