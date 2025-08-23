function events_ls = add_features(events_ls, eegBPSignal, cwt_frqs, cwt_mat, prune_pow)
    nr_events = size(events_ls,1);
    detsStartSamples = events_ls(:,5);
    detsEndSamples = events_ls(:,6);
    keep_dets_sel = true(nr_events,1);
    for ei = 1:nr_events
        if detsStartSamples{ei}<1
            detsStartSamples{ei} = 1;
        end
        if detsEndSamples{ei}>size(eegBPSignal,2)
            detsEndSamples{ei} = size(eegBPSignal,2);
        end

        % get band-passed power
        detect_bp_signal = eegBPSignal(detsStartSamples{ei}:detsEndSamples{ei});
        detect_bp_signal = detect_bp_signal - mean(detect_bp_signal);
        bp_power = mean(detect_bp_signal.*detect_bp_signal, 'all');
        
        % get peak frequency
        cfs = cwt_mat(:, detsStartSamples{ei}:detsEndSamples{ei});
        cwt_power_sig = cfs.*cfs;
        [max_val, max_idx] = max(mean(cwt_power_sig,2));
        event_peak_frequency = cwt_frqs(max_idx);
    
        % Wavelet based power
        favg_cwt_powsig = mean(cwt_power_sig, 1);
        cwt_power_a = mean(cwt_power_sig, 'all');
        cwt_power_b = prctile (favg_cwt_powsig, 75);
        cwt_power_c = mean(favg_cwt_powsig(favg_cwt_powsig>median(favg_cwt_powsig)));

        % Duration
        duration_ms = 1000*(events_ls{ei,4}-events_ls{ei,3});

        detect_comment = [...
            string(...
                strcat(...
                    num2str(bp_power),',',...
                    num2str(event_peak_frequency),',',...
                    num2str(duration_ms)...
                )...
            )...
            ];
        events_ls{ei,7} = detect_comment;
        % if prune_pow
        %     %keep_dets_sel(ei) = bp_power > 20;
        %     pass=0;
        % end
    end
    events_ls = events_ls(keep_dets_sel,:);
end