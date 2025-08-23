function confusion_matrix = compute_confusion_matrix(agreement_wdw_ms, channel_events, channel_auto_events, fs, nrSamples)
% Create windows for agreement analysis based on specified duration
window_duration_ms = agreement_wdw_ms;
window_size_samples = round(fs * window_duration_ms / 1000);
spindle_half_dur = 1.5;

% Ensure minimum window size of 1 sample
window_size_samples = max(1, window_size_samples);

% Calculate number of windows needed to cover the entire signal
nr_windows = ceil(nrSamples / window_size_samples);

% Initialize vectors for visual and auto detections (1 = event present, 0 = no event)
visual_windows = zeros(nr_windows, 1);
auto_windows = zeros(nr_windows, 1);

% Mark windows that contain visual events
if ~isempty(channel_events)
    for ei = 1:size(channel_events, 1)
        event_mid = round(mean([channel_events{ei, 5}, channel_events{ei, 6}]));
        event_start = event_mid - round(spindle_half_dur*fs); % Start sample
        event_end = event_mid + round(spindle_half_dur*fs); % End sample
        %event_start = channel_events{ei, 5};
        %event_end = channel_events{ei, 6};

        % Ensure valid sample indices (1-based indexing)
        event_start = max(1, event_start);
        event_end = min(nrSamples, event_end);

        % Skip invalid events
        if event_start > event_end
            continue;
        end

        % Find which windows overlap with this event
        % Convert sample indices to window indices (0-based for calculation, then +1 for MATLAB)
        start_window = floor((event_start - 1) / window_size_samples) + 1;
        end_window = floor((event_end - 1) / window_size_samples) + 1;

        % Ensure window indices are within bounds
        start_window = max(1, start_window);
        end_window = min(nr_windows, end_window);

        % Mark all overlapping windows as containing an event
        visual_windows(start_window:end_window) = 1;
    end
end

% Mark windows that contain auto-detected events
if ~isempty(channel_auto_events)
    for ei = 1:size(channel_auto_events, 1)
        event_mid = round(mean([channel_auto_events{ei, 5}, channel_auto_events{ei, 6}]));
        event_start = event_mid - round(spindle_half_dur*fs); % Start sample
        event_end = event_mid + round(spindle_half_dur*fs); % End sample
        %event_start = channel_auto_events{ei, 5};
        %event_end = channel_auto_events{ei, 6};

        % Find which windows overlap with this event
        start_window = floor(event_start / window_size_samples) + 1;
        end_window = floor(event_end / window_size_samples) + 1;

        % Ensure window indices are within bounds
        start_window = max(1, start_window);
        end_window = min(nr_windows, end_window);

        % Mark all overlapping windows as containing an event
        auto_windows(start_window:end_window) = 1;
    end
end

% Calculate confusion matrix elements
true_positives = sum(visual_windows == 1 & auto_windows == 1);   % Both detect event
false_positives = sum(visual_windows == 0 & auto_windows == 1);  % Auto detects, visual doesn't
false_negatives = sum(visual_windows == 1 & auto_windows == 0);  % Visual detects, auto doesn't
true_negatives = sum(visual_windows == 0 & auto_windows == 0);   % Both detect no event

confusion_matrix = [true_positives, false_positives, false_negatives, true_negatives];
end