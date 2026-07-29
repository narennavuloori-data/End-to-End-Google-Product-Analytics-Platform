# Business Requirements Document

## End-to-End Google Product Analytics Platform

**Product focus:** YouTube Viewer Experience  
**Assumed role:** Product Data Analyst — YouTube Viewer Experience Team  
**Document version:** 1.0  
**Project type:** Educational portfolio project  
**Data type:** Realistic synthetic data  

---

## 1. Project Background

YouTube is a video-sharing and streaming product where viewers discover, watch and interact with content across mobile phones, desktop computers, tablets and smart televisions.

A viewer's journey may begin when they:

- Open the YouTube application or website
- View videos recommended on the homepage
- Search for a topic
- Open a notification
- Visit a subscribed channel
- Click a suggested video
- Arrive through an external website or social-media link

After discovering a video, the viewer may:

- Click the video
- Start watching
- Watch part or all of the video
- Like, comment on or share the video
- Subscribe to the channel
- Save the video to Watch Later
- Continue to another recommended video
- Leave the platform
- Return on a later day

Understanding this complete journey is important because a high number of impressions or video clicks does not automatically mean that viewers are having a valuable experience. A viewer may click a video and leave immediately, watch only a small portion, fail to find relevant content or stop returning to the platform.

This project will build a simple end-to-end product analytics platform to study viewer behaviour across four major stages:

1. **Discovery** — How viewers find videos
2. **Viewing** — How viewers watch and complete videos
3. **Engagement** — How viewers interact with videos and channels
4. **Retention** — Whether viewers return and remain active over time

The project will also evaluate a hypothetical A/B experiment in which a new homepage recommendation-ranking algorithm is compared with the existing recommendation experience.

The analysis will be completed using a realistic synthetic dataset generated specifically for this educational project. The data will imitate believable YouTube-style viewer behaviour but will not contain any real Google or YouTube data.

---

## 2. Business Problem

The YouTube Viewer Experience team wants to understand how viewers move from discovering a video to watching, engaging and returning to the platform.

The main business problem is:

> How can YouTube improve content discovery, viewer engagement and long-term retention while maintaining a useful and healthy viewer experience?

The team needs a clear analytics system that combines product activity, viewing behaviour, funnel conversion, retention, user segments and experiment results in one place.

---

## 3. Project Goal

The goal of this project is to build an end-to-end product analytics platform that can:

- Measure overall product usage and viewer activity
- Understand how viewers discover content
- Analyse viewing behaviour and engagement
- Identify important funnel drop-offs
- Measure user retention over time
- Compare the performance of different user groups
- Create meaningful viewer segments
- Evaluate a hypothetical recommendation experiment
- Present findings through an interactive Power BI report
- Convert analytical findings into practical product recommendations

---

## 4. Business Objectives

The project must answer the following five main business questions.

### Objective 1: Measure Viewer Activity and Engagement

**Business question:**

> How actively are users engaging with YouTube?

The analysis should measure:

- Daily Active Users
- Weekly Active Users
- Monthly Active Users
- Total sessions
- Average session duration
- Videos watched per session
- Total watch time
- Average watch time per user
- Video completion rate
- Likes, comments, shares and channel subscriptions
- New users versus returning users

**Expected outcome:**

Create a clear view of overall product health and determine whether viewers are actively using and engaging with the platform.

---

### Objective 2: Evaluate Content-Discovery Sources

**Business question:**

> Which traffic sources and recommendation sources produce valuable viewing sessions?

The analysis should compare sources such as:

- Homepage Recommendation
- YouTube Search
- Suggested Video
- Subscriptions Feed
- Notifications
- Channel Page
- External Link

The sources should be compared using:

- Sessions generated
- Video impressions
- Video clicks
- Impression click-through rate
- Watch time
- Videos watched per session
- Video completion rate
- Engagement rate
- Returning-user rate

**Expected outcome:**

Identify which discovery sources generate meaningful viewing behaviour instead of only producing clicks.

---

### Objective 3: Identify Funnel Drop-Offs

**Business question:**

> Where do users drop out of the video-viewing funnel?

The main product funnel will be:

```text
Video Impression
        ↓
Video Click
        ↓
Video Start
        ↓
Watched 50%
        ↓
Video Complete
        ↓
Like, Share or Subscribe
```

For every funnel stage, the analysis should calculate:

- Number of users
- Number of sessions
- Conversion rate from the previous stage
- Overall conversion rate
- Drop-off count
- Drop-off percentage

The funnel should also be compared by:

- Device
- Country
- Traffic source
- Video category
- Subscription type
- New versus returning viewers

**Expected outcome:**

Find the biggest funnel drop-off and recommend a realistic product improvement.

---

### Objective 4: Measure Retention and Cohort Performance

**Business question:**

> Which users and cohorts have the strongest retention?

The analysis should calculate:

- Day 1 retention
- Day 7 retention
- Day 14 retention
- Day 30 retention
- Weekly retention
- Monthly retention
- Returning-user rate
- At-risk users
- Churned users

Users should be grouped into cohorts based on the month of their first activity.

Retention should be compared by:

- Acquisition channel
- Subscription type
- Preferred device
- Country
- Primary traffic source
- Preferred content category
- User segment

**Expected outcome:**

Identify the types of viewers who are most likely to return and the groups that may need a better onboarding or re-engagement experience.

---

### Objective 5: Evaluate the Recommendation Experiment

**Business question:**

> Did the new recommendation algorithm improve viewer engagement?

The hypothetical experiment will compare:

- **Control group:** Existing recommendation-ranking algorithm
- **Treatment group:** New personalised recommendation-ranking algorithm

The primary experiment metric will be:

- Average watch time per session

Secondary metrics will include:

- Impression click-through rate
- Videos watched per session
- Video completion rate
- Engagement rate
- Seven-day retention

Guardrail metrics will include:

- Immediate exit rate
- Very short view rate
- Negative-feedback rate
- Repeated-recommendation rate

The experiment analysis should calculate:

- Control-group result
- Treatment-group result
- Absolute difference
- Percentage uplift
- Confidence interval
- P-value
- Statistical significance
- Practical business significance

**Expected outcome:**

Provide a clear recommendation to launch, continue testing or reject the new recommendation experience.

---

## 5. Main Analysis Areas

### 5.1 Product KPI Analysis

Measure the overall health and usage of the product.

Main metrics include:

- Daily Active Users
- Weekly Active Users
- Monthly Active Users
- DAU/MAU Stickiness
- Total sessions
- Average session duration
- Total views
- Total watch hours
- Videos watched per session
- New and returning viewers

---

### 5.2 Viewer Engagement Analysis

Understand the depth of viewer interaction.

Main metrics include:

- Average watch time
- Average watch percentage
- Video completion rate
- Likes
- Comments
- Shares
- Channel subscriptions
- Engagement rate
- Watch Later actions

---

### 5.3 Content Performance Analysis

Compare the performance of videos, categories and channels.

The analysis should identify:

- Most-watched categories
- Categories with the highest completion rate
- Channels generating the most watch time
- Videos with high impressions but low click-through rate
- Videos with high click-through rate but low watch time
- Performance by video type
- Performance by video duration
- Performance by language
- Performance by content rating

---

### 5.4 Funnel Analysis

Study the viewer journey from impression to meaningful engagement.

The analysis should identify:

- Conversion at every stage
- Overall funnel conversion
- Largest drop-off stage
- Funnel differences by device
- Funnel differences by traffic source
- Funnel differences by content category
- Funnel differences between new and returning viewers

---

### 5.5 Retention Analysis

Measure whether viewers return after their first activity.

The analysis should include:

- Day 1 retention
- Day 7 retention
- Day 14 retention
- Day 30 retention
- Weekly and monthly retention
- Returning-user rate
- Inactive users
- At-risk users
- Churned users

---

### 5.6 Cohort Analysis

Group users according to the month of their first activity and follow their behaviour over time.

The cohort analysis should help answer:

- Which signup or first-activity month produced the strongest users?
- Does retention improve or decline across newer cohorts?
- Which acquisition channels produce better long-term users?
- Which devices or subscription types have stronger retention?

---

### 5.7 User Segmentation

Create simple rule-based viewer segments.

Recommended segments include:

- New Viewers
- Casual Viewers
- Regular Viewers
- Highly Engaged Viewers
- Search-Driven Viewers
- Recommendation-Driven Viewers
- Short-Form Viewers
- Long-Form Viewers
- At-Risk Viewers
- Churned Viewers

The purpose of segmentation is to understand that different viewers may need different product experiences.

---

### 5.8 A/B Testing

Evaluate whether the new recommendation-ranking experience improves important product metrics without damaging the viewer experience.

The analysis should include:

- Experiment-assignment validation
- Sample-size comparison
- Control and treatment comparison
- Primary metric analysis
- Secondary metric analysis
- Guardrail metric analysis
- Statistical significance
- Practical significance
- Final product recommendation

---

## 6. Project Scope

### 6.1 Included in the Project

The project will include:

- Viewer profiles
- YouTube channels
- Videos
- Viewer sessions
- Product events
- Video impressions
- Video clicks
- Video starts
- Viewing-progress events
- Video completions
- Search activity
- Likes
- Comments
- Shares
- Channel subscriptions
- Watch Later actions
- Traffic sources
- Devices
- Countries and regions
- Retention and cohorts
- Rule-based user segments
- A hypothetical recommendation A/B test
- Power BI reporting

### 6.2 Excluded from the Project

The project will not include:

- Real Google or YouTube data
- Personally identifiable information
- Creator revenue
- Advertising auctions
- Copyright claims
- Video-upload processing
- Recommendation-model development
- Machine-learning model training
- Real-time streaming
- YouTube Music
- YouTube TV
- Production deployment

These exclusions keep the project simple, focused and suitable for a product data analyst portfolio.

---

## 7. Intended Stakeholders

The hypothetical stakeholders for this project are:

| Stakeholder | Main interest |
|---|---|
| Product Manager | Product health, funnel performance and feature decisions |
| Product Data Analyst | KPI definitions, behavioural analysis and recommendations |
| Recommendation Team | Recommendation-source and experiment performance |
| Viewer Experience Team | Viewing quality, engagement and drop-offs |
| Content Strategy Team | Category, channel and video performance |
| Leadership Team | Executive KPIs, business impact and launch recommendation |

---

## 8. Data Requirements

The project will use six related synthetic CSV files:

| File | Purpose |
|---|---|
| `users.csv` | One record per viewer |
| `channels.csv` | One record per YouTube channel |
| `videos.csv` | One record per video |
| `sessions.csv` | One record per viewer session |
| `events.csv` | One record per product event |
| `experiment_assignments.csv` | One record per experiment participant |

The dataset should cover approximately 12 months of viewer activity.

The data must support:

- Product KPI calculations
- Session analysis
- Event-sequence analysis
- Funnel analysis
- Retention calculations
- Cohort analysis
- User segmentation
- Content performance
- A/B testing

---

## 9. Core KPI Requirements

| KPI | Simple definition |
|---|---|
| Daily Active Users | Unique users active on a given day |
| Weekly Active Users | Unique users active during a seven-day period |
| Monthly Active Users | Unique users active during a calendar month |
| DAU/MAU Stickiness | Daily Active Users divided by Monthly Active Users |
| Total Sessions | Number of viewer sessions |
| Average Session Duration | Average time between session start and session end |
| Total Watch Hours | Total watch duration converted into hours |
| Videos Watched per Session | Video starts or valid views divided by sessions |
| Impression CTR | Video clicks divided by video impressions |
| Video Completion Rate | Completed videos divided by video starts |
| Engagement Rate | Viewers performing an engagement action divided by eligible viewers |
| Returning-User Rate | Returning active users divided by total active users |
| Day 7 Retention | Users returning seven days after first activity |
| Day 30 Retention | Users returning thirty days after first activity |
| Experiment Uplift | Treatment result compared with control result |

Detailed formulas will be maintained separately in `docs/kpi_dictionary.md` during a later project phase.

---

## 10. Functional Requirements

The completed platform should allow a user to:

1. View overall product-health KPIs.
2. Filter results by date, device, country, subscription type and traffic source.
3. Compare new and returning viewers.
4. Analyse content performance by category, channel and video type.
5. View the complete video-viewing funnel.
6. Identify the largest funnel drop-off.
7. Review retention and cohort performance.
8. Compare user segments.
9. Compare control and treatment experiment results.
10. Read key findings and product recommendations.

---

## 11. Data-Quality Requirements

Before analysis, the project must verify that:

- Primary keys are unique.
- Required identifiers are not missing.
- Session users exist in the users dataset.
- Event sessions exist in the sessions dataset.
- Video channel IDs exist in the channels dataset.
- Video-related events reference valid videos.
- Event timestamps fall within the related session period.
- Watch duration is not negative.
- Watch duration does not exceed the related video duration.
- Event sequences follow a believable order.
- Experiment users belong to only one variant.
- Control and treatment groups are reasonably balanced.

Important data-quality errors must be corrected before creating the final analytical model.

---

## 12. Success Criteria

The project will be considered complete when it contains:

- Six related synthetic datasets
- A documented data dictionary
- Python-based validation and cleaning
- Exploratory data analysis
- Clean staging tables in Azure SQL
- A simple star-schema analytical model
- SQL product KPI analysis
- Funnel analysis
- Retention and cohort analysis
- User segmentation
- A Python A/B test
- Power BI reporting views
- Five clear Power BI dashboard pages
- Key findings
- Product recommendations
- A complete GitHub README
- A visible educational-use disclaimer

The final result should be understandable to a recruiter even without opening the source code.

---

## 13. Expected Deliverables

| Deliverable | Expected location |
|---|---|
| Business requirements | `docs/business_requirements.md` |
| Data dictionary | `data/data_dictionary.md` |
| Raw datasets | `data/raw/` |
| Processed datasets | `data/processed/` |
| Python notebooks | `notebooks/` |
| SQL scripts | `sql/` |
| Power BI report | `power-bi/google_product_analytics_platform.pbix` |
| Experiment report | `docs/ab_test_report.md` |
| Executive summary | `docs/executive_summary.md` |
| Architecture image | `images/architecture.png` |
| Dashboard screenshots | `images/dashboard_screenshots/` |
| Project documentation | `README.md` |

---

## 14. Assumptions and Limitations

### Assumptions

- The synthetic dataset represents plausible viewer behaviour.
- Each viewer is identified using a fictional anonymous user ID.
- Event timestamps are generated in a consistent time standard.
- Product events are sufficiently complete for funnel analysis.
- Experiment assignment occurs before experiment exposure.
- Control and treatment users are mutually exclusive.
- The hypothetical recommendation treatment produces only a small and realistic effect.

### Limitations

- Synthetic data cannot reproduce every real-world behaviour.
- The project does not represent Google's internal data model.
- Metric definitions may differ from Google's official internal definitions.
- The experiment is simulated rather than conducted on real users.
- Business recommendations are based only on the generated dataset.
- No causal claim will be made outside the designed hypothetical experiment.

---

## 15. Disclaimer

This project is an independent educational portfolio project created to demonstrate product analytics, SQL, Python, experimentation and business-intelligence skills.

The dataset used in this project is entirely synthetic and will be programmatically generated to simulate realistic viewer behaviour on a video-streaming platform. It does not contain real Google or YouTube users, personally identifiable information, confidential company information, proprietary analytics or internal Google data.

All product features, metrics, experiments, business scenarios, findings and recommendations presented in this project are hypothetical and are used solely for educational purposes.

Google, YouTube and their associated product names and trademarks belong to their respective owners. This project is not affiliated with, endorsed by, sponsored by or officially connected with Google or YouTube.

---

## 16. Final Business Requirement Summary

This project will create a simple end-to-end analytics platform for the YouTube viewer journey.

The platform will follow this flow:

```text
Synthetic Viewer Data
        ↓
Python Validation and Cleaning
        ↓
Azure SQL Data Model and Analysis
        ↓
Python A/B Testing
        ↓
Power BI Dashboards
        ↓
Product Findings and Recommendations
```

The final platform should clearly explain:

- Who is using the product
- How viewers discover content
- How deeply viewers watch and engage
- Where viewers leave the funnel
- Which viewers return
- Which user groups are most valuable
- Whether the new recommendation experience performs better
- What product actions should be taken
