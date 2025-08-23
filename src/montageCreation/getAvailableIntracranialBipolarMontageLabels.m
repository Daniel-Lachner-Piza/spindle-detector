% make bipolar montages with same letter channles and only(!) consecutive chann.numbers
function [excludedChannels, unipolarContacts, bipolarMontages] = getAvailableIntracranialBipolarMontageLabels(unipolarLabels)
	unipolarContacts = [];
    bipolarMontages = [];
    excludedChannels = {};
    scalpChannels = lower(getScalpChannelLabels());
    nonEEG_Channels = lower(getNonEEG_ChanelLabels());
    nrUnipolarChanns = length(unipolarLabels);
    numbers = ['0','1','2','3','4','5','6','7','8','9'];
    %Get Unipolar contacts
    for uniChIdx = 1:nrUnipolarChanns
		chLabel = unipolarLabels{uniChIdx};
        contact.contactName = chLabel;
        contact.contactGlobalIdx = uniChIdx;
        foundNrIndices = [];
        for ni = 1:length(numbers)
	        strIdx = strfind(chLabel, numbers(ni));
	        foundNrIndices = cat(2, foundNrIndices, strIdx);
        end
        firstNumIdx = min(foundNrIndices);
        lastNumIdx = max(foundNrIndices);
        contact.contactNr = str2double(chLabel(firstNumIdx:lastNumIdx));
        contact.electrodeName = chLabel(1:firstNumIdx-1);

        if sum(ismember(nonEEG_Channels, lower(contact.electrodeName))) == 0 && sum(ismember(nonEEG_Channels, lower(chLabel))) == 0
            if sum(ismember(scalpChannels, lower(chLabel))) == 0
                unipolarContacts = cat(1, unipolarContacts, contact);
            else
                disp(strcat("Scalp Channels mixed with Intracranial: ", chLabel));
                excludedChannels = cat(1, excludedChannels, chLabel);
            end
        else
            disp(strcat("Non EEG Channels in data: ", chLabel));
            excludedChannels = cat(1, excludedChannels, chLabel);
        end
    end
    
    %Get Bipolar Montages
    montageNr = 1;
    for upi = 1:size(unipolarContacts, 1)
        montage.firstElectrodeName = unipolarContacts(upi).electrodeName;
        montage.firstContactNr = unipolarContacts(upi).contactNr;
        montage.firstContactGlobalIdx = unipolarContacts(upi).contactGlobalIdx;
        
        for supi = 1:size(unipolarContacts, 1)
            if upi ~= supi
                montage.secondElectrodeName = unipolarContacts(supi).electrodeName;
                montage.secondContactNr = unipolarContacts(supi).contactNr;
                montage.secondContactGlobalIdx = unipolarContacts(supi).contactGlobalIdx;
                montage.montageName = strcat(unipolarContacts(upi).electrodeName, num2str(unipolarContacts(upi).contactNr),...
                                            '-',...
                                             unipolarContacts(supi).electrodeName, num2str(unipolarContacts(supi).contactNr));
                montage.montageMOSSDET_Nr = montageNr;
    
                
                if (strcmp(montage.firstElectrodeName, montage.secondElectrodeName) &&...
                    (montage.secondContactNr - montage.firstContactNr)==1)
                    bipolarMontages = cat(1, bipolarMontages, montage); 
                    montageNr = montageNr+1;
                end
            end
        end
    end
end