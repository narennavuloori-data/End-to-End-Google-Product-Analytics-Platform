# A/B Test Report

## Experiment

**Experiment:** New personalised homepage recommendation-ranking algorithm

- Control: Existing recommendation algorithm
- Treatment: New personalised recommendation algorithm
- Observation window: 14 days after first exposure

## Hypothesis

The new recommendation algorithm will increase average watch time per session without causing meaningful harm to viewer experience.

## Method

- Eligible experiment users were included.
- Each user belonged to only one variant.
- Control and Treatment were compared over the same 14-day window.
- A Welch independent-samples t-test was used for average metrics.
- A two-proportion z-test was used for rate metrics.
- A p-value below 0.05 was treated as statistically significant.
- A primary-metric uplift of at least 2% was treated as practically meaningful.

## Experiment Sample

- Control users: 5,939
- Treatment users: 5,916
- Users in multiple variants: 0
- Missing exposure dates: 0
- Exposure dates before assignment: 0

## Results

- **Average Watch Time per Session:** Control = 1.0577, Treatment = 1.0409, Difference = -0.0167, Uplift = -1.58%, 95% CI = [-0.2674, 0.2339], p-value = 0.8958
- **Videos Watched per Session:** Control = 0.1829, Treatment = 0.1576, Difference = -0.0253, Uplift = -13.83%, 95% CI = [-0.0425, -0.0081], p-value = 0.0040
- **Impression CTR:** Control = 40.0103, Treatment = 38.8411, Difference = -1.1692, Uplift = -2.92%, 95% CI = [-3.3858, 1.0474], p-value = 0.3013
- **Video Completion Rate:** Control = 48.8651, Treatment = 54.5521, Difference = 5.6870, Uplift = 11.64%, 95% CI = [2.0829, 9.2911], p-value = 0.0020
- **Engagement Rate:** Control = 29.2560, Treatment = 29.2790, Difference = 0.0230, Uplift = 0.08%, 95% CI = [-3.2644, 3.3103], p-value = 0.9891
- **Immediate Exit Rate:** Control = 0.0416, Treatment = 0.0000, Difference = -0.0416, Uplift = -100.00%, 95% CI = [-0.1232, 0.0399], p-value = 0.3249
- **Very Short View Rate:** Control = 12.5473, Treatment = 11.2163, Difference = -1.3310, Uplift = -10.61%, 95% CI = [-3.6642, 1.0023], p-value = 0.2653
- **Repeated Recommendation Rate:** Control = 0.0000, Treatment = 0.0000, Difference = 0.0000, Uplift = nan%, 95% CI = [0.0000, 0.0000], p-value = nan
- **Seven-Day Retention:** Control = 2.8288, Treatment = 2.6707, Difference = -0.1580, Uplift = -5.59%, 95% CI = [-0.7468, 0.4307], p-value = 0.5988

## Statistical Interpretation

The primary metric is not statistically significant.

The primary uplift does not meet the 2% practical threshold.

## Guardrail Analysis

No statistically significant guardrail harm above one percentage point was found.

Negative Feedback Rate was not available because the dataset has no dislike or not-interested event.

## Final Recommendation

Do not launch the treatment yet. Review the recommendation logic and run another test.

## Limitation

This is a synthetic educational experiment. The results demonstrate the analysis process and do not represent a real Google or YouTube experiment.