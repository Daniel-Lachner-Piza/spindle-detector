function cfg = startup_cfg()
[path,~,~] = fileparts(mfilename('fullpath'));
cutIdx = strfind(path, '\');
cfg.workspacePath = path(1:cutIdx(end-1));

cfg.eegType = 'Scalp';

cfg.goalScalpBipLabels = {'Fp1-F7'; 'F7-T7'; 'T7-P7'; 'P7-O1'; 'F7-T3'; 'T3-T5'; 'T5-O1';...
    'Fp2-F8'; 'F8-T8'; 'T8-P8'; 'P8-O2'; 'F8-T4'; 'T4-T6'; 'T6-O2'; 'Fp1-F3'; 'F3-C3'; 'C3-P3';...
    'P3-O1'; 'Fp2-F4'; 'F4-C4'; 'C4-P4'; 'P4-O2'; 'FZ-CZ'; 'CZ-PZ'};

%% add workspace to search path
if strcmp('LAPTOP-TFQFNF6U', getenv('COMPUTERNAME'))
    cfg.ftPath = strcat('F:\Postdoc_Calgary\Research\fieldtrip-20221121');
elseif strcmp('DLP', getenv('COMPUTERNAME'))
    cfg.ftPath = strcat('C:\Users\HFO\Documents\Postdoc_Calgary\Research\fieldtrip-20221121');
end
cfg.detectionsPath = strcat(cfg.workspacePath, cfg.eegType, '_Detections');

cfg.eegDataPathRoot =  "C:\Users\HFO\Documents\Postdoc_Calgary\Research\Tatsuya\Hazem_Spindle_Annotation_2025\EEGs_Non_Anonymized\";
%cfg.eegDataPathRoot =  "C:\Users\HFO\Documents\Postdoc_Calgary\Research\Tatsuya\PhysioEEGs\Non_Anonymized\";
cfg.all_eegDataPaths = {"HFOHealthy1monto2yrs";"HFOHealthy3to5yrs";"HFOHealthy6to10yrs";"HFOHealthy11to13yrs";"HFOHealthy14to17yrs",};

% Output folder configuration
cfg.outputFolder = 'OutputFiles';
cfg.outputPath = fullfile(cfg.workspacePath, cfg.outputFolder);

% Create output directory if it doesn't exist
if ~exist(cfg.outputPath, 'dir')
    mkdir(cfg.outputPath);
end
end