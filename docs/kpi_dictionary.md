# KPI Dictionary

## End-to-End Google Product Analytics Platform  
### Product Focus: YouTube Viewer Experience

---

## 1. Purpose

This document defines the key product analytics metrics used across the project.

It ensures that the same KPI names, formulas, filters, and interpretations are used consistently in:

- SQL analysis
- Power BI dashboards
- A/B testing
- Executive reporting
- GitHub documentation

---

## 2. Important Disclaimer

This project uses a fully synthetic dataset created for educational and portfolio purposes.

It does not contain real Google or YouTube user data, internal company metrics, or proprietary business logic.

The KPI definitions in this document are realistic product analytics definitions created for this project and may not match Google or YouTube's internal metric definitions.

---

## 3. Core Data Sources

| Data Source | Purpose |
|---|---|
| `analytics.dim_user` | User profile, subscription, acquisition, and account attributes |
| `analytics.dim_video` | Video category, type, duration, language, and content attributes |
| `analytics.dim_channel` | Channel information |
| `analytics.dim_date` | Calendar attributes |
| `analytics.dim_device` | Device, operating system, app version, and network |
| `analytics.dim_geography` | Country and region |
| `analytics.fact_sessions` | One row per user session |
| `analytics.fact_events` | One row per user event |
| `analytics.fact_experiments` | One row per experiment-assigned user |

---

## 4. Standard Event Definitions

The following events are used in KPI calculations.

| Event Name | Definition |
|---|---|
| `app_open` | User opens the YouTube application or website |
| `homepage_view` | User views the homepage |
| `video_impression` | A video recommendation or thumbnail is shown |
| `video_click` | User clicks a video thumbnail |
| `video_start` | Video playback begins |
| `video_progress_25` | User reaches 25% of the video |
| `video_progress_50` | User reaches 50% of the video |
| `video_progress_75` | User reaches 75% of the video |
| `video_complete` | User reaches the defined completion threshold |
| `search` | User submits a search query |
| `like` | User likes a video |
| `comment` | User comments on a video |
| `share` | User shares a video |
| `subscribe_channel` | User subscribes to a channel |
| `save_to_watch_later` | User saves a video to Watch Later |
| `session_end` | User session ends |

---

## 5. General Calculation Rules

### 5.1 Active User

A user is considered active when they generate at least one valid product event during the selected period.

Recommended qualifying events:

- `app_open`
- `homepage_view`
- `search`
- `video_click`
- `video_start`
- `video_progress_25`
- `video_progress_50`
- `video_progress_75`
- `video_complete`
- `like`
- `comment`
- `share`
- `subscribe_channel`
- `save_to_watch_later`

### 5.2 Valid Session

A valid session must contain:

- A non-null `session_id`
- A valid `user_id`
- A valid session start timestamp
- A valid session end timestamp
- Session end timestamp greater than or equal to session start timestamp

### 5.3 Valid Video View

A valid video view is counted when a user generates a `video_start` event.

### 5.4 Completed Video View

A completed video view is counted when a user generates a `video_complete` event.

### 5.5 Engagement Action

The following events are treated as engagement actions:

- `like`
- `comment`
- `share`
- `subscribe_channel`
- `save_to_watch_later`

### 5.6 Safe Division

All rate calculations should use safe division.

If the denominator is zero, return `NULL` or blank instead of zero.

---

# 6. User Activity KPIs

## KPI 1: Daily Active Users

| Field | Definition |
|---|---|
| KPI Name | Daily Active Users |
| Abbreviation | DAU |
| Business Meaning | Number of unique users active on a specific day |
| Formula | Distinct active users per day |
| Numerator | Distinct `user_key` with at least one qualifying event |
| Denominator | Not applicable |
| Grain | Daily |
| Primary Source | `analytics.fact_events` |
| Recommended Visual | KPI card, line chart |
| Interpretation | Measures daily product usage |

### Formula

```text
DAU = DISTINCTCOUNT(active users on selected date)
```

---

## KPI 2: Weekly Active Users

| Field | Definition |
|---|---|
| KPI Name | Weekly Active Users |
| Abbreviation | WAU |
| Business Meaning | Number of unique users active during a rolling or calendar 7-day period |
| Formula | Distinct users active during the selected week |
| Grain | Weekly |
| Primary Source | `analytics.fact_events` |
| Recommended Visual | KPI card, weekly trend |
| Interpretation | Measures medium-term engagement |

### Formula

```text
WAU = DISTINCTCOUNT(active users during selected week)
```

---

## KPI 3: Monthly Active Users

| Field | Definition |
|---|---|
| KPI Name | Monthly Active Users |
| Abbreviation | MAU |
| Business Meaning | Number of unique users active during the selected month |
| Formula | Distinct users active during the selected month |
| Grain | Monthly |
| Primary Source | `analytics.fact_events` |
| Recommended Visual | KPI card, monthly trend |
| Interpretation | Measures the size of the active user base |

### Formula

```text
MAU = DISTINCTCOUNT(active users during selected month)
```

---

## KPI 4: DAU/MAU Stickiness

| Field | Definition |
|---|---|
| KPI Name | DAU/MAU Stickiness |
| Abbreviation | Stickiness |
| Business Meaning | Indicates how frequently monthly active users return on a typical day |
| Formula | Average DAU divided by MAU |
| Numerator | Average Daily Active Users |
| Denominator | Monthly Active Users |
| Grain | Monthly |
| Primary Source | `analytics.fact_events` |
| Recommended Visual | KPI card, trend line |
| Interpretation | Higher values indicate more frequent usage |

### Formula

```text
DAU/MAU Stickiness = Average DAU / MAU
```

---

## KPI 5: New Users

| Field | Definition |
|---|---|
| KPI Name | New Users |
| Business Meaning | Users whose signup date falls within the selected period |
| Formula | Distinct users with signup date in the selected period |
| Grain | Daily, weekly, or monthly |
| Primary Source | `analytics.dim_user` |
| Recommended Visual | KPI card, acquisition trend |
| Interpretation | Measures user acquisition volume |

---

## KPI 6: Returning Users

| Field | Definition |
|---|---|
| KPI Name | Returning Users |
| Business Meaning | Active users whose first activity occurred before the selected period |
| Formula | Active users minus new active users |
| Grain | Daily, weekly, or monthly |
| Primary Source | `analytics.fact_events`, `analytics.dim_user` |
| Recommended Visual | KPI card, stacked chart |
| Interpretation | Measures repeat product usage |

### Formula

```text
Returning Users = Active Users - New Active Users
```

---

## KPI 7: Returning User Rate

| Field | Definition |
|---|---|
| KPI Name | Returning User Rate |
| Business Meaning | Percentage of active users who are returning users |
| Numerator | Returning Users |
| Denominator | Total Active Users |
| Grain | Daily, weekly, or monthly |
| Primary Source | `analytics.fact_events`, `analytics.dim_user` |
| Recommended Visual | KPI card, trend line |

### Formula

```text
Returning User Rate = Returning Users / Active Users
```

---

# 7. Session KPIs

## KPI 8: Total Sessions

| Field | Definition |
|---|---|
| KPI Name | Total Sessions |
| Business Meaning | Total number of valid user sessions |
| Formula | Distinct count of `session_id` |
| Grain | Any selected period |
| Primary Source | `analytics.fact_sessions` |
| Recommended Visual | KPI card, trend chart |

---

## KPI 9: Average Session Duration

| Field | Definition |
|---|---|
| KPI Name | Average Session Duration |
| Business Meaning | Average amount of time users spend in one session |
| Formula | Total session duration divided by total valid sessions |
| Unit | Minutes |
| Grain | Any selected period |
| Primary Source | `analytics.fact_sessions` |
| Recommended Visual | KPI card, bar chart by segment |

### Formula

```text
Average Session Duration =
SUM(session_duration_minutes) / COUNT(valid sessions)
```

---

## KPI 10: Sessions per Active User

| Field | Definition |
|---|---|
| KPI Name | Sessions per Active User |
| Business Meaning | Average number of sessions generated by each active user |
| Numerator | Total Sessions |
| Denominator | Active Users |
| Grain | Daily, weekly, or monthly |
| Primary Source | `analytics.fact_sessions` |
| Recommended Visual | KPI card, trend line |

### Formula

```text
Sessions per Active User = Total Sessions / Active Users
```

---

## KPI 11: Videos Watched per Session

| Field | Definition |
|---|---|
| KPI Name | Videos Watched per Session |
| Business Meaning | Average number of started videos in each valid session |
| Numerator | Distinct valid video starts |
| Denominator | Total Sessions |
| Grain | Any selected period |
| Primary Source | `analytics.fact_events`, `analytics.fact_sessions` |
| Recommended Visual | KPI card, bar chart |

### Formula

```text
Videos Watched per Session =
Distinct Video Starts / Total Sessions
```

---

## KPI 12: Immediate Exit Rate

| Field | Definition |
|---|---|
| KPI Name | Immediate Exit Rate |
| Business Meaning | Percentage of sessions that end without a meaningful content interaction |
| Numerator | Sessions with no `video_start`, `search`, or engagement event |
| Denominator | Total Sessions |
| Grain | Any selected period |
| Primary Source | `analytics.fact_sessions`, `analytics.fact_events` |
| Recommended Visual | Guardrail KPI card |

### Formula

```text
Immediate Exit Rate =
Sessions Without Meaningful Interaction / Total Sessions
```

---

# 8. Viewing KPIs

## KPI 13: Total Video Starts

| Field | Definition |
|---|---|
| KPI Name | Total Video Starts |
| Business Meaning | Number of times video playback begins |
| Formula | Count of `video_start` events |
| Grain | Any selected period |
| Primary Source | `analytics.fact_events` |
| Recommended Visual | KPI card, trend chart |

---

## KPI 14: Unique Videos Watched

| Field | Definition |
|---|---|
| KPI Name | Unique Videos Watched |
| Business Meaning | Number of distinct videos started during the selected period |
| Formula | Distinct count of `video_key` for `video_start` events |
| Grain | Any selected period |
| Primary Source | `analytics.fact_events` |

---

## KPI 15: Total Watch Hours

| Field | Definition |
|---|---|
| KPI Name | Total Watch Hours |
| Business Meaning | Total watch time generated by users |
| Formula | Sum of watch duration seconds divided by 3,600 |
| Unit | Hours |
| Grain | Any selected period |
| Primary Source | `analytics.fact_events` |
| Recommended Visual | KPI card, trend line |

### Formula

```text
Total Watch Hours =
SUM(watch_duration_seconds) / 3600
```

### Important Rule

Use only the event row that stores final watch duration for the video view.

Do not sum cumulative progress-event durations, because that can double count watch time.

---

## KPI 16: Average Watch Time per User

| Field | Definition |
|---|---|
| KPI Name | Average Watch Time per User |
| Business Meaning | Average watch time generated by each active user |
| Numerator | Total Watch Minutes |
| Denominator | Active Users |
| Unit | Minutes |
| Grain | Any selected period |
| Primary Source | `analytics.fact_events` |

### Formula

```text
Average Watch Time per User =
Total Watch Minutes / Active Users
```

---

## KPI 17: Average Watch Time per Session

| Field | Definition |
|---|---|
| KPI Name | Average Watch Time per Session |
| Business Meaning | Average total video watch time generated during one session |
| Numerator | Total Watch Minutes |
| Denominator | Total Valid Sessions |
| Unit | Minutes |
| Grain | Session or selected period |
| Primary Source | `analytics.fact_events`, `analytics.fact_sessions` |
| Recommended Visual | KPI card, experiment comparison chart |

### Formula

```text
Average Watch Time per Session =
Total Watch Minutes / Total Sessions
```

### Experiment Role

This is the primary A/B testing metric.

---

## KPI 18: Average Watch Percentage

| Field | Definition |
|---|---|
| KPI Name | Average Watch Percentage |
| Business Meaning | Average percentage of a video's total duration watched |
| Numerator | Watch Duration Seconds |
| Denominator | Video Duration Seconds |
| Unit | Percentage |
| Grain | Video view |
| Primary Source | `analytics.fact_events`, `analytics.dim_video` |
| Recommended Visual | KPI card, content comparison chart |

### Formula

```text
Watch Percentage =
MIN(Watch Duration Seconds / Video Duration Seconds, 1)

Average Watch Percentage =
AVERAGE(Watch Percentage across valid video views)
```

### Exclusions

Exclude:

- Missing video duration
- Zero video duration
- Invalid negative watch duration
- Non-video events

---

## KPI 19: Video Completion Rate

| Field | Definition |
|---|---|
| KPI Name | Video Completion Rate |
| Business Meaning | Percentage of started videos that reach the completion threshold |
| Numerator | Distinct completed video views |
| Denominator | Distinct video starts |
| Unit | Percentage |
| Grain | Any selected period |
| Primary Source | `analytics.fact_events` |
| Recommended Visual | KPI card, category comparison |

### Formula

```text
Video Completion Rate =
Completed Video Views / Video Starts
```

### Important Rule

Count one completion per user-session-video combination to prevent duplicate event inflation.

---

## KPI 20: 50% Watch Rate

| Field | Definition |
|---|---|
| KPI Name | 50% Watch Rate |
| Business Meaning | Percentage of started videos that reach at least 50% progress |
| Numerator | Distinct views reaching `video_progress_50` or later |
| Denominator | Distinct video starts |
| Primary Source | `analytics.fact_events` |
| Recommended Visual | Funnel stage KPI |

### Formula

```text
50% Watch Rate =
Views Reaching 50% / Video Starts
```

---

## KPI 21: Very Short View Rate

| Field | Definition |
|---|---|
| KPI Name | Very Short View Rate |
| Business Meaning | Percentage of video starts with extremely low watch duration |
| Numerator | Video starts with watch duration below 10 seconds |
| Denominator | Total valid video starts |
| Unit | Percentage |
| Primary Source | `analytics.fact_events` |
| Recommended Visual | Experiment guardrail card |

### Formula

```text
Very Short View Rate =
Video Starts with Watch Duration < 10 Seconds / Video Starts
```

---

# 9. Discovery KPIs

## KPI 22: Video Impressions

| Field | Definition |
|---|---|
| KPI Name | Video Impressions |
| Business Meaning | Total number of video thumbnails or recommendations shown |
| Formula | Count of `video_impression` events |
| Grain | Any selected period |
| Primary Source | `analytics.fact_events` |

---

## KPI 23: Video Clicks

| Field | Definition |
|---|---|
| KPI Name | Video Clicks |
| Business Meaning | Total number of video thumbnail clicks |
| Formula | Count of `video_click` events |
| Grain | Any selected period |
| Primary Source | `analytics.fact_events` |

---

## KPI 24: Impression Click-Through Rate

| Field | Definition |
|---|---|
| KPI Name | Impression Click-Through Rate |
| Abbreviation | Impression CTR |
| Business Meaning | Percentage of displayed video impressions that lead to a click |
| Numerator | Valid Video Clicks |
| Denominator | Valid Video Impressions |
| Unit | Percentage |
| Grain | Any selected period |
| Primary Source | `analytics.fact_events` |
| Recommended Visual | KPI card, recommendation-source chart |

### Formula

```text
Impression CTR =
Video Clicks / Video Impressions
```

### Matching Rule

For the most accurate calculation, match click events to prior impressions using:

- Same `user_id`
- Same `session_id`
- Same `video_id`
- Click timestamp after impression timestamp

---

## KPI 25: Click-to-Start Rate

| Field | Definition |
|---|---|
| KPI Name | Click-to-Start Rate |
| Business Meaning | Percentage of video clicks that result in video playback |
| Numerator | Distinct video starts |
| Denominator | Distinct video clicks |
| Unit | Percentage |
| Primary Source | `analytics.fact_events` |
| Recommended Visual | Funnel metric |

### Formula

```text
Click-to-Start Rate =
Video Starts / Video Clicks
```

---

## KPI 26: Search Success Rate

| Field | Definition |
|---|---|
| KPI Name | Search Success Rate |
| Business Meaning | Percentage of searches followed by a video click or video start |
| Numerator | Searches followed by a video click or start within the same session |
| Denominator | Total Search Events |
| Unit | Percentage |
| Primary Source | `analytics.fact_events` |
| Recommended Visual | KPI card, search analysis chart |

### Formula

```text
Search Success Rate =
Successful Searches / Total Searches
```

### Recommended Success Window

A search is successful when a valid video click or video start occurs within 10 minutes after the search event in the same session.

---

## KPI 27: Recommendation CTR

| Field | Definition |
|---|---|
| KPI Name | Recommendation CTR |
| Business Meaning | Click-through rate for recommendations shown through a selected recommendation source |
| Numerator | Recommendation-linked video clicks |
| Denominator | Recommendation-linked video impressions |
| Unit | Percentage |
| Primary Source | `analytics.fact_events` |
| Recommended Breakdown | Homepage, Suggested Video, Subscriptions Feed |

### Formula

```text
Recommendation CTR =
Recommendation Clicks / Recommendation Impressions
```

---

## KPI 28: Recommendation-Driven Watch Share

| Field | Definition |
|---|---|
| KPI Name | Recommendation-Driven Watch Share |
| Business Meaning | Percentage of total watch time generated from recommendation-based traffic |
| Numerator | Watch time from homepage or suggested recommendation sources |
| Denominator | Total Watch Time |
| Unit | Percentage |
| Primary Source | `analytics.fact_events`, `analytics.fact_sessions` |

### Formula

```text
Recommendation-Driven Watch Share =
Recommendation Watch Time / Total Watch Time
```

---

# 10. Engagement KPIs

## KPI 29: Total Likes

| Field | Definition |
|---|---|
| KPI Name | Total Likes |
| Business Meaning | Total number of like actions |
| Formula | Count of `like` events |
| Primary Source | `analytics.fact_events` |

---

## KPI 30: Total Comments

| Field | Definition |
|---|---|
| KPI Name | Total Comments |
| Business Meaning | Total number of comment actions |
| Formula | Count of `comment` events |
| Primary Source | `analytics.fact_events` |

---

## KPI 31: Total Shares

| Field | Definition |
|---|---|
| KPI Name | Total Shares |
| Business Meaning | Total number of share actions |
| Formula | Count of `share` events |
| Primary Source | `analytics.fact_events` |

---

## KPI 32: Channel Subscriptions

| Field | Definition |
|---|---|
| KPI Name | Channel Subscriptions |
| Business Meaning | Total number of channel subscription actions |
| Formula | Count of `subscribe_channel` events |
| Primary Source | `analytics.fact_events` |

---

## KPI 33: Watch Later Saves

| Field | Definition |
|---|---|
| KPI Name | Watch Later Saves |
| Business Meaning | Total number of videos saved for later viewing |
| Formula | Count of `save_to_watch_later` events |
| Primary Source | `analytics.fact_events` |

---

## KPI 34: Engagement Actions

| Field | Definition |
|---|---|
| KPI Name | Engagement Actions |
| Business Meaning | Total number of high-intent actions performed by users |
| Formula | Likes + Comments + Shares + Subscriptions + Watch Later Saves |
| Primary Source | `analytics.fact_events` |

### Formula

```text
Engagement Actions =
Likes + Comments + Shares + Channel Subscriptions + Watch Later Saves
```

---

## KPI 35: Engagement Rate

| Field | Definition |
|---|---|
| KPI Name | Engagement Rate |
| Business Meaning | Percentage of video viewers who perform at least one engagement action |
| Numerator | Distinct viewers with at least one engagement action |
| Denominator | Distinct viewers with at least one video start |
| Unit | Percentage |
| Primary Source | `analytics.fact_events` |
| Recommended Visual | KPI card, segment comparison |

### Formula

```text
Engagement Rate =
Engaged Viewers / Video Viewers
```

### Important Rule

Use distinct users rather than total engagement events to avoid over-weighting highly active users.

---

## KPI 36: Engagement Actions per 1,000 Video Starts

| Field | Definition |
|---|---|
| KPI Name | Engagement Actions per 1,000 Video Starts |
| Business Meaning | Normalised engagement volume relative to video consumption |
| Numerator | Total Engagement Actions |
| Denominator | Total Video Starts |
| Scale | 1,000 |
| Primary Source | `analytics.fact_events` |

### Formula

```text
Engagement Actions per 1,000 Video Starts =
Engagement Actions / Video Starts × 1,000
```

---

## KPI 37: Subscriber Conversion Rate

| Field | Definition |
|---|---|
| KPI Name | Subscriber Conversion Rate |
| Business Meaning | Percentage of video viewers who subscribe to a channel |
| Numerator | Distinct users with `subscribe_channel` event |
| Denominator | Distinct users with `video_start` event |
| Unit | Percentage |
| Primary Source | `analytics.fact_events` |

### Formula

```text
Subscriber Conversion Rate =
Users Subscribing to a Channel / Video Viewers
```

---

# 11. Funnel KPIs

## Main Product Funnel

```text
Video Impression
→ Video Click
→ Video Start
→ Watched 50%
→ Video Complete
→ Engagement Action
```

## KPI 38: Funnel Entrants

| Field | Definition |
|---|---|
| KPI Name | Funnel Entrants |
| Business Meaning | Number of distinct users entering the first funnel stage |
| Formula | Distinct users with a `video_impression` event |
| Primary Source | `analytics.fact_events` |

---

## KPI 39: Step Conversion Rate

| Field | Definition |
|---|---|
| KPI Name | Step Conversion Rate |
| Business Meaning | Percentage of users moving from one funnel stage to the next |
| Numerator | Distinct users reaching the current stage |
| Denominator | Distinct users reaching the previous stage |
| Unit | Percentage |
| Primary Source | `analytics.fact_events` |

### Formula

```text
Step Conversion Rate =
Users at Current Stage / Users at Previous Stage
```

---

## KPI 40: Overall Funnel Conversion Rate

| Field | Definition |
|---|---|
| KPI Name | Overall Funnel Conversion Rate |
| Business Meaning | Percentage of funnel entrants who reach the final engagement stage |
| Numerator | Distinct users reaching final stage |
| Denominator | Distinct users entering first stage |
| Unit | Percentage |
| Primary Source | `analytics.fact_events` |

### Formula

```text
Overall Funnel Conversion Rate =
Users Reaching Engagement Stage / Funnel Entrants
```

---

## KPI 41: Funnel Drop-Off Count

| Field | Definition |
|---|---|
| KPI Name | Funnel Drop-Off Count |
| Business Meaning | Number of users lost between two consecutive stages |
| Numerator | Users at previous stage minus users at current stage |
| Primary Source | `analytics.fact_events` |

### Formula

```text
Funnel Drop-Off Count =
Users at Previous Stage - Users at Current Stage
```

---

## KPI 42: Funnel Drop-Off Rate

| Field | Definition |
|---|---|
| KPI Name | Funnel Drop-Off Rate |
| Business Meaning | Percentage of users who fail to move to the next funnel stage |
| Numerator | Funnel Drop-Off Count |
| Denominator | Users at previous stage |
| Unit | Percentage |
| Primary Source | `analytics.fact_events` |

### Formula

```text
Funnel Drop-Off Rate =
Drop-Off Count / Users at Previous Stage
```

---

# 12. Retention KPIs

## Retention Definition

A retained user is a user who returns and generates at least one qualifying activity event after their first active date.

Recommended qualifying retention activity:

- `app_open`
- `homepage_view`
- `search`
- `video_start`
- Any engagement action

---

## KPI 43: Day 1 Retention

| Field | Definition |
|---|---|
| KPI Name | Day 1 Retention |
| Business Meaning | Percentage of newly active users who return one day after first activity |
| Numerator | Cohort users active on Day 1 |
| Denominator | Total users in the cohort |
| Unit | Percentage |
| Primary Source | `analytics.fact_events` |

### Formula

```text
Day 1 Retention =
Users Active 1 Day After First Activity / Cohort Users
```

---

## KPI 44: Day 7 Retention

| Field | Definition |
|---|---|
| KPI Name | Day 7 Retention |
| Business Meaning | Percentage of cohort users who return seven days after first activity |
| Numerator | Cohort users active on Day 7 |
| Denominator | Total users in the cohort |
| Unit | Percentage |
| Primary Source | `analytics.fact_events` |

---

## KPI 45: Day 14 Retention

| Field | Definition |
|---|---|
| KPI Name | Day 14 Retention |
| Business Meaning | Percentage of cohort users who return fourteen days after first activity |
| Numerator | Cohort users active on Day 14 |
| Denominator | Total users in the cohort |
| Unit | Percentage |
| Primary Source | `analytics.fact_events` |

---

## KPI 46: Day 30 Retention

| Field | Definition |
|---|---|
| KPI Name | Day 30 Retention |
| Business Meaning | Percentage of cohort users who return thirty days after first activity |
| Numerator | Cohort users active on Day 30 |
| Denominator | Total users in the cohort |
| Unit | Percentage |
| Primary Source | `analytics.fact_events` |

---

## KPI 47: Weekly Retention Rate

| Field | Definition |
|---|---|
| KPI Name | Weekly Retention Rate |
| Business Meaning | Percentage of users from a weekly cohort who return in a later week |
| Numerator | Cohort users active in selected return week |
| Denominator | Total users in original weekly cohort |
| Unit | Percentage |
| Primary Source | `analytics.fact_events` |

---

## KPI 48: Monthly Cohort Retention

| Field | Definition |
|---|---|
| KPI Name | Monthly Cohort Retention |
| Business Meaning | Percentage of users from a monthly first-activity cohort who remain active in later months |
| Numerator | Cohort users active in selected month number |
| Denominator | Total users in original cohort |
| Unit | Percentage |
| Primary Source | `analytics.fact_events` |
| Recommended Visual | Cohort matrix |

### Formula

```text
Monthly Cohort Retention =
Retained Cohort Users / Original Cohort Users
```

---

# 13. User Segmentation KPIs

## KPI 49: Total Users by Segment

| Field | Definition |
|---|---|
| KPI Name | Total Users by Segment |
| Business Meaning | Number of users assigned to each behavioural segment |
| Formula | Distinct count of users by `user_segment` |
| Primary Source | `reporting.vw_user_segments` |
| Recommended Visual | Bar chart, donut chart |

---

## KPI 50: Segment Share

| Field | Definition |
|---|---|
| KPI Name | Segment Share |
| Business Meaning | Percentage of total users belonging to a selected segment |
| Numerator | Users in selected segment |
| Denominator | Total segmented users |
| Unit | Percentage |
| Primary Source | `reporting.vw_user_segments` |

### Formula

```text
Segment Share =
Users in Segment / Total Segmented Users
```

---

## KPI 51: At-Risk Users

| Field | Definition |
|---|---|
| KPI Name | At-Risk Users |
| Business Meaning | Previously active users showing a significant decline in recent activity |
| Example Rule | Active in prior 30 days but inactive in the most recent 14 days |
| Primary Source | `reporting.vw_user_segments` |
| Recommended Visual | KPI card, subscription breakdown |

### Important Note

The final threshold must remain consistent in SQL, Power BI, and documentation.

---

## KPI 52: Churned Users

| Field | Definition |
|---|---|
| KPI Name | Churned Users |
| Business Meaning | Users with no qualifying activity during the defined churn window |
| Example Rule | No activity during the most recent 30 days |
| Primary Source | `reporting.vw_user_segments` |

---

## KPI 53: Churn Rate

| Field | Definition |
|---|---|
| KPI Name | Churn Rate |
| Business Meaning | Percentage of previously active users classified as churned |
| Numerator | Churned Users |
| Denominator | Users eligible for churn evaluation |
| Unit | Percentage |
| Primary Source | `reporting.vw_user_segments` |

### Formula

```text
Churn Rate =
Churned Users / Churn-Eligible Users
```

---

# 14. Content Performance KPIs

## KPI 54: Watch Hours by Video Category

| Field | Definition |
|---|---|
| KPI Name | Watch Hours by Video Category |
| Business Meaning | Total watch hours generated by each content category |
| Formula | Sum of watch duration grouped by `video_category` |
| Primary Source | `analytics.fact_events`, `analytics.dim_video` |

---

## KPI 55: Completion Rate by Video Type

| Field | Definition |
|---|---|
| KPI Name | Completion Rate by Video Type |
| Business Meaning | Compares video completion across Shorts, Standard Videos, Live Streams, and Premieres |
| Formula | Completed Views / Video Starts by `video_type` |
| Primary Source | `analytics.fact_events`, `analytics.dim_video` |

---

## KPI 56: High-Impression, Low-CTR Videos

| Field | Definition |
|---|---|
| KPI Name | High-Impression, Low-CTR Videos |
| Business Meaning | Videos receiving strong exposure but weak click response |
| Example Rule | Impressions above median and CTR below median |
| Primary Source | `reporting.vw_content_performance` |
| Recommended Visual | Scatter plot or exception table |

---

## KPI 57: High-CTR, Low-Watch-Time Videos

| Field | Definition |
|---|---|
| KPI Name | High-CTR, Low-Watch-Time Videos |
| Business Meaning | Videos attracting clicks but failing to retain viewers |
| Example Rule | CTR above median and average watch percentage below median |
| Primary Source | `reporting.vw_content_performance` |
| Recommended Visual | Scatter plot or exception table |

---

## KPI 58: Channel Engagement Rate

| Field | Definition |
|---|---|
| KPI Name | Channel Engagement Rate |
| Business Meaning | Percentage of a channel's viewers who perform an engagement action |
| Numerator | Distinct engaged viewers for the channel |
| Denominator | Distinct video viewers for the channel |
| Unit | Percentage |
| Primary Source | `analytics.fact_events`, `analytics.dim_channel` |

---

# 15. A/B Testing KPIs

## Experiment Scenario

A hypothetical improved YouTube homepage recommendation-ranking algorithm is tested.

- **Control:** Existing recommendation experience
- **Treatment:** New personalised recommendation experience

---

## KPI 59: Experiment Sample Size

| Field | Definition |
|---|---|
| KPI Name | Experiment Sample Size |
| Business Meaning | Number of eligible users included in each experiment variant |
| Formula | Distinct count of experiment-assigned users |
| Primary Source | `analytics.fact_experiments` |

---

## KPI 60: Primary Metric Uplift

| Field | Definition |
|---|---|
| KPI Name | Primary Metric Uplift |
| Primary Metric | Average Watch Time per Session |
| Business Meaning | Relative improvement of treatment compared with control |
| Numerator | Treatment Mean minus Control Mean |
| Denominator | Control Mean |
| Unit | Percentage |
| Primary Source | Experiment analysis output |

### Formula

```text
Primary Metric Uplift =
(Treatment Mean - Control Mean) / Control Mean
```

---

## KPI 61: Absolute Lift

| Field | Definition |
|---|---|
| KPI Name | Absolute Lift |
| Business Meaning | Direct difference between treatment and control |
| Formula | Treatment Metric minus Control Metric |
| Unit | Same as the metric |
| Primary Source | Experiment analysis output |

### Formula

```text
Absolute Lift =
Treatment Metric - Control Metric
```

---

## KPI 62: Relative Lift

| Field | Definition |
|---|---|
| KPI Name | Relative Lift |
| Business Meaning | Percentage change in treatment relative to control |
| Formula | Absolute Lift divided by Control Metric |
| Unit | Percentage |
| Primary Source | Experiment analysis output |

### Formula

```text
Relative Lift =
(Treatment Metric - Control Metric) / Control Metric
```

---

## KPI 63: P-Value

| Field | Definition |
|---|---|
| KPI Name | P-Value |
| Business Meaning | Probability of observing the result if there is no true difference between control and treatment |
| Recommended Threshold | Less than 0.05 |
| Primary Source | Python A/B test notebook |
| Important Note | Statistical significance does not automatically mean business significance |

---

## KPI 64: Confidence Interval

| Field | Definition |
|---|---|
| KPI Name | Confidence Interval |
| Business Meaning | Estimated range containing the true treatment effect |
| Recommended Level | 95% |
| Primary Source | Python A/B test notebook |

---

## KPI 65: Experiment Decision

| Field | Definition |
|---|---|
| KPI Name | Experiment Decision |
| Possible Values | Launch, Gradual Rollout, Continue Testing, Do Not Launch |
| Decision Inputs | Primary metric, secondary metrics, guardrails, confidence interval, practical significance |
| Primary Source | `docs/ab_test_report.md` |

---

# 16. Experiment Guardrail KPIs

| KPI | Definition | Desired Direction |
|---|---|---|
| Immediate Exit Rate | Sessions ending without meaningful interaction | Lower |
| Very Short View Rate | Video starts with watch duration below 10 seconds | Lower |
| Negative Feedback Rate | Percentage of exposed users generating negative feedback, if available | Lower |
| Repeated Recommendation Rate | Percentage of recommendation impressions showing repeated content | Lower |
| Day 7 Retention | Percentage of experiment users returning after seven days | Higher or stable |

---

# 17. Recommended Power BI KPI Cards

## Executive Overview

- Monthly Active Users
- Total Sessions
- Total Watch Hours
- Average Session Duration
- DAU/MAU Stickiness
- Video Completion Rate

## Engagement and Content

- Total Video Starts
- Impression CTR
- Average Watch Percentage
- Engagement Rate
- Videos Watched per Session

## Funnel Analysis

- Funnel Entrants
- Click-to-Start Rate
- 50% Watch Rate
- Overall Funnel Conversion Rate
- Largest Funnel Drop-Off Rate

## Retention and Segments

- Day 1 Retention
- Day 7 Retention
- Day 30 Retention
- Returning User Rate
- At-Risk Users

## Experiment Analysis

- Experiment Sample Size
- Average Watch Time per Session
- Primary Metric Uplift
- CTR Uplift
- P-Value
- Experiment Decision

---

# 18. Recommended Reporting Views

| Reporting View | Main KPIs |
|---|---|
| `reporting.vw_daily_product_kpis` | DAU, sessions, views, watch time, engagement |
| `reporting.vw_content_performance` | Impressions, CTR, starts, completion, watch percentage |
| `reporting.vw_funnel_performance` | Funnel users, step conversion, drop-off |
| `reporting.vw_retention_cohorts` | D1, D7, D14, D30, monthly cohort retention |
| `reporting.vw_user_segments` | Segment counts, watch time, churn, at-risk users |
| `reporting.vw_experiment_results` | Control and treatment metrics, lift, p-values |

---

# 19. KPI Naming Standards

Use the following naming conventions across SQL and Power BI.

| Type | Naming Rule | Example |
|---|---|---|
| SQL column | Lowercase snake_case | `average_watch_minutes_per_session` |
| SQL view | Lowercase snake_case | `vw_daily_product_kpis` |
| Power BI measure | Title Case | `Average Watch Time per Session` |
| Percentage measure | End with `%` when appropriate | `Impression CTR %` |
| Count measure | Start with Total or Distinct | `Total Sessions` |
| Average measure | Start with Average | `Average Session Duration` |

---

# 20. Metric Validation Checklist

Before publishing the dashboard, confirm that:

- [ ] Every KPI has one agreed definition
- [ ] Numerators and denominators use the same date filter
- [ ] Distinct users are used where required
- [ ] Duplicate events do not inflate counts
- [ ] Watch duration is not double counted
- [ ] Completion events are deduplicated
- [ ] Funnel stages follow the correct event order
- [ ] Retention uses one consistent first-activity date
- [ ] Experiment users belong to only one variant
- [ ] Control and treatment use the same eligibility rules
- [ ] Rate KPIs use safe division
- [ ] Power BI values match SQL validation queries

---

# 21. Final KPI Summary

This project primarily evaluates five product areas:

| Product Area | Main KPIs |
|---|---|
| Product Usage | DAU, WAU, MAU, Stickiness, Sessions |
| Viewer Engagement | Watch Time, Completion Rate, Engagement Rate |
| Content Discovery | Impressions, CTR, Search Success Rate |
| Retention | D1, D7, D14, D30, Cohort Retention |
| Experimentation | Uplift, P-Value, Confidence Interval, Guardrails |

---

## Document Owner

**Product Data Analyst — YouTube Viewer Experience Team**

## Project

**End-to-End Google Product Analytics Platform**

## Document Status

**Portfolio Project KPI Dictionary — Version 1.0**
