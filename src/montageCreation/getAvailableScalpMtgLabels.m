function cnsldtMtgList = getAvailableScalpMtgLabels(unipLabels, goalBipLabels)
    goalBipLabels = {'Fp1-F7'; 'F7-T7'; 'T7-P7'; 'P7-O1'; 'F7-T3'; 'T3-T5'; 'T5-O1';...
    'Fp2-F8'; 'F8-T8'; 'T8-P8'; 'P8-O2'; 'F8-T4'; 'T4-T6'; 'T6-O2'; 'Fp1-F3'; 'F3-C3'; 'C3-P3';...
    'P3-O1'; 'Fp2-F4'; 'F4-C4'; 'C4-P4'; 'P4-O2'; 'FZ-CZ'; 'CZ-PZ'};

    mtgLabelsTemp = lower(goalBipLabels);
    unipLabels = lower(unipLabels);

    % Find out how many of the goal mtgs are really present in the data
    cnsldtMtgList = {};
    for mi = 1:size(mtgLabelsTemp,1)
        montageName = mtgLabelsTemp{mi};
        chA = montageName(1:strfind(montageName, '-')-1);
        chB = montageName(strfind(montageName, '-')+1:end);
        chAIdx = find(ismember(unipLabels, chA));
        chBIdx = find(ismember(unipLabels, chB));
        if not(isempty(chAIdx) || isempty(chBIdx))
            mtgEntree = {goalBipLabels{mi}, chAIdx, chBIdx};
            cnsldtMtgList = [cnsldtMtgList; mtgEntree];
        end
    end
    nrMtgs = size(cnsldtMtgList,1);
end