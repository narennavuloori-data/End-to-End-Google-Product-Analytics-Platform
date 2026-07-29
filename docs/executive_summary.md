# Executive Summary

## End-to-End Google Product Analytics Platform

**Product focus:** YouTube Viewer Experience  
**Assumed role:** Product Data Analyst — YouTube Viewer Experience Team  
**Project type:** Educational portfolio project using realistic synthetic data  
**Analysis period:** July 27, 2025 to July 25, 2026  

---

## 1. Project Context

This project builds an end-to-end product analytics platform for the YouTube viewer experience.

The main business objective is to understand how viewers:

- Discover videos
- Start and continue watching
- Interact with videos and channels
- Return to the platform over time
- Respond to a new personalised homepage recommendation algorithm

The platform combines Python, Azure SQL, SQL analytics, A/B testing and Power BI to study the complete viewer journey.

The analysis covers:

- Product KPIs
- Viewer engagement
- Content performance
- Video-viewing funnel conversion
- Retention and cohorts
- User segmentation
- Recommendation A/B testing

After cleaning, the analytical dataset contains:

| Dataset | Cleaned rows |
|---|---:|
| Users | 25,000 |
| Channels | 2,000 |
| Videos | 10,000 |
| Sessions | 216,464 |
| Events | 1,609,012 |
| Experiment assignments | 12,500 |

The dataset is entirely synthetic and contains no real Google or YouTube user information.

---

## 2. Key Findings

### 2.1 Overall product activity was strong, but not every registered user became active

The platform recorded:

- **20,459 active users**
- **216,464 sessions**
- **134,908 video starts**
- **12,974.08 total watch hours**
- **6.01 minutes average session duration**
- **39.57% impression click-through rate**
- **50.59% video completion rate**

Approximately **81.84% of the 25,000 registered users** generated at least one session during the analysis period.

This indicates healthy overall usage, while also showing an opportunity to activate users who registered but did not become active viewers.

---

### 2.2 Recommendation surfaces drove watch time, while search showed stronger click intent

Homepage Recommendation was the largest traffic source:

- **64,718 sessions**
- **29.90% of all sessions**
- **4,638.93 watch hours**
- **35.76% of total watch hours**
- **6.77 minutes average session duration**

Suggested Video produced fewer sessions but generated the strongest viewing depth among the major recommendation sources:

- **7.17 minutes average session duration**
- **0.82 videos watched per session**

Search Results generated a **43.28% impression CTR**, compared with **33.42% for Homepage recommendations**.

However, YouTube Search sessions averaged only **5.05 minutes**, compared with:

- **6.77 minutes** for Homepage Recommendation
- **7.17 minutes** for Suggested Video

This suggests that search users usually arrive with a clear content need and are more likely to click, while recommendation-driven sessions encourage broader and longer content exploration.

---

### 2.3 Mobile generated the most scale, while television produced the deepest sessions

Mobile accounted for:

- **138,287 sessions**
- **63.88% of all sessions**
- **7,023.18 watch hours**
- **54.13% of total watch hours**

Television generated fewer sessions but had the longest average session duration:

- **TV:** 8.94 minutes
- **Game Console:** 7.95 minutes
- **Desktop:** 6.51 minutes
- **Tablet:** 6.14 minutes
- **Mobile:** 5.40 minutes

This shows two different product needs:

- Mobile should be optimised for high-volume, fast and reliable discovery.
- Television should be optimised for longer viewing sessions and continuous playback.

---

### 2.4 Shorts generated many completions but contributed little total watch time

Shorts produced:

- **34.79% of video starts**
- **58.35% of video completions**
- Only **3.34% of total watch hours**

Standard Videos generated:

- **55.08% of video starts**
- **55.54% of total watch hours**

The high completion share for Shorts is partly explained by their shorter duration. Shorts are effective for quick consumption and completion, while Standard Videos remain the main source of total watch time.

---

### 2.5 The largest funnel loss occurred after video completion

The overall funnel results were:

| Funnel stage | Users reaching stage |
|---|---:|
| Video Impression | 19,159 |
| Video Click | 17,704 |
| Video Start | 17,542 |
| Watched 50% | 16,548 |
| Video Complete | 14,940 |
| Like, Share or Subscribe | 9,733 |

The largest drop occurred between **Video Complete** and **Like, Share or Subscribe**:

- **5,207 users lost**
- **34.85% drop-off**

The Click-to-Start conversion was **99.08%**, showing that playback start was not the main funnel problem in this dataset.

The main opportunity is to encourage meaningful post-view engagement without interrupting the viewing experience.

---

### 2.6 Retention and segmentation show a large re-engagement opportunity

Among users who became active:

- **84.29% returned on at least one later date**
- Exact **Day 7 retention was 3.73%**
- Exact **Day 30 retention was 3.05%**

Users primarily driven by Homepage Recommendation had the strongest traffic-source retention:

- **4.53% Day 7 retention**
- **3.83% Day 30 retention**
- **90.84% returning-user rate**

Under the project’s rule-based inactivity definitions:

- **11,194 users were classified as Churned Viewers**
- **3,468 users were classified as At-Risk Viewers**

Together, these groups represent **58.65% of all users**, making re-engagement one of the largest product opportunities.

---

### 2.7 The experiment treatment should not be launched in its current form

The experiment included **11,855 eligible users**:

- **5,939 Control users**
- **5,916 Treatment users**

The primary metric did not improve:

| Metric | Control | Treatment | Result |
|---|---:|---:|---|
| Average Watch Time per Session | 1.0576 minutes | 1.0409 minutes | **1.58% decrease** |
| P-value | — | — | **0.8959** |

The watch-time difference was not statistically significant.

The treatment also reduced Videos Watched per Session by **13.83%**, and this decrease was statistically significant with a **0.0040 p-value**.

One positive result was Video Completion Rate:

- **Control:** 48.87%
- **Treatment:** 54.55%
- **Improvement:** 5.69 percentage points
- **P-value:** 0.0020

The treatment appears to help viewers complete a smaller number of selected videos, but it does not improve the primary watch-time objective and reduces the number of videos watched per session.

**Experiment decision:** Do not launch the treatment in its current form. Redesign the ranking logic and run another controlled test.

---

## 3. Product Recommendations

### 3.1 Strengthen recommendation quality while preserving discovery diversity

Homepage and Suggested Video generated the strongest watch-time contribution.

Recommended actions:

- Continue investing in personalised recommendation relevance.
- Avoid repeatedly recommending the same videos or categories.
- Balance familiar content with new discovery opportunities.
- Track long-term retention alongside short-term watch time.

---

### 3.2 Improve the search-to-session journey

Search users had strong click intent but shorter sessions.

Recommended actions:

- Improve related-video recommendations after a search-result video starts.
- Offer clear next-video suggestions connected to the original search topic.
- Improve search filters and result relevance.
- Analyse searches that produce a click but no continued viewing.

The goal should be to preserve search relevance while encouraging useful follow-on discovery.

---

### 3.3 Design device-specific viewer experiences

Recommended mobile actions:

- Improve page-load and playback reliability.
- Keep recommendations easy to scan.
- Reduce unnecessary steps between discovery and playback.
- Support quick continuation across sessions.

Recommended television actions:

- Improve Watch Next and autoplay relevance.
- Support longer viewing sessions.
- Make navigation simple with remote controls.
- Promote playlists and related long-form content.

---

### 3.4 Use Shorts for discovery and long-form videos for depth

Recommended actions:

- Use Shorts to introduce viewers to channels and topics.
- Create stronger transitions from Shorts to related Standard Videos.
- Avoid judging Shorts only by completion rate.
- Evaluate whether Shorts create later long-form viewing and retention.
- Promote long-form categories with strong watch time and completion.

This connects quick content discovery with deeper viewing value.

---

### 3.5 Improve post-view engagement opportunities

The largest funnel drop occurred after video completion.

Recommended actions:

- Show relevant channel-subscription prompts after meaningful viewing.
- Improve end-screen recommendations and calls to action.
- Place Like and Share prompts at natural moments.
- Avoid aggressive prompts that interrupt the video.
- Personalise prompts based on viewer history and engagement behaviour.

The objective is not to force engagement, but to make the next useful action easier.

---

### 3.6 Create targeted re-engagement strategies

Recommended actions for At-Risk viewers:

- Send personalised notifications based on previously watched categories.
- Recommend unfinished or recently relevant content.
- Use lower notification frequency for users who rarely respond.
- Test different re-engagement messages through controlled experiments.

Recommended actions for Churned viewers:

- Use broader content rediscovery campaigns.
- Highlight new videos from previously watched channels.
- Test whether Shorts, search suggestions or channel updates encourage return.
- Measure reactivation separately from normal retention.

---

### 3.7 Redesign and retest the recommendation treatment

The current treatment should not be launched.

Recommended next steps:

1. Investigate why completion improved while videos watched per session declined.
2. Check whether the treatment recommends fewer but more narrowly focused videos.
3. Review recommendation diversity across users and sessions.
4. Add real negative-feedback events such as `dislike`, `not_interested` and `dont_recommend_channel` to future experiment data.
5. Define the minimum practical uplift before starting the next test.
6. Run a new A/B test using the same observation window for both variants.
7. Launch gradually only when the primary metric improves without meaningful guardrail harm.

---

## 4. Business Impact

### Viewer Engagement

Improving recommendation relevance, search follow-on discovery and post-view prompts may increase:

- Videos watched per session
- Likes, shares and subscriptions
- Meaningful interaction with channels
- Continued viewing after the first video

---

### Watch Time

Separating short-form discovery from long-form viewing can help the product:

- Use Shorts to attract interest
- Move interested viewers toward longer content
- Improve Suggested Video performance
- Increase useful watch time rather than only increasing clicks

---

### Content Discovery

The recommendations can improve discovery by:

- Matching users with more relevant videos
- Creating better transitions after search
- Reducing repetitive recommendations
- Supporting discovery across categories and channels
- Adapting recommendations to device behaviour

---

### Retention

Targeted onboarding and re-engagement may:

- Increase Day 7 and Day 30 retention
- Reduce the At-Risk population
- Reactivate selected Churned viewers
- Improve retention from lower-performing traffic sources
- Strengthen long-term user value

---

### Recommendation Effectiveness

A disciplined experiment process can prevent weak product changes from being launched.

The current experiment demonstrates why YouTube should evaluate:

- Primary metrics
- Secondary metrics
- Statistical significance
- Practical significance
- Guardrail metrics
- Long-term retention
- Recommendation diversity

A treatment should not be launched only because one secondary metric improves.

---

### Product Decision-Making

The completed platform gives product teams a repeatable way to:

- Monitor product health
- Identify funnel problems
- Compare user and content segments
- Measure retention
- Evaluate experiments
- Convert analytical findings into product actions
- Communicate results through Power BI dashboards

This supports evidence-based decisions instead of relying only on assumptions or isolated metrics.

---

## 5. Final Executive Recommendation

The analysis shows that recommendation surfaces are the main drivers of watch time, mobile provides the greatest usage scale, television produces the deepest sessions, and Shorts support high-volume completion but not total watch-time depth.

The immediate product priorities should be:

1. Improve recommendation diversity and relevance.
2. Extend viewing journeys after search.
3. Connect Shorts discovery with long-form content.
4. Improve post-completion engagement opportunities.
5. Re-engage At-Risk and Churned viewers using personalised strategies.
6. Reject the current experiment treatment and test a redesigned version.

These actions should be evaluated through continued KPI monitoring and controlled experiments before broad product rollout.

---

## Disclaimer

This is an independent educational portfolio project using entirely synthetic data. It does not contain real Google or YouTube users, internal company data, proprietary recommendation information or real experiment results.

Google, YouTube and their associated trademarks belong to their respective owners. This project is not affiliated with, endorsed by or sponsored by Google or YouTube.
