-- daily product KPIs
create or alter view reporting.vw_daily_product_kpis as

with session_data as (
    select
        d.full_date,
        count(distinct s.user_key) as daily_active_users,
        count(*) as total_sessions,
        avg(s.session_duration_minutes) as average_session_minutes
    from analytics.fact_sessions s
    join analytics.dim_date d
        on s.date_key = d.date_key
    group by d.full_date
),

event_data as (
    select
        d.full_date,
        sum(case when e.event_name = 'video_impression' then 1 else 0 end) as impressions,
        sum(case when e.event_name = 'video_click' then 1 else 0 end) as clicks,
        sum(case when e.event_name = 'video_start' then 1 else 0 end) as video_views,
        sum(case when e.event_name = 'video_complete' then 1 else 0 end) as completions,
        sum(case
            when e.event_name in ('like', 'comment', 'share', 'subscribe_channel')
            then 1 else 0
        end) as engagement_actions,
        count(distinct case
            when e.event_name in ('like', 'comment', 'share', 'subscribe_channel')
            then e.user_key
        end) as engaged_users,
        count(distinct case
            when e.event_name = 'video_start'
            then e.user_key
        end) as viewing_users
    from analytics.fact_events e
    join analytics.dim_date d
        on e.date_key = d.date_key
    group by d.full_date
),

video_watch as (
    select
        d.full_date,
        e.session_id,
        e.video_key,
        max(isnull(e.watch_duration_seconds, 0)) as watch_seconds
    from analytics.fact_events e
    join analytics.dim_date d
        on e.date_key = d.date_key
    where e.video_key is not null
    group by
        d.full_date,
        e.session_id,
        e.video_key
),

watch_data as (
    select
        full_date,
        sum(watch_seconds) / 3600.0 as total_watch_hours
    from video_watch
    group by full_date
)

select
    s.full_date,
    s.daily_active_users,
    s.total_sessions,
    round(s.average_session_minutes, 2) as average_session_minutes,
    isnull(e.video_views, 0) as video_views,
    round(isnull(w.total_watch_hours, 0), 2) as total_watch_hours,
    round(e.clicks * 100.0 / nullif(e.impressions, 0), 2) as impression_ctr,
    round(e.completions * 100.0 / nullif(e.video_views, 0), 2) as completion_rate,
    round(e.engaged_users * 100.0 / nullif(e.viewing_users, 0), 2) as engagement_rate
from session_data s
left join event_data e
    on s.full_date = e.full_date
left join watch_data w
    on s.full_date = w.full_date;

go


-- content performance by video category
create or alter view reporting.vw_content_performance as

with event_data as (
    select
        v.video_category,
        count(distinct v.video_id) as total_videos,
        sum(case when e.event_name = 'video_impression' then 1 else 0 end) as impressions,
        sum(case when e.event_name = 'video_click' then 1 else 0 end) as clicks,
        sum(case when e.event_name = 'video_start' then 1 else 0 end) as video_views,
        sum(case when e.event_name = 'video_complete' then 1 else 0 end) as completions,
        sum(case
            when e.event_name in ('like', 'comment', 'share', 'subscribe_channel')
            then 1 else 0
        end) as engagement_actions
    from analytics.dim_video v
    left join analytics.fact_events e
        on v.video_key = e.video_key
    group by v.video_category
),

video_watch as (
    select
        v.video_category,
        e.session_id,
        e.video_key,
        max(isnull(e.watch_duration_seconds, 0)) as watch_seconds
    from analytics.fact_events e
    join analytics.dim_video v
        on e.video_key = v.video_key
    group by
        v.video_category,
        e.session_id,
        e.video_key
),

watch_data as (
    select
        video_category,
        sum(watch_seconds) / 3600.0 as total_watch_hours
    from video_watch
    group by video_category
)

select
    e.video_category,
    e.total_videos,
    e.impressions,
    e.clicks,
    e.video_views,
    e.completions,
    e.engagement_actions,
    round(isnull(w.total_watch_hours, 0), 2) as total_watch_hours,
    round(e.clicks * 100.0 / nullif(e.impressions, 0), 2) as impression_ctr,
    round(e.completions * 100.0 / nullif(e.video_views, 0), 2) as completion_rate
from event_data e
left join watch_data w
    on e.video_category = w.video_category;

go


-- overall funnel performance
create or alter view reporting.vw_funnel_performance as

with event_flags as (
    select
        session_id,
        user_key,
        video_key,
        max(case when event_name = 'video_impression' then 1 else 0 end) as impression,
        max(case when event_name = 'video_click' then 1 else 0 end) as clicked,
        max(case when event_name = 'video_start' then 1 else 0 end) as started,
        max(case when event_name = 'video_progress_50' then 1 else 0 end) as watched_50,
        max(case when event_name = 'video_complete' then 1 else 0 end) as completed,
        max(case
            when event_name in ('like', 'share', 'subscribe_channel')
            then 1 else 0
        end) as engaged
    from analytics.fact_events
    where video_key is not null
    group by
        session_id,
        user_key,
        video_key
),

stage_counts as (
    select
        1 as stage_number,
        'Video Impression' as stage_name,
        count(distinct case when impression = 1 then user_key end) as users_entering_stage
    from event_flags

    union all

    select
        2,
        'Video Click',
        count(distinct case
            when impression = 1 and clicked = 1 then user_key
        end)
    from event_flags

    union all

    select
        3,
        'Video Start',
        count(distinct case
            when impression = 1 and clicked = 1 and started = 1 then user_key
        end)
    from event_flags

    union all

    select
        4,
        'Watched 50%',
        count(distinct case
            when impression = 1 and clicked = 1
             and started = 1 and watched_50 = 1
            then user_key
        end)
    from event_flags

    union all

    select
        5,
        'Video Complete',
        count(distinct case
            when impression = 1 and clicked = 1 and started = 1
             and watched_50 = 1 and completed = 1
            then user_key
        end)
    from event_flags

    union all

    select
        6,
        'Like, Share or Subscribe',
        count(distinct case
            when impression = 1 and clicked = 1 and started = 1
             and watched_50 = 1 and completed = 1 and engaged = 1
            then user_key
        end)
    from event_flags
),

funnel as (
    select
        stage_number,
        stage_name,
        users_entering_stage,
        lag(users_entering_stage) over (
            order by stage_number
        ) as previous_stage_users,
        first_value(users_entering_stage) over (
            order by stage_number
        ) as first_stage_users
    from stage_counts
)

select
    stage_number,
    stage_name,
    users_entering_stage,
    round(
        users_entering_stage * 100.0
        / nullif(previous_stage_users, 0),
        2
    ) as conversion_from_previous_stage,
    round(
        users_entering_stage * 100.0
        / nullif(first_stage_users, 0),
        2
    ) as overall_funnel_conversion,
    isnull(previous_stage_users - users_entering_stage, 0) as drop_off_count,
    isnull(
        round(
            (previous_stage_users - users_entering_stage) * 100.0
            / nullif(previous_stage_users, 0),
            2
        ),
        0
    ) as drop_off_percentage
from funnel;

go


-- monthly cohort retention
create or alter view reporting.vw_retention_cohorts as

select
    cohort_month,
    month_number,
    cohort_users,
    retained_users,
    retention_percentage
from reporting.vw_monthly_retention;

go


-- reporting.vw_user_segments already exists from 08_user_segmentation.sql


-- experiment results
create or alter view reporting.vw_experiment_results as

with experiment_users as (
    select
        e.user_key,
        e.variant,
        d.full_date as exposure_date
    from analytics.fact_experiments e
    join analytics.dim_date d
        on e.exposure_date_key = d.date_key
    where e.eligible_flag = 1
),

post_sessions as (
    select
        e.variant,
        e.user_key,
        s.session_id,
        s.session_duration_minutes,
        d.full_date as session_date
    from experiment_users e
    join analytics.fact_sessions s
        on e.user_key = s.user_key
    join analytics.dim_date d
        on s.date_key = d.date_key
    where d.full_date between e.exposure_date
                          and dateadd(day, 13, e.exposure_date)
),

post_events as (
    select
        e.variant,
        e.user_key,
        f.session_id,
        f.video_key,
        f.event_name,
        f.watch_duration_seconds,
        d.full_date as event_date
    from experiment_users e
    join analytics.fact_events f
        on e.user_key = f.user_key
    join analytics.dim_date d
        on f.date_key = d.date_key
    where d.full_date between e.exposure_date
                          and dateadd(day, 13, e.exposure_date)
),

sample_size as (
    select
        variant,
        count(*) as experiment_users
    from experiment_users
    group by variant
),

session_summary as (
    select
        variant,
        count(distinct session_id) as total_sessions,
        sum(case when session_duration_minutes < 1 then 1 else 0 end) as immediate_exits
    from post_sessions
    group by variant
),

event_summary as (
    select
        variant,
        sum(case when event_name = 'video_impression' then 1 else 0 end) as impressions,
        sum(case when event_name = 'video_click' then 1 else 0 end) as clicks
    from post_events
    group by variant
),

video_views as (
    select
        variant,
        user_key,
        session_id,
        video_key,
        max(case when event_name = 'video_start' then 1 else 0 end) as started,
        max(case when event_name = 'video_complete' then 1 else 0 end) as completed,
        max(case
            when event_name in ('like', 'comment', 'share', 'subscribe_channel')
            then 1 else 0
        end) as engaged,
        max(isnull(watch_duration_seconds, 0)) as watch_seconds
    from post_events
    where video_key is not null
    group by
        variant,
        user_key,
        session_id,
        video_key
),

view_summary as (
    select
        variant,
        sum(started) as videos_watched,
        sum(completed) as completed_videos,
        sum(engaged) as engaged_videos,
        sum(watch_seconds) as watch_seconds
    from video_views
    group by variant
),

day_7 as (
    select
        e.variant,
        count(distinct e.user_key) as retained_users
    from experiment_users e
    join analytics.fact_sessions s
        on e.user_key = s.user_key
    join analytics.dim_date d
        on s.date_key = d.date_key
    where d.full_date = dateadd(day, 7, e.exposure_date)
    group by e.variant
)

select
    n.variant,
    n.experiment_users,
    round(
        v.watch_seconds / 60.0
        / nullif(s.total_sessions, 0),
        2
    ) as average_watch_minutes_per_session,
    round(
        e.clicks * 100.0
        / nullif(e.impressions, 0),
        2
    ) as impression_ctr,
    round(
        v.videos_watched * 1.0
        / nullif(s.total_sessions, 0),
        2
    ) as videos_per_session,
    round(
        v.completed_videos * 100.0
        / nullif(v.videos_watched, 0),
        2
    ) as completion_rate,
    round(
        v.engaged_videos * 100.0
        / nullif(v.videos_watched, 0),
        2
    ) as engagement_rate,
    round(
        d.retained_users * 100.0
        / nullif(n.experiment_users, 0),
        2
    ) as seven_day_retention,
    round(
        s.immediate_exits * 100.0
        / nullif(s.total_sessions, 0),
        2
    ) as immediate_exit_rate,
    cast(null as decimal(10,2)) as negative_feedback_rate
from sample_size n
left join session_summary s
    on n.variant = s.variant
left join event_summary e
    on n.variant = e.variant
left join view_summary v
    on n.variant = v.variant
left join day_7 d
    on n.variant = d.variant;

go


-- checking the views
select top 10 * from reporting.vw_daily_product_kpis;
select * from reporting.vw_content_performance;
select * from reporting.vw_funnel_performance;
select top 20 * from reporting.vw_retention_cohorts;
select top 10 * from reporting.vw_user_segments;
select * from reporting.vw_experiment_results;
