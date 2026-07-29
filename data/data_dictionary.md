# Data Dictionary

## End-to-End Google Product Analytics Platform

**Product focus:** YouTube Viewer Experience  
**Dataset type:** Realistic synthetic dataset  
**Document version:** 1.0  
**Raw-data period:** July 27, 2025 to July 26, 2026  
**Total raw rows across all files:** 1,878,868  

---

## 1. Purpose of This Document

This data dictionary explains the structure and business meaning of every field in the six synthetic datasets used in the **End-to-End Google Product Analytics Platform** project.

It is designed to help anyone understand:

- What each CSV file represents
- What one row in each file means
- Which columns are primary keys and foreign keys
- What data type each column should use
- Which fields may contain missing values
- Which categorical values are expected
- How the six files connect to one another
- Which raw-data issues must be handled during cleaning

This document describes the **raw generated datasets**. Cleaned and analytical tables may contain additional calculated columns created later in Python or SQL.

---

## 2. Dataset Overview

| Dataset | Raw file | Grain — what one row represents | Raw rows | Primary key |
|---|---|---|---:|---|
| Users | `users.csv` | One viewer account record | 25,025 | `user_id` |
| Channels | `channels.csv` | One YouTube channel | 2,000 | `channel_id` |
| Videos | `videos.csv` | One uploaded video | 10,000 | `video_id` |
| Sessions | `sessions.csv` | One viewer session | 217,113 | `session_id` |
| Events | `events.csv` | One viewer action inside a session | 1,612,230 | `event_id` |
| Experiment Assignments | `experiment_assignments.csv` | One user assignment to one experiment | 12,500 | `experiment_id + user_id` |

### Observed Raw-Data Conditions

The generated data intentionally contains realistic data-quality problems for Phase 3 validation and cleaning.

| Dataset | Observed condition |
|---|---|
| `users.csv` | 25,025 rows but 25,000 unique `user_id` values; 25 duplicate user-key occurrences must be investigated |
| `sessions.csv` | 217,113 rows but 216,464 unique `session_id` values; 649 duplicate session-key occurrences must be investigated |
| `users.csv` | Country and device values contain inconsistent uppercase, lowercase and extra spaces |
| `sessions.csv` | Device and traffic-source values contain inconsistent uppercase, lowercase and extra spaces |
| Several files | Some optional descriptive fields contain missing values |
| `events.csv` | Many context-dependent columns are blank when they do not apply to the event type |

These issues should **not** be manually edited inside the raw CSV files. They will be handled with reproducible Python cleaning code.

---

## 3. Dataset Relationship Map

```text
users.csv
   │
   ├── user_id ────────────────┐
   │                            │
   ▼                            ▼
sessions.csv                experiment_assignments.csv
   │
   ├── session_id ──────────────┐
   │                            │
   └── user_id ─────────────┐   │
                            ▼   ▼
                         events.csv
                            ▲   ▲
                            │   │
channels.csv                │   │
   │                        │   │
   └── channel_id ──► videos.csv
                         │
                         └── video_id ──► events.csv
```

### Main Relationships

| Parent table | Parent key | Child table | Child key | Relationship |
|---|---|---|---|---|
| `users.csv` | `user_id` | `sessions.csv` | `user_id` | One user can have many sessions |
| `users.csv` | `user_id` | `events.csv` | `user_id` | One user can generate many events |
| `users.csv` | `user_id` | `experiment_assignments.csv` | `user_id` | One user may be assigned to an experiment |
| `channels.csv` | `channel_id` | `videos.csv` | `channel_id` | One channel can publish many videos |
| `channels.csv` | `channel_id` | `events.csv` | `channel_id` | One channel can be referenced by many events |
| `videos.csv` | `video_id` | `events.csv` | `video_id` | One video can appear in many events |
| `sessions.csv` | `session_id` | `events.csv` | `session_id` | One session can contain many events |

---

# 4. `users.csv`

## 4.1 Table Purpose

Stores viewer-level profile and account information.

## 4.2 Grain

> One row represents one YouTube viewer account record.

## 4.3 Raw Dataset Summary

| Property | Value |
|---|---|
| Raw rows | 25,025 |
| Unique user IDs | 25,000 |
| Date range | July 27, 2020 to July 25, 2026 |
| Primary key | `user_id` |
| Used by | Sessions, events, retention, cohorts, segmentation and experiments |

## 4.4 Column Dictionary

| Column | Key | Recommended type | Nullable? | Description | Example |
|---|---|---|---|---|---|
| `user_id` | Primary key | `VARCHAR(10)` | No | Anonymous synthetic identifier assigned to each viewer account. | `U000001` |
| `signup_date` | — | `DATE` | No | Date on which the viewer account was created. | `2021-01-21` |
| `country` | — | `VARCHAR(50)` | No | Viewer’s modeled country. Used for geographic analysis. | `Thailand` |
| `region` | — | `VARCHAR(60)` | Yes | State, province or broad regional area within the country when available. | `Central India` |
| `age_group` | — | `VARCHAR(10)` | Yes | Modeled age band rather than exact age. | `25-34` |
| `preferred_language` | — | `VARCHAR(30)` | Yes | Language most commonly preferred by the viewer. | `English` |
| `subscription_type` | — | `VARCHAR(30)` | No | Viewer’s subscription plan. | `Free` |
| `acquisition_channel` | — | `VARCHAR(30)` | No | Channel through which the viewer was originally acquired. | `Google Ads` |
| `preferred_device` | — | `VARCHAR(20)` | No | Device type most frequently used by the viewer. | `Mobile` |
| `account_status` | — | `VARCHAR(15)` | No | Current modeled activity status of the viewer account. | `Active` |

## 4.5 Expected Categorical Values

### `age_group`

```text
13-17
18-24
25-34
35-44
45-54
55-64
65+
```

### `subscription_type`

```text
Free
Premium Trial
YouTube Premium
```

### `acquisition_channel`

```text
Direct
Google Ads
Organic Search
Pre-installed App
Referral
Social Media
```

### Standardized `preferred_device`

```text
Desktop
Game Console
Mobile
TV
Tablet
```

### `account_status`

```text
Active
Inactive
Churned
```

## 4.6 Important Cleaning Rules

- Remove leading and trailing spaces from text fields.
- Standardize inconsistent country capitalization.
- Standardize inconsistent device capitalization.
- Investigate and resolve duplicate `user_id` records.
- Preserve missing `region` values when a meaningful region is unavailable; use a documented replacement such as `Unknown` only in the cleaned dataset.
- Do not invent exact ages from `age_group`.
- Do not treat `account_status` as the same thing as calculated churn; a separate behavioural churn definition may be created later.

---

# 5. `channels.csv`

## 5.1 Table Purpose

Stores descriptive information about YouTube channels that publish the videos in the dataset.

## 5.2 Grain

> One row represents one YouTube channel.

## 5.3 Raw Dataset Summary

| Property | Value |
|---|---|
| Raw rows | 2,000 |
| Unique channel IDs | 2,000 |
| Creation-date range | January 1, 2010 to July 23, 2026 |
| Primary key | `channel_id` |
| Used by | Video and channel performance analysis |

## 5.4 Column Dictionary

| Column | Key | Recommended type | Nullable? | Description | Example |
|---|---|---|---|---|---|
| `channel_id` | Primary key | `VARCHAR(10)` | No | Unique synthetic identifier for a YouTube channel. | `C00001` |
| `channel_name` | — | `VARCHAR(120)` | No | Fictional display name of the channel. | `Pixel League` |
| `channel_category` | — | `VARCHAR(30)` | No | Main content category associated with the channel. | `Sports` |
| `creator_country` | — | `VARCHAR(50)` | No | Modeled country in which the channel creator is based. | `Japan` |
| `primary_language` | — | `VARCHAR(30)` | Yes | Main language used by the channel. | `Japanese` |
| `channel_created_date` | — | `DATE` | No | Date on which the channel was created. | `2010-08-18` |
| `subscriber_band` | — | `VARCHAR(20)` | No | Grouped subscriber-count range; not an exact subscriber count. | `100K-1M` |
| `content_rating` | — | `VARCHAR(20)` | Yes | Broad audience suitability classification for the channel. | `General` |

## 5.5 Expected Categorical Values

### `channel_category`

```text
Comedy
Education
Entertainment
Film
Gaming
Lifestyle
Music
News
Sports
Technology
```

### `subscriber_band`

```text
<10K
10K-100K
100K-1M
1M-10M
10M+
```

### `content_rating`

```text
General
Teen
Mature
```

## 5.6 Important Cleaning Rules

- Confirm that `channel_id` is unique and not null.
- Standardize missing `primary_language` as `Unknown` only in the cleaned output.
- Standardize missing `content_rating` as `Unknown` only if required for analysis.
- Ensure `channel_created_date` is not later than the project’s data-generation date.
- Preserve the subscriber value as a band; do not convert it into a fake exact subscriber count.

---

# 6. `videos.csv`

## 6.1 Table Purpose

Stores descriptive and structural information about videos available for viewing.

## 6.2 Grain

> One row represents one uploaded video.

## 6.3 Raw Dataset Summary

| Property | Value |
|---|---|
| Raw rows | 10,000 |
| Unique video IDs | 10,000 |
| Upload-date range | January 7, 2010 to July 25, 2026 |
| Duration range | 15 to 14,388 seconds |
| Primary key | `video_id` |
| Foreign key | `channel_id` → `channels.channel_id` |

## 6.4 Column Dictionary

| Column | Key | Recommended type | Nullable? | Description | Example |
|---|---|---|---|---|---|
| `video_id` | Primary key | `VARCHAR(10)` | No | Unique synthetic identifier for a video. | `V000001` |
| `channel_id` | Foreign key | `VARCHAR(10)` | No | Identifier of the channel that published the video. | `C00069` |
| `upload_date` | — | `DATE` | No | Date on which the video was uploaded. | `2015-03-27` |
| `video_category` | — | `VARCHAR(30)` | No | Main subject category of the video. | `Technology` |
| `video_type` | — | `VARCHAR(30)` | No | Format of the video. | `Standard Video` |
| `video_language` | — | `VARCHAR(30)` | No | Main language of the video. | `Portuguese` |
| `duration_seconds` | — | `INT` | No | Total video duration measured in seconds. | `421` |
| `content_rating` | — | `VARCHAR(20)` | Yes | Broad audience suitability classification. | `General` |
| `title_length` | — | `SMALLINT` | Yes | Number of characters in the video title. | `37` |
| `thumbnail_style` | — | `VARCHAR(30)` | Yes | Simplified visual style of the video thumbnail. | `Text Overlay` |

## 6.5 Expected Categorical Values

### `video_category`

```text
Comedy
Education
Entertainment
Film
Gaming
Lifestyle
Music
News
Sports
Technology
```

### `video_type`

```text
Standard Video
Short
Live Stream
Premiere
```

### `content_rating`

```text
General
Teen
Mature
```

### `thumbnail_style`

```text
Before-After
Bright Colors
Collage
Face Close-up
Minimalist
Screenshot
Text Overlay
```

## 6.6 Important Cleaning Rules

- Every `channel_id` must exist in `channels.csv`.
- `duration_seconds` must be greater than zero.
- Convert `title_length` to a nullable integer after handling missing values.
- Upload dates must not occur after the related viewing event.
- Missing descriptive fields should not cause the entire video row to be deleted.
- Do not assume all `Short` records have exactly the same duration; validate them using a sensible business range.

---

# 7. `sessions.csv`

## 7.1 Table Purpose

Stores one record for each period in which a viewer actively used YouTube.

## 7.2 Grain

> One row represents one viewer session.

## 7.3 Raw Dataset Summary

| Property | Value |
|---|---|
| Raw rows | 217,113 |
| Unique session IDs | 216,464 |
| Start-date range | July 27, 2025 to July 25, 2026 |
| End-date range | July 27, 2025 to July 26, 2026 |
| Primary key | `session_id` |
| Foreign key | `user_id` → `users.user_id` |

## 7.4 Column Dictionary

| Column | Key | Recommended type | Nullable? | Description | Example |
|---|---|---|---|---|---|
| `session_id` | Primary key | `VARCHAR(12)` | No | Unique synthetic identifier for a viewer session. | `S00000001` |
| `user_id` | Foreign key | `VARCHAR(10)` | No | Viewer who generated the session. | `U000001` |
| `session_start_timestamp` | — | `DATETIME2(3)` | No | Date and time at which the session began. | `2025-08-08 22:25:18` |
| `session_end_timestamp` | — | `DATETIME2(3)` | No | Date and time at which the session ended. | `2025-08-08 22:28:46.435` |
| `device_type` | — | `VARCHAR(20)` | No | Device used during the session. | `Mobile` |
| `operating_system` | — | `VARCHAR(30)` | No | Operating system used by the session device. | `Android` |
| `country` | — | `VARCHAR(50)` | No | Country associated with the session. | `Thailand` |
| `traffic_source` | — | `VARCHAR(40)` | No | Source that brought the viewer into the session. | `Homepage Recommendation` |
| `app_version` | — | `VARCHAR(20)` | Yes | Version of the YouTube application represented in the synthetic data. | `18.20.34` |
| `network_type` | — | `VARCHAR(20)` | Yes | Network connection used during the session. | `WiFi` |

## 7.5 Expected Categorical Values

### Standardized `device_type`

```text
Desktop
Game Console
Mobile
TV
Tablet
```

### `traffic_source`

```text
Channel Page
External Link
Homepage Recommendation
Notifications
Subscriptions Feed
Suggested Video
YouTube Search
```

### `network_type`

```text
3G
4G
5G
Ethernet
WiFi
```

### Observed `operating_system` Examples

```text
Android
Android TV
ChromeOS
iOS
iPadOS
Linux
LG webOS
macOS
PlayStation
Roku OS
Samsung Tizen
tvOS
Windows
Xbox
```

## 7.6 Important Cleaning Rules

- Investigate and resolve duplicate `session_id` records.
- Every `user_id` must exist in the cleaned users table.
- `session_end_timestamp` must be after or equal to `session_start_timestamp`.
- Derive `session_duration_seconds` or `session_duration_minutes` during cleaning.
- Standardize device and traffic-source capitalization and remove extra spaces.
- Confirm that the operating system is compatible with the device type where possible.
- Missing `app_version` may be acceptable for some web, console or television sessions.
- Missing `network_type` should be documented and may be standardized to `Unknown`.
- Session country may differ from the user’s profile country because viewers can travel; this should not automatically be treated as an error.

---

# 8. `events.csv`

## 8.1 Table Purpose

Stores the event-level activity generated by viewers inside sessions. This is the central behavioural dataset used for product KPIs, engagement analysis, funnels and content performance.

## 8.2 Grain

> One row represents one viewer action at one point in time inside one session.

## 8.3 Raw Dataset Summary

| Property | Value |
|---|---|
| Raw rows | 1,612,230 |
| Event-time range | July 27, 2025 to July 26, 2026 |
| Event sequence range | 1 to 54 |
| Primary key | `event_id` |
| Foreign keys | `session_id`, `user_id`, `video_id`, `channel_id` |
| Main use | Product activity, funnels, viewing progress, engagement and watch-time analysis |

## 8.4 Column Dictionary

| Column | Key | Recommended type | Nullable? | Description | Example |
|---|---|---|---|---|---|
| `event_id` | Primary key | `VARCHAR(12)` | No | Unique synthetic identifier for one event. | `E00000001` |
| `session_id` | Foreign key | `VARCHAR(12)` | No | Session in which the event occurred. | `S00000001` |
| `user_id` | Foreign key | `VARCHAR(10)` | No | Viewer who generated the event. | `U000001` |
| `event_timestamp` | — | `DATETIME2(3)` | No | Exact synthetic date and time at which the event occurred. | `2025-08-08 22:25:21.439` |
| `event_name` | — | `VARCHAR(40)` | No | Type of viewer action represented by the row. | `video_impression` |
| `event_sequence_number` | — | `SMALLINT` | No | Ordered position of the event inside its session. | `3` |
| `video_id` | Foreign key | `VARCHAR(10)` | Conditional | Video connected to the event. Blank for events that are not related to a specific video. | `V009958` |
| `channel_id` | Foreign key | `VARCHAR(10)` | Conditional | Channel connected to the video or channel action. Blank when not applicable. | `C00034` |
| `recommendation_source` | — | `VARCHAR(30)` | Conditional | Surface or source through which the video was discovered. | `Homepage` |
| `search_category` | — | `VARCHAR(30)` | Conditional | Simplified topic searched by the viewer. Mainly populated for search events. | `Tech Reviews` |
| `watch_duration_seconds` | — | `DECIMAL(12,3)` | Conditional | Viewing duration associated with supported viewing or progress events. | `13.0` |
| `video_position_seconds` | — | `DECIMAL(12,3)` | Conditional | Playback position reached in the video at the time of the event. | `12.8` |
| `is_autoplay` | — | `BIT` | Conditional | Indicates whether playback began automatically rather than through a direct manual play action. | `False` |

## 8.5 Expected Event Names

```text
app_open
homepage_view
video_impression
video_click
video_start
video_progress_25
video_progress_50
video_progress_75
video_complete
search
like
comment
share
subscribe_channel
save_to_watch_later
session_end
```

## 8.6 Expected Recommendation Sources

```text
Channel Page
External
Homepage
Notification
Search Results
Subscriptions Feed
Watch Next
```

## 8.7 Expected Search Categories

```text
Comedy
Cooking
Education
Fitness
Gaming
Movies
Music
News
Sports
Tech Reviews
Tutorials
Vlogs
```

## 8.8 Meaning of Conditional Nulls

Blank values in `events.csv` are not automatically data errors.

| Column | When a blank may be valid |
|---|---|
| `video_id` | `app_open`, `homepage_view`, `search` or `session_end` events |
| `channel_id` | Events not linked to a specific video or channel |
| `recommendation_source` | Events unrelated to content discovery |
| `search_category` | All non-search events |
| `watch_duration_seconds` | Events that do not represent viewing progress |
| `video_position_seconds` | Events that do not represent video playback |
| `is_autoplay` | Events where autoplay is not relevant |

## 8.9 Typical Event Sequence

A session may contain a sequence such as:

```text
app_open
    ↓
homepage_view
    ↓
video_impression
    ↓
video_click
    ↓
video_start
    ↓
video_progress_25
    ↓
video_progress_50
    ↓
video_progress_75
    ↓
video_complete
    ↓
like / comment / share / subscribe_channel
    ↓
session_end
```

Not every session must contain every event. A viewer may leave at any stage.

## 8.10 Important Cleaning and Validation Rules

- `event_id` must be unique and not null.
- Every `session_id` must exist in the cleaned sessions table.
- Every `user_id` must exist in the cleaned users table.
- The event user should match the user associated with the session.
- Video-related `video_id` values must exist in the cleaned videos table.
- Populated `channel_id` values must exist in the cleaned channels table.
- `event_timestamp` should fall between the session start and session end.
- `event_sequence_number` should begin at 1 and increase within each session.
- Watch duration and playback position must not be negative.
- Watch duration and playback position should not exceed the related video duration, allowing only a documented tolerance if needed.
- Progress events should generally appear in logical order.
- `video_complete` should normally follow `video_start`.
- Context-dependent nulls should be validated using `event_name`, not filled blindly.
- Convert `is_autoplay` to a proper Boolean or SQL `BIT`.

---

# 9. `experiment_assignments.csv`

## 9.1 Table Purpose

Stores user assignment information for the hypothetical homepage recommendation-ranking A/B experiment.

## 9.2 Grain

> One row represents one user assigned to one experiment.

## 9.3 Raw Dataset Summary

| Property | Value |
|---|---|
| Raw rows | 12,500 |
| Experiment | `EXP_2026_HOMEPAGE_RANK_V2` |
| Assignment-date range | April 18, 2026 to July 11, 2026 |
| First-exposure range | April 18, 2026 to July 16, 2026 |
| Composite primary key | `experiment_id + user_id` |
| Foreign key | `user_id` → `users.user_id` |

## 9.4 Column Dictionary

| Column | Key | Recommended type | Nullable? | Description | Example |
|---|---|---|---|---|---|
| `experiment_id` | Composite primary key | `VARCHAR(50)` | No | Identifier of the hypothetical product experiment. | `EXP_2026_HOMEPAGE_RANK_V2` |
| `user_id` | Composite primary key and foreign key | `VARCHAR(10)` | No | Viewer assigned to the experiment. | `U019110` |
| `variant` | — | `VARCHAR(12)` | No | Experiment group assigned to the viewer. | `Control` |
| `assignment_date` | — | `DATE` | No | Date on which the viewer was assigned to the experiment. | `2026-05-17` |
| `first_exposure_date` | — | `DATE` | No | First date on which the viewer was exposed to the assigned experience. | `2026-05-21` |
| `eligible_flag` | — | `BIT` | No | Indicates whether the viewer met the experiment’s eligibility rules. | `True` |

## 9.5 Expected Categorical Values

### `variant`

```text
Control
Treatment
```

### `eligible_flag`

```text
True
False
```

## 9.6 Experiment Meaning

| Variant | Hypothetical experience |
|---|---|
| `Control` | Existing homepage recommendation-ranking algorithm |
| `Treatment` | New personalised homepage recommendation-ranking algorithm |

## 9.7 Important Cleaning and Validation Rules

- Every experiment `user_id` must exist in the cleaned users table.
- A user must not appear in both Control and Treatment for the same experiment.
- `assignment_date` must be on or before `first_exposure_date`.
- Experiment exposure must occur within the available event-data period.
- Ineligible users should not be included in the primary experiment-effect calculation unless explicitly required.
- Control and Treatment group sizes should be reasonably balanced.
- Behaviour used to calculate experiment metrics must occur on or after the first exposure date.
- Experiment results must be calculated at the user level or another pre-defined independent analysis unit.

---

# 10. Shared Geographic and Language Values

## 10.1 Main Countries

The generated data contains the following modeled countries:

```text
Australia
Brazil
Canada
France
Germany
India
Indonesia
Italy
Japan
Mexico
Nigeria
Pakistan
Philippines
South Korea
Spain
Thailand
Turkey
United Kingdom
United States
Vietnam
```

## 10.2 Main Languages

```text
Bengali
English
Filipino
French
German
Hindi
Indonesian
Italian
Japanese
Kannada
Korean
Marathi
Portuguese
Spanish
Tamil
Telugu
Thai
Turkish
Urdu
Vietnamese
```

Text standardization must preserve the correct display names and must not change valid language meanings.

---

# 11. Primary-Key and Foreign-Key Rules

## 11.1 Primary Keys

| Dataset | Primary key rule |
|---|---|
| Users | `user_id` must uniquely identify one cleaned viewer |
| Channels | `channel_id` must uniquely identify one channel |
| Videos | `video_id` must uniquely identify one video |
| Sessions | `session_id` must uniquely identify one cleaned session |
| Events | `event_id` must uniquely identify one event |
| Experiment assignments | `experiment_id + user_id` must uniquely identify one assignment |

## 11.2 Foreign Keys

| Child column | Must exist in |
|---|---|
| `sessions.user_id` | `users.user_id` |
| `events.user_id` | `users.user_id` |
| `events.session_id` | `sessions.session_id` |
| `videos.channel_id` | `channels.channel_id` |
| `events.video_id` when populated | `videos.video_id` |
| `events.channel_id` when populated | `channels.channel_id` |
| `experiment_assignments.user_id` | `users.user_id` |

---

# 12. Date and Timestamp Rules

| Rule | Explanation |
|---|---|
| Signup before activity | A user’s `signup_date` should not be after their session or event activity |
| Channel before upload | `channel_created_date` should not be after a video’s `upload_date` |
| Upload before viewing | A video’s `upload_date` should not be after a related event |
| Session order | Session end must not be before session start |
| Event inside session | Event time should be between session start and end |
| Assignment before exposure | Experiment assignment must not occur after first exposure |
| Exposure before measurement | Experiment behaviour should be measured only after exposure |

The project will preserve timestamp precision to milliseconds using `DATETIME2(3)` in Azure SQL.

---

# 13. Planned Calculated Fields

The following columns do not exist in the raw files. They may be created later during Python cleaning, SQL modelling or analysis.

## 13.1 Session Features

```text
session_duration_seconds
session_duration_minutes
session_date
session_hour
session_day_name
is_weekend
```

## 13.2 Event Features

```text
event_date
event_hour
is_viewing_event
is_engagement_event
is_completion_event
is_search_event
```

## 13.3 Video Features

```text
duration_minutes
video_duration_group
video_age_days
```

## 13.4 User Features

```text
first_activity_date
last_activity_date
days_since_last_activity
total_sessions
total_watch_hours
primary_traffic_source
preferred_content_category
user_segment
cohort_month
```

## 13.5 Experiment Metrics

```text
watch_time_per_session
impression_ctr
videos_per_session
video_completion_rate
engagement_rate
seven_day_retention
immediate_exit_rate
very_short_view_rate
```

Calculated fields must always be documented with their formulas before being used in final dashboards.

---

# 14. File Naming and Storage Rules

The six raw files should be stored as:

```text
data/raw/users.csv
data/raw/channels.csv
data/raw/videos.csv
data/raw/sessions.csv
data/raw/events.csv
data/raw/experiment_assignments.csv
```

The data dictionary should be stored as:

```text
data/data_dictionary.md
```

Do not keep names such as:

```text
users(3).csv
events(3).csv
sessions(3).csv
```

Rename the downloaded files to their clean standard names before continuing.

Raw files should remain unchanged after they are placed in `data/raw/`. All cleaned files will later be written to:

```text
data/processed/
```

---

# 15. Data-Privacy Classification

| Data category | Present? | Notes |
|---|---|---|
| Real customer data | No | All records are synthetic |
| Personally identifiable information | No | IDs and names are fictional |
| Exact user names | No | No real viewer names are included |
| Email addresses | No | Not included |
| Phone numbers | No | Not included |
| Exact addresses | No | Not included |
| Payment information | No | Not included |
| Sensitive real-world profiles | No | User attributes are synthetic and grouped |
| Product behavioural data | Synthetic only | Events simulate realistic product usage |

---

# 16. Dataset Disclaimer

This dataset is entirely synthetic and was created for an independent educational portfolio project.

It does not contain:

- Real Google or YouTube user information
- Internal Google datasets
- Confidential business information
- Personally identifiable information
- Proprietary recommendation-system data
- Real experiment results

Google, YouTube and their associated trademarks belong to their respective owners. This project is not affiliated with, endorsed by, sponsored by or officially connected with Google or YouTube.

All viewer behaviour, product metrics, experiments, findings and recommendations are hypothetical and are used only to demonstrate data analytics skills.

---

# 17. Final Dataset Summary

The six datasets together represent the following product journey:

```text
User account
    ↓
Viewer session
    ↓
Content discovery
    ↓
Video impression
    ↓
Video click
    ↓
Video start and progress
    ↓
Video completion
    ↓
Like, comment, share or subscribe
    ↓
Future return and retention
    ↓
Control-versus-treatment experiment analysis
```

This structure supports:

- Product KPI analysis
- Viewer engagement analysis
- Content performance analysis
- Funnel analysis
- Retention analysis
- Cohort analysis
- User segmentation
- A/B testing
- Power BI reporting
