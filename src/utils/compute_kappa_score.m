function kappa_score = compute_kappa_score(confusion_matrix)
true_positives = confusion_matrix(1);
false_positives = confusion_matrix(2);
false_negatives = confusion_matrix(3);
true_negatives = confusion_matrix(4);

% Calculate observed agreement
total_windows = sum(confusion_matrix);
observed_agreement = (true_positives + true_negatives) / total_windows;

% Calculate expected agreement by chance
% P(visual=1) * P(auto=1) + P(visual=0) * P(auto=0)
p_visual_positive = (true_positives + false_negatives) / total_windows;
p_auto_positive = (true_positives + false_positives) / total_windows;
p_visual_negative = 1 - p_visual_positive;
p_auto_negative = 1 - p_auto_positive;

expected_agreement = (p_visual_positive * p_auto_positive) + (p_visual_negative * p_auto_negative);

% Calculate Cohen's kappa
if abs(expected_agreement - 1) < eps
    % Perfect agreement by chance (within numerical precision)
    kappa_score = double(abs(observed_agreement - 1) < eps);
else
    kappa_score = (observed_agreement - expected_agreement) / (1 - expected_agreement);
end

% Clamp kappa to valid range [-1, 1] to handle numerical issues
kappa_score = max(-1, min(1, kappa_score));
end