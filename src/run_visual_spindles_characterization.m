clc; clear all; close all;
disp(mfilename('fullpath'))

cfg = startup_cfg();
fieldtrip_init(cfg);

force_recalc = true();
prune_pow = false();
ensure_prop = false();


for si = 1:size(cfg.all_eegDataPaths,1)
    eegDataPath = strcat(cfg.eegDataPathRoot, cfg.all_eegDataPaths{si});
    filesList = dir(strcat(eegDataPath, '\**\*.edf'));
    for fi = 1:size(filesList,1)
        eegFilepath = strcat(filesList(fi).folder, '\', filesList(fi).name);
        [filepath,subjName,ext] = fileparts(eegFilepath);
        merged_events_fpath = get_characterized_visual_events_fpath(cfg, eegFilepath);
        if ~isfile(merged_events_fpath) || force_recalc
            vis_marks = get_visual_marks(eegFilepath, eegDataPath);
            vis_marks_characterized = characterize_visual_marks(vis_marks, eegFilepath, cfg.goalScalpBipLabels, prune_pow, ensure_prop);

            subjName;
            detections = vis_marks_characterized;
            save(merged_events_fpath, 'detections', 'subjName');
        end
    end
end

function vis_marks = get_visual_marks(eegFilepath, eegDataPath)
vis_marks = {};
[filepath,subjName,ext] = fileparts(eegFilepath);
if contains(subjName, "~")
    first_sep = '~';
elseif contains(subjName, "-")
    first_sep = '-';
elseif contains(subjName, "_")
    first_sep = '_';
end
subjNameA = subjName(1:strfind(subjName, first_sep)-1);
subjNameB = subjName(strfind(subjName, first_sep)+1:strfind(subjName, "_")-1);
subjName

assert(~isempty(subjNameA) && ~isempty(subjNameB), "Name parts not recognized");

annotations_file_ls = dir(strcat(eegDataPath, '\**\*annotations*.mat'));
annotations_file_ls={annotations_file_ls(:).name};
pat_annots_sel = contains(annotations_file_ls,subjNameA, 'IgnoreCase', true) & contains(annotations_file_ls,subjNameB, 'IgnoreCase', true);
if sum(pat_annots_sel)>0
    pat_vis_annots_fpath = strcat(eegDataPath, '\',annotations_file_ls{pat_annots_sel});

    assert(isfile(pat_vis_annots_fpath), strcat("Annotations file not found", pat_vis_annots_fpath));
    if isfile(pat_vis_annots_fpath)

        vis_marks = load(pat_vis_annots_fpath);
        vis_marks = vis_marks.detections;
    end
end

end

function vis_marks_char_merged = characterize_visual_marks(vis_marks, eegFilepath, goalScalpBipLabels, prune_pow, ensure_prop)

vis_marks_char_merged = {};
if size(vis_marks,1)>1
    [filepath,subjName,ext] = fileparts(eegFilepath);

    subjNameEEG = subjName
    subjNameEEG = strrep(subjNameEEG, '~', '');
    subjNameEEG = strrep(subjNameEEG, ' ', '');

    %% readScalpEEG
    [filepath,subjName,ext] = fileparts(eegFilepath);
    hdr = ft_read_header(eegFilepath);
    nrSamplesUnip = hdr.nSamples;
    fs = hdr.Fs;
    assert(fs>64, "Sampling Rate under 64Hz")

    durationS = nrSamplesUnip/fs;
    durationUnipM = durationS/60;

    unipLabels = hdr.label;
    unipSignals = ft_read_data(eegFilepath, 'begsample', 1, 'endsample', nrSamplesUnip);
    [mtgLabels, mtgSignals] = generateMontageSignals(unipSignals, unipLabels, goalScalpBipLabels);
    nrMtgs = size(mtgSignals, 1);
    for chi = 1:nrMtgs
        eegSignal = mtgSignals(chi, :);
        eegBPSignal = getBandpassedSignal(fs, 512, 8, 20, eegSignal);
        eegBPSignal = eegBPSignal-mean(eegBPSignal);
        [cfs, cwt_frqs, coi] = cwt(eegSignal, 'amor', fs, 'FrequencyLimits',[8 20]);
        cwt_mat = real(cfs);
        montageName = mtgLabels{chi};
        ch_events_sel = strcmpi(vis_marks(:,1), montageName);
        ch_events = vis_marks(ch_events_sel,:);
        vis_marks(ch_events_sel,:) = add_features(vis_marks(ch_events_sel,:), eegBPSignal, cwt_frqs, cwt_mat, prune_pow);
        disp(strcat(subjName, " Channel ", num2str(chi), "/", num2str(nrMtgs)))
    end
    vis_marks_char_merged = vis_marks;%merge_events(vis_marks, fs, ensure_prop);
end
end

function merged_events_fpath = get_characterized_visual_events_fpath(cfg, eegFilepath)
[filepath,subjName,ext] = fileparts(eegFilepath);
subjName
eegFilepathParts = strsplit(filepath, '\');
group_name = eegFilepathParts(end);

merged_events_dir = strcat(cfg.workspacePath, "Characterized_Visual_Marks\", group_name, '\'); mkdir(merged_events_dir);
merged_events_fpath = strcat(merged_events_dir, subjName, '_characterized_visual_marks.mat');
end
