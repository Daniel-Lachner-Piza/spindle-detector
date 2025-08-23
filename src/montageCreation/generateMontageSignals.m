function [mtgLabels, mtgSignals] = generateMontageSignals(unipSignals, unipLabels, goalMtgLabels)
    nrSamples = size(unipSignals,2);
    mtgLabelsTemp = lower(goalMtgLabels);
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
            mtgEntree = {goalMtgLabels{mi}, chAIdx, chBIdx};
            cnsldtMtgList = [cnsldtMtgList; mtgEntree];
        end
    end
    nrMtgs = size(cnsldtMtgList,1);
    mtgLabels = cnsldtMtgList(:,1);

    mtgSignals = [];
    if size(unipSignals,2)>0
        mtgSignals = zeros(nrMtgs, nrSamples);
        for mi = 1:nrMtgs
            sigA = unipSignals(cnsldtMtgList{mi,2},:);
            sigB = unipSignals(cnsldtMtgList{mi,3},:);
            mtgSignal = sigA - sigB;
            mtgSignals(mi,:) = mtgSignal;
        end
    end
end