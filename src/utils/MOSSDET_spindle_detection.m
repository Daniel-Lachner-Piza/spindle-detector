%Example of MATLAB function used to detect HFO, the signal must be at least one minute long to allow the correct normalization of the features used for the detection
%System requirements: Windows 64 bit
function [rippleRate, frRate] = MOSSDET_spindle_detection(detectorName, subjName, fs, mtgLabels, mtgSignals, workspacePath, eegType, detectionsPath, prune_pow, ensure_prop, forceNewDetection)

ratesFN = strcat(workspacePath, eegType, '_Rates\', subjName, '_', detectorName, '_', eegType, '_Rates.mat');
detectionsFN = strcat(detectionsPath, '\', subjName, '_', detectorName, '_', eegType, '_Detections.mat');
rippleRate = [];
frRate = [];

if not(isfile(detectionsFN)) || forceNewDetection
    marksList = {};
    mossdetRates = [];
    nrMtgs = size(mtgSignals, 1);
    durationM = (size(mtgSignals,2)/fs)/60;

    t = datetime;
    timeStr = strcat(num2str(t.Day), '.', num2str(t.Month), '.',num2str(t.Year));
    timeStr = strcat(timeStr, '_',num2str(t.Hour), ':',num2str(t.Minute), ':',num2str(round(t.Second)));

    for chi = 1:nrMtgs
        chi
        montageName = mtgLabels{chi};

        % ensure a clean MOSSDET folder
        tmp_det_dir = strcat(subjName, '_', montageName);
        % Remove non-alphanumeric characters from directory name
        tmp_det_dir = regexprep(tmp_det_dir, '[^a-zA-Z0-9]', '');

        mossdetFolder = setup_detector(workspacePath, tmp_det_dir);

        eegSignal = mtgSignals(chi, :);
        eegBPSignal = getBandpassedSignal(fs, 512, 8, 20, eegSignal);
        eegBPSignal = eegBPSignal-mean(eegBPSignal);
        [cfs, cwt_frqs, coi] = cwt(eegSignal, 'amor', fs, 'FrequencyLimits',[8 20]);
        cwt_mat = real(cfs);


        %detect the Oscillation
        mossdetDetects = [];
        eegSignal = transpose(eegSignal);
        savedSignalPath = strcat(mossdetFolder, montageName, '.mat');
        save(savedSignalPath,'eegSignal');
        outputFolder = strcat(mossdetFolder, montageName, '\');
        outputFolder = strrep(outputFolder, '\', '\\'); % this string is passed to a c++ program so the backslash needs to be escaped by anoter backslash

        mossdetVariables.exePath = strcat(mossdetFolder, 'MOSSDET_c.exe');
        mossdetVariables.signalFilePath = savedSignalPath;
        mossdetVariables.decFunctionsPath = mossdetFolder;
        mossdetVariables.outputPath = outputFolder;
        mossdetVariables.startTime = 0;
        mossdetVariables.endTime = 60*60*243*65;
        mossdetVariables.samplingRate = fs;
        mossdetVariables.eoiType = 'SleepSpindles';%'HFO+IES'; %Options are 'HFO+IES' or 'SleepSpindles';
        mossdetVariables.verbose = 1;
        mossdetVariables.saveDetections = 1;

        command = strcat(mossdetVariables.exePath, {' '},...
            mossdetVariables.signalFilePath, {' '},...
            mossdetVariables.decFunctionsPath, {' '}, ...
            mossdetVariables.outputPath, {' '},...
            num2str(mossdetVariables.startTime), {' '},...
            num2str(mossdetVariables.endTime), {' '},...
            num2str(mossdetVariables.samplingRate), {' '},...
            mossdetVariables.eoiType, {' '},...
            num2str(mossdetVariables.verbose), {' '},...
            num2str(mossdetVariables.saveDetections));

        out_res = system(command{1});

        %read detections from generated text files instead of generating a
        %matlab file, which fails often
        MOSSDET_Detections = [];
        %MOSSDET_Detections = readDetections(mossdetVariables.outputPath, montageName, 'Ripple', MOSSDET_Detections);
        %MOSSDET_Detections = readDetections(mossdetVariables.outputPath, montageName, 'FastRipple', MOSSDET_Detections);
        %MOSSDET_Detections = readDetections(mossdetVariables.outputPath, montageName, 'Spike', MOSSDET_Detections);
        MOSSDET_Detections = readDetections(mossdetVariables.outputPath, montageName, 'Spindle', MOSSDET_Detections);

        delete(mossdetVariables.signalFilePath);
        rehash();
        pause(1);
        robust_rmdir(mossdetVariables.outputPath);
        %MOSSDET_Detections = getIES_CoincidentHFO(MOSSDET_Detections);

        if isempty(MOSSDET_Detections)
            mossdetDetects.mark = [];
            mossdetDetects.startSample = [];
            mossdetDetects.endSample = [];
        else
            [~,idx] = sort(MOSSDET_Detections(2,:)); % sort just the second row
            MOSSDET_Detections = MOSSDET_Detections(:,idx);   % sort the whole matrix using the sort indices

            mossdetDetects.mark = int64(MOSSDET_Detections(1,:));
            detectionStartTimesLocal = MOSSDET_Detections(2,:);
            detectionEndTimesLocal = MOSSDET_Detections(3,:);
            detectionStartSamplesLocal = int64(double(detectionStartTimesLocal).*double(mossdetVariables.samplingRate));
            detectionEndSamplesLocal = int64(double(detectionEndTimesLocal).*double(mossdetVariables.samplingRate));
            mossdetDetects.startSample = detectionStartSamplesLocal;
            mossdetDetects.endSample = detectionEndSamplesLocal;
        end
        mossdetRates = cat(1, mossdetRates, [sum(mossdetDetects.mark == 1)/durationM, sum(mossdetDetects.mark == 2)/durationM]);

        %% get detections file data
        %relevantDetsSel = mossdetDetects.mark == 1 | mossdetDetects.mark == 2 | mossdetDetects.mark == 3;
        relevantDetsSel = true(1, length(mossdetDetects.mark));
        relevantDetects.mark = mossdetDetects.mark(relevantDetsSel);
        relevantDetects.startSample = mossdetDetects.startSample(relevantDetsSel);
        relevantDetects.endSample = mossdetDetects.endSample(relevantDetsSel);

        nrDets = size(relevantDetects.mark,2);
        if nrDets > 0
            detsChannLabels = repmat({montageName}, nrDets, 1);
            detsTypeStr = repmat({''}, nrDets, 1);
            detsTypeStr((relevantDetects.mark == 1)) = repmat({'msdtRipple'}, sum(relevantDetects.mark == 1), 1);
            detsTypeStr((relevantDetects.mark == 2)) = repmat({'msdtFR'}, sum(relevantDetects.mark == 2), 1);
            detsTypeStr((relevantDetects.mark == 3)) = repmat({'msdtSpike'}, sum(relevantDetects.mark == 3), 1);

            detsTypeStr((relevantDetects.mark == 4)) = repmat({'msdtSpikeRipple'}, sum(relevantDetects.mark == 4), 1);
            detsTypeStr((relevantDetects.mark == 6)) = repmat({'msdtIsolRipple'}, sum(relevantDetects.mark == 6), 1);

            detsTypeStr((relevantDetects.mark == 5)) = repmat({'msdtSpikeFR'}, sum(relevantDetects.mark == 5), 1);
            detsTypeStr((relevantDetects.mark == 7)) = repmat({'msdtIsolFR'}, sum(relevantDetects.mark == 7), 1);

            detsTypeStr((relevantDetects.mark == 20)) = repmat({'msdtSPNDL'}, sum(relevantDetects.mark == 20), 1);

            detsStartTimes = num2cell(double(double(relevantDetects.startSample)/fs)');
            detsEndTimes = num2cell(double(double(relevantDetects.endSample)/fs)');
            detsStartSamples = num2cell(double(relevantDetects.startSample)');
            detsEndSamples = num2cell(double(relevantDetects.endSample)');

            detsComments = repmat({"MOSSDET"}, nrDets, 1);
            detsChannSpec = repmat({true()}, nrDets, 1);
            detsCreationTimes = repmat({timeStr}, nrDets, 1);
            detsUsers = repmat({'DLP_MOSSDET'}, nrDets, 1);


            % Add power info to detection comments
            newDets = cat(2, detsChannLabels, detsTypeStr, detsStartTimes, detsEndTimes, detsStartSamples, detsEndSamples, detsComments, detsChannSpec, detsCreationTimes, detsUsers);
            newDets = add_features(newDets, eegBPSignal, cwt_frqs, cwt_mat, prune_pow);
            if ~isempty(newDets)
                marksList = cat(1, marksList, newDets);
            end
        end
        robust_rmdir(mossdetFolder)
    end

    %marksList = merge_events(marksList, fs, ensure_prop);

    if ~isempty(marksList)
        % Cast to correct possible differences in type
        marksList(:,3) = cellfun(@double, marksList(:,3),'UniformOutput',false);  % startTime
        marksList(:,4) = cellfun(@double, marksList(:,4),'UniformOutput',false);  % endTime
        marksList(:,5) = cellfun(@int32, marksList(:,5),'UniformOutput',false);  % startSample
        marksList(:,6) = cellfun(@int32, marksList(:,6),'UniformOutput',false);  % endSample
    end

    detections = marksList;
    save(detectionsFN, 'detections', 'mtgLabels', 'subjName');
end
end

function MOSSDET_Detections = readDetections(outputFolder, channelsInfo, eventName, MOSSDET_Detections)

outputFolder = strrep(outputFolder, '\\', '\');
detectionOutFilename = strcat(outputFolder, 'MOSSDET_Output\', channelsInfo, '\DetectionFiles\', channelsInfo, '_', eventName, 'DetectionsAndFeatures.txt');
if not(isfile(detectionOutFilename))
    detectionOutFilename
    stop = 1;
    return;
end
%Description	ChannelName	StartTime(s)	EndTime(s)	MaxEventAmplitude	MaxEventPower	MaxEventSpectralPeak (Hz)	AvgBackgroundAmplitude	AvgBackgroundPower	BackgroundStdDev
[Description, ChannelName, StartTime, EndTime, MaxEventAmplitude, MaxEventPower, MaxEventSpectralPeak, AvgBackgroundAmplitude, AvgBackgroundPower, BackgroundStdDev] =...
    textread(detectionOutFilename, '%s\t%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f', 'headerlines', 1);

delete(detectionOutFilename);
mark = 0;
if strcmp(eventName, 'Ripple')
    mark = 1;
elseif strcmp(eventName, 'FastRipple')
    mark = 2;
elseif strcmp(eventName, 'Spike')
    mark = 3;
elseif strcmp(eventName, 'Spindle')
    mark = 20;
end
marksVec = zeros(1, length(Description)) + mark;
StartTime = transpose(StartTime);
EndTime = transpose(EndTime);

detectionsMatrix = [];
if isempty(MOSSDET_Detections)
    detectionsMatrix = cat(1, detectionsMatrix, marksVec);
    detectionsMatrix = cat(1, detectionsMatrix, StartTime);
    detectionsMatrix = cat(1, detectionsMatrix, EndTime);
else
    detectionsMatrix = cat(1, detectionsMatrix, cat(2, MOSSDET_Detections(1, :), marksVec));
    detectionsMatrix = cat(1, detectionsMatrix, cat(2, MOSSDET_Detections(2, :), StartTime));
    detectionsMatrix = cat(1, detectionsMatrix, cat(2, MOSSDET_Detections(3, :), EndTime));
end
MOSSDET_Detections = detectionsMatrix;
end

function MOSSDET_Detections = getIES_CoincidentHFO(MOSSDET_Detections)
nrDetections = size(MOSSDET_Detections, 2);

for fdi = 1:nrDetections    %iterate through HFO
    iesCoincidence = 0;
    fdType = MOSSDET_Detections(1, fdi);
    fdStart = MOSSDET_Detections(2, fdi);
    fdEnd = MOSSDET_Detections(3, fdi);
    fdDuration = fdEnd - fdStart;

    if(fdType == 3)
        continue;
    end

    for sdi = 1:nrDetections    %iterate through IES
        if (fdi == sdi || MOSSDET_Detections(1, sdi) ~= 3)
            continue;
        end
        sdStart = MOSSDET_Detections(2, sdi);
        sdEnd = MOSSDET_Detections(3, sdi);
        sdDuration = sdEnd - sdStart;
        overlapTime = getEventsOverlap(fdStart, fdEnd, sdStart, sdEnd);
        overlapPerc = 100*(overlapTime / fdDuration);
        if (100 * (overlapTime / sdDuration) > overlapPerc)
            overlapPerc = 100 * (overlapTime / sdDuration);
        end
        if overlapPerc > 50.0
            iesCoincidence = 1;
            break;
        end
    end

    %     - All Ripples     (1) -> any Ripple
    %     - All FR          (2) -> any FR
    %     - All IES         (3) -> any IES

    %     - IES_Ripples     (4) -> any Ripple coinciding with a IES
    %     - IES_FR          (5) -> any FR coinciding with a IES
    %     - isolRipples     (6) -> any Ripple not coinciding with IES
    %     - isolFR          (7) -> any FR not coinciding with IES

    if fdType == 1
        if iesCoincidence > 0
            MOSSDET_Detections = cat(2, MOSSDET_Detections, [4; fdStart; fdEnd]);
        else
            MOSSDET_Detections = cat(2, MOSSDET_Detections, [6; fdStart; fdEnd]);
        end
    elseif fdType == 2
        if iesCoincidence > 0
            MOSSDET_Detections = cat(2, MOSSDET_Detections, [5; fdStart; fdEnd]);
        else
            MOSSDET_Detections = cat(2, MOSSDET_Detections, [7; fdStart; fdEnd]);
        end
    end
end
end

function overlapTime = getEventsOverlap(feStart, feEnd, seStart, seEnd)
% Calculate temporal overlap between two events
% Input validation
if feStart >= feEnd || seStart >= seEnd
    warning('Invalid event duration: start time must be less than end time');
    overlapTime = 0;
    return;
end

% Calculate overlap using standard interval overlap formula
% This is more robust and handles all cases automatically
overlapStart = max(feStart, seStart);
overlapEnd = min(feEnd, seEnd);

% If overlap start is after overlap end, there's no overlap
if overlapStart >= overlapEnd
    overlapTime = 0;
else
    overlapTime = overlapEnd - overlapStart;
end

% Ensure non-negative result (should already be guaranteed by logic above)
overlapTime = max(0, overlapTime);
end

function mossdetFolder = setup_detector(workspacePath, subjName)
% Define the MOSSDET folder path
mossdetFolder = strcat(workspacePath, 'src\MOSSDET_', subjName, '\');
mossdetOriginFolder = strcat(workspacePath, 'src\MOSSDET_origin\');

% Check if MOSSDET folder exists and delete it
if exist(mossdetFolder, 'dir')
    robust_rmdir(mossdetFolder);
    fprintf('Deleted pre-existing MOSSDET folder: %s\n', mossdetFolder);
end

% Check if MOSSDET_origin folder exists
if exist(mossdetOriginFolder, 'dir')
    % Copy all contents from MOSSDET_origin to MOSSDET
    copyfile(mossdetOriginFolder, mossdetFolder, 'f');
    fprintf('Copied contents from MOSSDET_origin to MOSSDET folder: %s\n', mossdetFolder);
else
    warning('MOSSDET_origin folder not found: %s', mossdetOriginFolder);
end

end