function scalpMtgSel = selectScalpMontageIdxs(mtgLabels)
    nrMtgs = length(mtgLabels);
    scalpUnipLabels = getScalpChannelLabels();
    scalpMtgSel = false(nrMtgs,1);

    for mi = 1:nrMtgs
        mtgName = mtgLabels{mi};
        channA = mtgName(1:strfind(mtgName, '-')-1);
        channB = mtgName(strfind(mtgName, '-')+1:end);

        if sum(ismember(scalpUnipLabels, channA))>0 || sum(ismember(scalpUnipLabels, channB))>0
            scalpMtgSel(mi) = true;
        end

    end
end