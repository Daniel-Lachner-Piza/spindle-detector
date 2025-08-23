function metrics = compute_performance_metrics(confusion_matrix)
tp = confusion_matrix(1);
fp = confusion_matrix(2);
fn = confusion_matrix(3);
tn = confusion_matrix(4);

% Handle division by zero cases
% Kappa calculation
denominator_kappa = (tp+fp) * (fp+tn) + (tp+fn)*(fn+tn);
if denominator_kappa == 0
    metrics.kappa = 0;  % Perfect agreement or no events
else
    metrics.kappa = (2 * (tp*tn - fn*fp)) / denominator_kappa;
end

% F1 Score calculation
denominator_f1 = 2*tp + fp + fn;
if denominator_f1 == 0
    metrics.fOneScore = 0;  % No true positives, false positives, or false negatives
else
    metrics.fOneScore = (2*tp) / denominator_f1;
end

% Sensitivity (Recall) calculation
denominator_sens = tp + fn;
if denominator_sens == 0
    metrics.sensitivity = 0;  % No actual positives
else
    metrics.sensitivity = tp / denominator_sens;
end

% Specificity calculation
denominator_spec = tn + fp;
if denominator_spec == 0
    metrics.specificity = 0;  % No actual negatives
else
    metrics.specificity = tn / denominator_spec;
end

% Precision calculation
denominator_prec = tp + fp;
if denominator_prec == 0
    metrics.precision = 0;  % No predicted positives
else
    metrics.precision = tp / denominator_prec;
end

end