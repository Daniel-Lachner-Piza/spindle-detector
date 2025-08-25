clc; clear all; close all;
disp(mfilename('fullpath'))
addpath(genpath('src')); 

cfg = startup_cfg();
fieldtrip_init(cfg);

%run_spindle_auto_detection;
%run_visual_spindles_characterization;

agreement_wdw_ms = 1;
auto_events_bppow_th_ls = 0:0.1:30;
auto_events_prop_th_ls = 1:1:4;
train_test_ratio = 0.6;

plot_ok = false();
grid_search = [];
for bpi = 1:length(auto_events_bppow_th_ls)
    for pi = 1:length(auto_events_prop_th_ls)
        auto_events_bppow_th = auto_events_bppow_th_ls(bpi);
        auto_events_prop_th = auto_events_prop_th_ls(pi);
        run_auto_spindles_merge(cfg, auto_events_bppow_th, auto_events_prop_th);
        generate_training_test_sets(cfg, train_test_ratio);
        avg_kappa = get_spindles_visual_auto_agreement(cfg, agreement_wdw_ms, 'Train', plot_ok);
        [auto_events_bppow_th, auto_events_prop_th, avg_kappa]
        grid_search = [grid_search; [auto_events_bppow_th, auto_events_prop_th, avg_kappa]];
    end
end
[max_kappa, max_idx] = max(grid_search(:,3));
best_auto_events_bppow_th = grid_search(max_idx, 1);
best_auto_events_prop_th = grid_search(max_idx, 2);
fprintf('best_auto_events_bppow_th:       %.3f\n', best_auto_events_bppow_th);
fprintf('best_auto_events_prop_th:       %.3f\n', best_auto_events_prop_th);
fprintf('Train Avg Kappa:       %.3f\n', max_kappa);

plot_ok = true();
run_auto_spindles_merge(cfg, best_auto_events_bppow_th, best_auto_events_prop_th);
test_avg_kappa = get_spindles_visual_auto_agreement(cfg, agreement_wdw_ms, 'Test', plot_ok);

fprintf('best_auto_events_bppow_th:       %.3f\n', best_auto_events_bppow_th);
fprintf('best_auto_events_prop_th:       %.3f\n', best_auto_events_prop_th);
fprintf('Train Avg Kappa:       %.3f\n', max_kappa);
fprintf('Test Avg Kappa:       %.3f\n', test_avg_kappa);

% OPTIMIZED_POWER_TH = 26.9;
% OPTIMIZED_EXTENT_TH = 4;
% OPTIM_TRAIN_KAPPA = 0.5;
% OPTIM_TEST_KAPPA=0.501;
OPTIMIZED_POWER_TH = best_auto_events_bppow_th;
OPTIMIZED_EXTENT_TH = best_auto_events_prop_th;


eeg_datapath_root =  "C:\Users\HFO\Documents\Postdoc_Calgary\Research\Tatsuya\PhysioEEGs\Non_Anonymized\";
eeg_data_subfolders = cfg.all_eegDataPaths;
post_process_detections(cfg, eeg_datapath_root, eeg_data_subfolders, OPTIMIZED_POWER_TH, OPTIMIZED_EXTENT_TH)
