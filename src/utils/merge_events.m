function merged_events_ls = merge_events(events_ls, fs, ensure_prop)

[~, sortIdx] = sort(cell2mat(events_ls(:,5)));
events_ls  =events_ls(sortIdx,:);

nr_events = size(events_ls, 1);
merged_events_ls = {};
processed = false(nr_events, 1);  % Track which events have been processed
spndl_ext = 3;
for ei_a = 1:nr_events
    if processed(ei_a)
        continue;  % Skip if already processed
    end

    overlapping_events_ls = {};
    overlapping_indices = [];

    % Find all events that overlap with event ei_a
    for ei_b = 1:nr_events
        if processed(ei_b)
            continue;  % Skip if already processed
        end

        event_a_start_sample = events_ls{ei_a,5};
        event_a_end_sample = events_ls{ei_a,6};
        middle_a = mean([event_a_start_sample , event_a_end_sample]);
        %[event_a_start_sample, event_a_end_sample]
        event_a_start_sample = middle_a-spndl_ext*fs;
        event_a_end_sample = middle_a+spndl_ext*fs;
        %[event_a_start_sample, event_a_end_sample]

        event_b_start_sample = events_ls{ei_b,5}-spndl_ext*fs;
        event_b_end_sample = events_ls{ei_b,6}+spndl_ext*fs;

        % Check for any overlap between events (covers all overlap cases)
        events_overlap = event_a_start_sample < event_b_end_sample && event_b_start_sample < event_a_end_sample;
        % events_overlap_1 = event_a_start_sample <= event_b_start_sample && event_a_end_sample >= event_b_end_sample;
        % events_overlap_2 = event_b_start_sample <= event_a_start_sample && event_b_end_sample >= event_a_end_sample;
        % events_overlap_3 = event_a_start_sample >= event_b_start_sample && event_a_start_sample <= event_b_end_sample;
        % events_overlap_4 = event_a_end_sample >= event_b_start_sample && event_a_end_sample <= event_b_end_sample;
        % events_overlap = events_overlap_1 || events_overlap_2 || events_overlap_3 || events_overlap_4;

        if events_overlap
            overlapping_events_ls = cat(1, overlapping_events_ls, events_ls(ei_b,:));
            overlapping_indices = [overlapping_indices, ei_b];
        end
    end

    if size(overlapping_events_ls,1) > 1
        % Multiple overlapping events - merge them
        ovle_start_time = cell2mat(overlapping_events_ls(:,3));
        ovle_end_time = cell2mat(overlapping_events_ls(:,4));
        ovle_start_sample = cell2mat(overlapping_events_ls(:,5));
        ovle_end_sample = cell2mat(overlapping_events_ls(:,6));

        comments = overlapping_events_ls(:,7);
        channels = overlapping_events_ls(:,1);
        ch_extent = length(unique(channels));

        if ch_extent ~= length(channels)
            % Multiple events on same channel - this might need special handling
            % For now, proceeding with merge
        end

        split_results = cellfun(@(x) strsplit(x, ','), comments, 'UniformOutput', false);
        flatSplitResults = vertcat(split_results{:});
        extra_feats = cellfun(@(x) str2double(x), flatSplitResults);
        power_vals = extra_feats(:,1);
        freq_vals = extra_feats(:,2);
        duration_vals = extra_feats(:,3);
        [mv, mi] = max(power_vals);
        event_to_keep = overlapping_events_ls(mi, :);

        % Add channel extent to comments
        event_to_keep{:,7} = strcat(event_to_keep{:,7}, ',', num2str(ch_extent));

        % adjust start and end
        % event_to_keep{:,3} = min(ovle_start_time);
        % event_to_keep{:,4} = max(ovle_end_time);
        % event_to_keep{:,5} = min(ovle_start_sample);
        % event_to_keep{:,6} = max(ovle_end_sample);
        
        merged_events_ls = cat(1, merged_events_ls, event_to_keep);

        % Mark all overlapping events as processed
        processed(overlapping_indices) = true;

    elseif size(overlapping_events_ls,1) == 1 && ~ensure_prop
        % Single event with no overlaps - keep as is
        event_to_keep = events_ls(ei_a,:);
        ch_extent = 1;
        event_to_keep{:,7} = strcat(event_to_keep{:,7}, ',', num2str(ch_extent));
        merged_events_ls = cat(1, merged_events_ls, event_to_keep);
        processed(ei_a) = true;
    end
end
end