clc; clear all; close all;
disp(mfilename('fullpath'))

cfg = startup_cfg();
fieldtrip_init(cfg);

cfg.eegDataPathRoot =  "C:\Users\HFO\Documents\Postdoc_Calgary\Research\Tatsuya\PhysioEEGs\Non_Anonymized\";

forceNewDetection = false();
prune_pow = false();
ensure_prop = false();

for si = 1:size(cfg.all_eegDataPaths,1)
    eegDataPath = strcat(cfg.eegDataPathRoot, cfg.all_eegDataPaths{si});

    detectionsPath = split(eegDataPath, '\');
    detectionsPath = strcat(cfg.workspacePath, cfg.eegType, '_Detections\', detectionsPath(end));
    mkdir(detectionsPath);

    filesList = dir(strcat(eegDataPath, '\**\*.edf'));

    allFilesDate = {};
    allFilesDuration = {};
    allFilesSamplingRate = {};

    for fi = 1:size(filesList,1)
        eegFilepath = strcat(filesList(fi).folder, '\', filesList(fi).name);
        [filepath,subjName,ext] = fileparts(eegFilepath);

        subjNameEEG = subjName
        subjNameEEG = strrep(subjNameEEG, '~', '');
        subjNameEEG = strrep(subjNameEEG, ' ', '');

        %% readScalpEEG
        [filepath,subjName,ext] = fileparts(eegFilepath);
        hdr = ft_read_header(eegFilepath);
        nrSamplesUnip = hdr.nSamples;
        fs = hdr.Fs;
        if fs < 256
            {subjName, fs}
            ('Sampling Rate under 256 Hz');
            continue;

        end

        durationS = nrSamplesUnip/fs;
        durationUnipM = durationS/60

        allFilesDate = cat(1, allFilesDate, {strcat(subjName, '.edf'), hdr.orig.RID});
        allFilesDuration = cat(1, allFilesDuration, {subjName, durationS});
        allFilesSamplingRate = cat(1, allFilesSamplingRate, fs);


        {fi, subjName, durationUnipM}

        unipLabels = hdr.label;
        unipSignals = ft_read_data(eegFilepath, 'begsample', 1, 'endsample', nrSamplesUnip);
        [mtgLabels, mtgSignals] = generateMontageSignals(unipSignals, unipLabels, cfg.goalScalpBipLabels);



        %% MOSSDET
        detectorName = 'MOSSDET'
        [rippleRate, frRate] = MOSSDET_spindle_detection(detectorName, subjName, fs, mtgLabels, mtgSignals, cfg.workspacePath, cfg.eegType, detectionsPath, prune_pow, ensure_prop, forceNewDetection);
    end
end
