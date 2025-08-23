# Performance Metrics for Sleep Spindle Detection

This document provides detailed mathematical definitions and interpretations of the performance metrics used to evaluate the sleep spindle detection system.

## Overview

The sleep spindle detection system is evaluated using four key performance metrics that assess different aspects of detection accuracy. These metrics are calculated by comparing automatic detections with expert visual annotations (ground truth) within a specified temporal agreement window.

## Confusion Matrix Foundation

All performance metrics are derived from a confusion matrix with the following components:

- **True Positives (TP)**: Automatic detections that match visual annotations
- **False Positives (FP)**: Automatic detections with no corresponding visual annotation
- **True Negatives (TN)**: Correctly identified non-spindle periods
- **False Negatives (FN)**: Visual annotations missed by automatic detection

## Performance Metrics

### 1. Sensitivity (Recall)

**Definition**: The proportion of actual spindle events correctly detected by the automatic system.

**Mathematical Formula**:
```
Sensitivity = TP / (TP + FN)
```

**Interpretation**:
- Range: [0, 1], where 1 = perfect detection of all true spindles
- High sensitivity means few spindles are missed (low false negative rate)
- Clinical importance: Ensures most pathologically relevant spindles are detected

**Example**: If there are 100 visual spindles and the system detects 70 of them:
- Sensitivity = 70 / (70 + 30) = 0.70 (70%)

### 2. Specificity

**Definition**: The proportion of non-spindle periods correctly identified as such.

**Mathematical Formula**:
```
Specificity = TN / (TN + FP)
```

**Interpretation**:
- Range: [0, 1], where 1 = perfect rejection of non-spindle events
- High specificity means few false alarms (low false positive rate)
- Clinical importance: Reduces noise and maintains confidence in detections

**Example**: If there are 1000 non-spindle periods and the system correctly rejects 900:
- Specificity = 900 / (900 + 100) = 0.90 (90%)

### 3. Precision (Positive Predictive Value)

**Definition**: The proportion of automatic detections that correspond to actual spindle events.

**Mathematical Formula**:
```
Precision = TP / (TP + FP)
```

**Interpretation**:
- Range: [0, 1], where 1 = all detections are true spindles
- High precision means low false alarm rate among detections
- Clinical importance: Indicates reliability of positive detections

**Example**: If the system makes 150 detections and 120 are correct:
- Precision = 120 / (120 + 30) = 0.80 (80%)

### 4. Cohen's Kappa (κ)

**Definition**: A measure of inter-rater agreement that accounts for the possibility of agreement occurring by chance.

**Mathematical Formula**:
```
κ = (P_o - P_e) / (1 - P_e)

where:
P_o = Observed agreement = (TP + TN) / (TP + FP + TN + FN)
P_e = Expected agreement by chance = [(TP + FN)(TP + FP) + (FP + TN)(FN + TN)] / (TP + FP + TN + FN)²
```

**Alternative Formulation**:
```
κ = 2 × (TP × TN - FN × FP) / [(TP + FP)(FP + TN) + (TP + FN)(FN + TN)]
```

**Interpretation**:
- Range: [-1, 1], where:
  - κ = 1: Perfect agreement
  - κ = 0: Agreement no better than chance
  - κ < 0: Agreement worse than chance
- Advantages over accuracy: Accounts for class imbalance and chance agreement
- Clinical importance: Most robust metric for medical diagnostic systems

**Kappa Score Ranges**:
| Kappa Value | Strength of Agreement |
|-------------|----------------------|
| < 0.00 | Poor |
| 0.00 - 0.20 | Slight |
| 0.21 - 0.40 | Fair |
| 0.41 - 0.60 | Moderate |
| 0.61 - 0.80 | Substantial |
| 0.81 - 1.00 | Almost Perfect |

## Metric Relationships and Trade-offs

### Sensitivity vs. Specificity Trade-off
- Increasing detection threshold typically increases specificity but decreases sensitivity
- The optimal balance depends on clinical application requirements

### Precision vs. Recall Trade-off
- Similar to sensitivity/specificity but focuses on detection performance
- F1-score combines both: `F1 = 2 × (Precision × Sensitivity) / (Precision + Sensitivity)`

### Why Kappa is Preferred
1. **Accounts for chance agreement**: Unlike simple accuracy, kappa corrects for agreements that could occur randomly
2. **Handles class imbalance**: Robust performance measure even when spindle events are rare compared to non-spindle periods
3. **Single comprehensive metric**: Incorporates information from the entire confusion matrix
4. **Clinical standard**: Widely accepted in medical literature for diagnostic agreement studies

## Temporal Agreement Window

All metrics depend on the temporal agreement criterion used to match automatic detections with visual annotations:

- **Standard window**: ±0.5 seconds (1-second total window)
- **Rationale**: Accounts for slight temporal variations in manual marking while maintaining clinical relevance
- **Impact**: Wider windows increase apparent performance; narrower windows are more stringent

#### Sleep Spindle Detection Benchmarks

**Performance standards for automated spindle detection:**

**Scalp EEG (current system):**
- **κ > 0.50**: Minimally acceptable for research applications (lower bound)
- **κ > 0.60**: Clinically acceptable for automated detection systems  
- **κ > 0.70**: Good agreement suitable for most research applications
- **κ > 0.80**: Excellent agreement approaching manual expert consistency

**Context**: Scalp recordings typically achieve lower kappa scores than intracranial due to signal-to-noise limitations and artifact contamination.

## Implementation Notes

### Calculation Methodology
1. **Event matching**: Automatic detections are matched to visual annotations within the temporal agreement window
2. **One-to-one mapping**: Each detection can match at most one annotation and vice versa
3. **Closest temporal match**: When multiple matches are possible, the temporally closest pair is selected
4. **Per-subject calculation**: Metrics are calculated for each subject individually, then averaged across subjects within age groups

### Statistical Reporting
- **Central tendency**: Mean across subjects
- **Variability**: Standard deviation to indicate consistency
- **Sample size**: Number of subjects per age group for statistical power assessment

## References

1. Cohen, J. (1960). A coefficient of agreement for nominal scales. Educational and Psychological Measurement, 20(1), 37-46.
2. Landis, J.R. & Koch, G.G. (1977). The measurement of observer agreement for categorical data. Biometrics, 33(1), 159-174.
3. Warby, S.C., et al. (2014). Sleep-spindle detection: crowdsourcing and evaluating performance of experts, non-experts and automated methods. Nature Methods, 11(4), 385-392.
4. O'Reilly, C., et al. (2017). Automatic sleep spindle detection: benchmarking with fine temporal resolution using open science tools. Frontiers in Neuroinformatics, 11, 15.
5. Fawcett, T. (2006). An introduction to ROC analysis. Pattern Recognition Letters, 27(8), 861-874.
*References: 
6. Ferrarelli, F., et al. (2007). Reduced sleep spindle activity in schizophrenia patients. American Journal of Psychiatry, 164(3), 483-492.
7. Lajnef, T., et al. (2015). Learning machines and sleeping brains: automatic spindle detection using evolving fuzzy neural networks. Journal of Neural Engineering, 12(3), 036004.*
