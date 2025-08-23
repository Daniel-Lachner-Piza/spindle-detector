function avg_kappa = get_spindles_visual_auto_agreement(cfg, agreement_wdw_ms, dataset_name, plot_ok)
kappa_scores_log = {};
for si = 1:size(cfg.all_eegDataPaths,1)
    age_group = cfg.all_eegDataPaths{si};
    eegDataPath = strcat(cfg.eegDataPathRoot, age_group);
    filesList = dir(strcat(eegDataPath, '\**\*.edf'));

    fprintf('Processing age group: %s (%d subjects)\n', age_group, size(filesList,1));

    for fi = 1:size(filesList,1)
        eegFilepath = strcat(filesList(fi).folder, '\', filesList(fi).name);

        [filepath,subjName,ext] = fileparts(eegFilepath);
        eegFilepathParts = strsplit(filepath, '\');
        group_name = eegFilepathParts(end);

        try
            %% Read EEG header only (no need to load full data)
            hdr = ft_read_header(eegFilepath);

            if hdr.Fs <= 64
                fprintf('  WARNING: Low sampling rate (%d Hz) for %s\n', hdr.Fs, subjName);
                continue;
            end

            % Get montage labels without loading full signals
            [mtgLabels, ~] = generateMontageSignals([], hdr.label, cfg.goalScalpBipLabels);
            nrSamples = hdr.nSamples;
            fs = hdr.Fs;
            nrMtgs = length(mtgLabels);


            %% Get merged and characterized visual events
            visual_events_dir = strcat(cfg.workspacePath, "Characterized_Visual_Marks\", group_name, '\');
            visual_events_fpath = strcat(visual_events_dir, subjName, '_characterized_visual_marks.mat');

            if ~exist(visual_events_fpath, 'file')
                fprintf('  WARNING: Visual events file not found for %s\n', subjName);
                continue;
            end

            visual_events = load(visual_events_fpath);
            visual_events = visual_events.detections;
            visual_events = merge_events(visual_events, fs, false());
            if isempty(visual_events)
                continue;
            end

            %% Get merged and characterized auto-detect events
            auto_events_dir = strcat(cfg.workspacePath, "Scalp_Detections_First_Run\", group_name, '\');
            auto_events_dir = strcat(cfg.workspacePath, "Scalp_Detections_Pruned_Merged\", group_name, '\');
            auto_events_dir = strcat(cfg.workspacePath, "Scalp_Detections_Pruned_Merged_", dataset_name, '\', group_name, '\');

            auto_events_fpath = strcat(auto_events_dir, subjName, '_MOSSDET_Scalp_Detections.mat');

            if ~exist(auto_events_fpath, 'file')
                fprintf('  WARNING: Auto events file not found for %s\n', subjName);
                continue;
            end

            auto_events = load(auto_events_fpath);
            auto_events = auto_events.detections;

            % Measure agreement
            confusion_matrix = [0,0,0,0];
            for chi = 1:nrMtgs
                ch_name = mtgLabels{chi};
                ch_vis_events = visual_events(strcmpi(visual_events(:,1), ch_name), :);
                ch_auto_events = auto_events(strcmpi(auto_events(:,1), ch_name), :);
                % Get kappa score between visual and auto events
                ch_confusion_matrix = compute_confusion_matrix(agreement_wdw_ms, ch_vis_events, ch_auto_events, fs, nrSamples);
                confusion_matrix = confusion_matrix+ch_confusion_matrix;
            end

            % Get kappa score between visual and auto events
            confusion_matrix = compute_confusion_matrix(agreement_wdw_ms, visual_events, auto_events, fs, nrSamples);

            kappa_score = compute_kappa_score(confusion_matrix);
            metrics = compute_performance_metrics(confusion_matrix);

            kappa_scores_log = cat(1, kappa_scores_log, {char(group_name), subjName, metrics.sensitivity, metrics.specificity, metrics.precision, metrics.kappa});

            fprintf('  %s: kappa = %.3f\n', subjName, kappa_score);

            pass=0;

        catch ME
            fprintf('  ERROR processing %s: %s\n', subjName, ME.message);
        end
    end
end

kappa_data = cell2mat(kappa_scores_log(:,6));
avg_kappa = mean(kappa_data);
fprintf('Avg Kappa:       %.3f ± %.3f\n', avg_kappa, std(kappa_data));

if plot_ok
    display_results(cfg, kappa_scores_log)
end
end

function display_results(cfg, kappa_scores_log)
%% Display and save results
fprintf('\n=== PERFORMANCE METRICS ANALYSIS ===\n');

if ~isempty(kappa_scores_log)
    % Convert to table for easier analysis
    results_table = cell2table(kappa_scores_log, 'VariableNames', ...
        {'AgeGroup', 'Subject', 'Sensitivity', 'Specificity', 'Precision', 'Kappa'});

    % Display summary statistics
    fprintf('Total subjects analyzed: %d\n', size(results_table, 1));

    % Extract numeric data for analysis
    sensitivity_data = cell2mat(kappa_scores_log(:,3));
    specificity_data = cell2mat(kappa_scores_log(:,4));
    precision_data = cell2mat(kappa_scores_log(:,5));
    kappa_data = cell2mat(kappa_scores_log(:,6));

    % Overall statistics
    fprintf('\nOverall Performance Metrics:\n');
    fprintf('  Sensitivity: %.3f ± %.3f\n', mean(sensitivity_data), std(sensitivity_data));
    fprintf('  Specificity: %.3f ± %.3f\n', mean(specificity_data), std(specificity_data));
    fprintf('  Precision:   %.3f ± %.3f\n', mean(precision_data), std(precision_data));
    fprintf('  Kappa:       %.3f ± %.3f\n', mean(kappa_data), std(kappa_data));

    % Results by age group
    fprintf('\nResults by Age Group:\n');

    % Use predefined age group order from configuration
    unique_groups = cfg.all_eegDataPaths;

    for gi = 1:length(unique_groups)
        group_mask = strcmp(kappa_scores_log(:,1), unique_groups{gi});
        group_sens = cell2mat(kappa_scores_log(group_mask, 3));
        group_spec = cell2mat(kappa_scores_log(group_mask, 4));
        group_prec = cell2mat(kappa_scores_log(group_mask, 5));
        group_kappa = cell2mat(kappa_scores_log(group_mask, 6));

        fprintf('  %s (n=%d):\n', unique_groups{gi}, sum(group_mask));
        fprintf('    Sensitivity: %.3f ± %.3f\n', mean(group_sens), std(group_sens));
        fprintf('    Specificity: %.3f ± %.3f\n', mean(group_spec), std(group_spec));
        fprintf('    Precision:   %.3f ± %.3f\n', mean(group_prec), std(group_prec));
        fprintf('    Kappa:       %.3f ± %.3f\n', mean(group_kappa), std(group_kappa));
        fprintf('\n');
    end

    % Create boxplots for each metric by age group
    create_performance_boxplots(results_table, cfg);

    % Save results to Excel file
    save_results_to_excel(results_table, cfg);

else
    fprintf('No valid results found!\n');
end
end

function create_performance_boxplots(results_table, cfg)
% Create boxplots for each age group with all metrics in different colors
try
    % Use predefined age group order from configuration
    predefined_order = cfg.all_eegDataPaths;

    % Get available groups from data and ensure they are character arrays
    available_groups = unique(results_table.AgeGroup);
    if iscell(available_groups)
        available_groups = cellfun(@char, available_groups, 'UniformOutput', false);
    end

    % Filter to only include age groups that actually have data
    age_groups = {};
    for i = 1:length(predefined_order)
        if any(strcmp(predefined_order{i}, available_groups))
            age_groups{end+1} = predefined_order{i};
        end
    end

    % Prepare data for boxplots
    metrics = {'Sensitivity', 'Specificity', 'Precision', 'Kappa'};
    colors = [0.2 0.6 0.8; 0.8 0.4 0.2; 0.4 0.8 0.3; 0.8 0.2 0.6]; % Blue, Orange, Green, Magenta

    % Calculate subplot layout
    num_groups = length(age_groups);
    num_cols = min(5, num_groups); % Max 5 columns
    num_rows = ceil(num_groups / num_cols);

    % Create a figure with subplots for each age group
    figure('Position', [100, 100, 400*num_cols, 300*num_rows]);

    for gi = 1:length(age_groups)
        subplot(num_rows, num_cols, gi);

        % Get data for this age group
        group_mask = strcmp(results_table.AgeGroup, age_groups{gi});
        group_data = results_table(group_mask, :);

        % Prepare data for boxplot - combine all metrics
        all_metric_data = [];
        all_metric_labels = {};

        for mi = 1:length(metrics)
            metric_values = group_data.(metrics{mi});
            all_metric_data = [all_metric_data; metric_values];
            all_metric_labels = [all_metric_labels; repmat(metrics(mi), length(metric_values), 1)];
        end

        % Create boxplot
        h = boxplot(all_metric_data, all_metric_labels, 'Colors', colors);

        % Customize the plot
        title(sprintf('%s (n=%d)', strrep(age_groups{gi}, 'HFOHealthy', ''), sum(group_mask)));
        xlabel('Performance Metrics');
        ylabel('Score');
        yticks(0:0.1:1);
        ylim([0,1]);
        grid on;
        grid minor;

        % Add mean values as colored diamonds
        hold on;
        for mi = 1:length(metrics)
            metric_values = group_data.(metrics{mi});
            mean_val = mean(metric_values);
            plot(mi, mean_val, 'd', 'MarkerSize', 8, 'MarkerFaceColor', colors(mi,:), ...
                'MarkerEdgeColor', 'black', 'LineWidth', 1);
        end
        hold off;

        % Set box colors
        for mi = 1:length(metrics)
            % Color the boxes
            patch(get(h(5,mi), 'XData'), get(h(5,mi), 'YData'), colors(mi,:), 'FaceAlpha', 0.3);
        end

        % Add statistics textbox
        stats_text = {};
        for mi = 1:length(metrics)
            metric_values = group_data.(metrics{mi});
            median_val = median(metric_values);
            mean_val = mean(metric_values);
            std_val = std(metric_values);

            stats_text{end+1} = sprintf('%s: Med=%.3f, Mean=%.3f, SD=%.3f', ...
                metrics{mi}, median_val, mean_val, std_val);
        end

        % Position textbox in upper right corner of subplot
        text(0.98, 0.98, stats_text, 'Units', 'normalized', ...
            'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', ...
            'FontSize', 8, 'BackgroundColor', 'white', 'EdgeColor', 'black', ...
            'Margin', 3);
    end

    % Add overall title
    sgtitle('Performance Metrics by Age Group');

    % Maximize the figure before saving
    set(gcf, 'WindowState', 'maximized');
    pause(0.5); % Brief pause to ensure the figure is fully maximized

    % Save the figure
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    figure_filename = sprintf('performance_boxplots_%s.png', timestamp);
    figure_filepath = fullfile(cfg.outputPath, figure_filename);
    saveas(gcf, figure_filepath);
    fprintf('Boxplots saved to: %s\n', figure_filepath);

catch ME
    warning('boxplot:failed', 'Failed to create boxplots: %s', ME.message);
end
end


function save_results_to_excel(results_table, cfg)
% Save results to Excel file with multiple sheets
try
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    excel_filename = sprintf('performance_metrics_%s.xlsx', timestamp);
    excel_filepath = fullfile(cfg.outputPath, excel_filename);

    % Save main results table
    writetable(results_table, excel_filepath, 'Sheet', 'All_Results');

    % Create summary statistics by age group
    age_groups = unique(results_table.AgeGroup);
    summary_data = [];

    for gi = 1:length(age_groups)
        group_mask = strcmp(results_table.AgeGroup, age_groups{gi});
        group_data = results_table(group_mask, :);

        % Calculate summary statistics for this group
        summary_row = {
            age_groups{gi}, ...
            sum(group_mask), ...
            mean(group_data.Sensitivity), std(group_data.Sensitivity), ...
            mean(group_data.Specificity), std(group_data.Specificity), ...
            mean(group_data.Precision), std(group_data.Precision), ...
            mean(group_data.Kappa), std(group_data.Kappa)
            };
        summary_data = [summary_data; summary_row];
    end

    % Create summary table
    summary_table = cell2table(summary_data, 'VariableNames', ...
        {'AgeGroup', 'N', 'Sensitivity_Mean', 'Sensitivity_Std', ...
        'Specificity_Mean', 'Specificity_Std', 'Precision_Mean', 'Precision_Std', ...
        'Kappa_Mean', 'Kappa_Std'});

    % Save summary to second sheet
    writetable(summary_table, excel_filepath, 'Sheet', 'Summary_by_AgeGroup');

    % Save individual age group sheets
    for gi = 1:length(age_groups)
        group_mask = strcmp(results_table.AgeGroup, age_groups{gi});
        group_table = results_table(group_mask, :);
        sheet_name = strrep(age_groups{gi}, 'HFOHealthy', ''); % Shorten sheet name
        writetable(group_table, excel_filepath, 'Sheet', sheet_name);
    end

    fprintf('Results saved to Excel file: %s\n', excel_filepath);
    fprintf('  - Sheet "All_Results": Complete dataset\n');
    fprintf('  - Sheet "Summary_by_AgeGroup": Summary statistics\n');
    for gi = 1:length(age_groups)
        sheet_name = strrep(age_groups{gi}, 'HFOHealthy', '');
        fprintf('  - Sheet "%s": %s data\n', sheet_name, age_groups{gi});
    end

catch ME
    warning('excel:failed', 'Failed to save Excel file: %s', ME.message);
    % Fallback to CSV
    try
        csv_filename = sprintf('performance_metrics_%s.csv', timestamp);
        csv_filepath = fullfile(cfg.outputPath, csv_filename);
        writetable(results_table, csv_filepath);
        fprintf('Fallback: Results saved to CSV file: %s\n', csv_filepath);
    catch
        warning('csv:failed', 'Failed to save CSV file as well.');
    end
end
end