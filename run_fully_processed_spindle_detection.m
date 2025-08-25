clc; clear all; close all;
disp(mfilename('fullpath'))
addpath(genpath('src')); 

cfg = startup_cfg();
fieldtrip_init(cfg);

%%
OPTIMIZED_POWER_TH = 26.5;
OPTIMIZED_EXTENT_TH = 4;
OPTIM_TRAIN_KAPPA = 0.493;
OPTIM_TEST_KAPPA=0.501;

fprintf('Optimized bppow th:       %.3f\n', OPTIMIZED_POWER_TH);
fprintf('Optimized propagation th:       %.3f\n', OPTIMIZED_EXTENT_TH);
fprintf('Train Avg Kappa:       %.3f\n', OPTIM_TRAIN_KAPPA);
fprintf('Test Avg Kappa:       %.3f\n', OPTIM_TEST_KAPPA);

%%
% run MOSSDET spindle detector
run_spindle_auto_detection;
% define path where to find EEG files
eeg_datapath_root =  "C:\Users\HFO\Documents\Postdoc_Calgary\Research\Tatsuya\PhysioEEGs\Non_Anonymized\"; 
eeg_data_subfolders = cfg.all_eegDataPaths;
post_process_detections(cfg, eeg_datapath_root, eeg_data_subfolders, OPTIMIZED_POWER_TH, OPTIMIZED_EXTENT_TH)
