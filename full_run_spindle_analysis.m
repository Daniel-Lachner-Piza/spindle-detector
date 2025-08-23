clc; clear all; close all;
disp(mfilename('fullpath'))
addpath(genpath('src')); 

cfg = startup_cfg();
fieldtrip_init(cfg);

%run_spindle_auto_detection;
%run_visual_spindles_characterization;

% best_auto_events_bppow_th = 20;
% best_auto_events_prop_th = 4;
% plot_ok = true();
% spindles_characterize_merge_auto_events(cfg, best_auto_events_bppow_th, best_auto_events_prop_th);
% test_avg_kappa = spindles_visual_auto_agreement(cfg, agreement_wdw_ms, 'Test', plot_ok);
