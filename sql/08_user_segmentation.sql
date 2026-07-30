-- create one user segmentation view
create or alter view reporting.vw_user_segments as

with max_date as (
    select max(d.full_date) as last_data_date
    from analytics.fact_sessions s
    join analytics.dim_date d
        on s.date_key = d.date_key
),

session_summary as (
    select
        s.user_key,
        count(*) as total_sessions,
        count(distinct d.[year] * 100 + d.week_number) as active_weeks,
        min(d.full_date) as first_active_date,
        max(d.full_date) as last_active_date,
        sum(case
            when s.traffic_source = 'YouTube Search' then 1
            else 0
        end) as search_sessions,
        sum(case
            when s.traffic_source in (
                'Homepage Recommendation',
                'Suggested Video'
            ) then 1
            else 0
        end) as recommendation_sessions
    from analytics.fact_sessions s
    join analytics.dim_date d
        on s.date_key = d.date_key
    group by s.user_key
),

video_views as (
    select
        e.user_key,
        e.session_id,
        e.video_key,
        max(case
            when e.event_name = 'video_start' then 1
            else 0
        end) as video_started,
        max(isnull(e.watch_duration_seconds, 0)) as watch_seconds
    from analytics.fact_events e
    where e.video_key is not null
    group by
        e.user_key,
        e.session_id,
        e.video_key
),

view_summary as (
    select
        user_key,
        sum(video_started) as videos_watched,
        sum(watch_seconds) / 3600.0 as total_watch_hours
    from video_views
    group by user_key
),

engagement_summary as (
    select
        user_key,
        sum(case
            when event_name in (
                'like',
                'comment',
                'share',
                'subscribe_channel'
            ) then 1
            else 0
        end) as engagement_actions
    from analytics.fact_events
    group by user_key
),

traffic_counts as (
    select
        user_key,
        traffic_source,
        count(*) as session_count
    from analytics.fact_sessions
    group by user_key, traffic_source
),

traffic_rank as (
    select
        user_key,
        traffic_source,
        row_number() over (
            partition by user_key
            order by session_count desc
        ) as rank_number
    from traffic_counts
),

content_counts as (
    select
        e.user_key,
        v.video_category,
        count(*) as view_count
    from analytics.fact_events e
    join analytics.dim_video v
        on e.video_key = v.video_key
    where e.event_name = 'video_start'
    group by e.user_key, v.video_category
),

content_rank as (
    select
        user_key,
        video_category,
        row_number() over (
            partition by user_key
            order by view_count desc
        ) as rank_number
    from content_counts
),

video_format as (
    select
        e.user_key,
        sum(case
            when v.video_type = 'Short' then 1
            else 0
        end) as short_views,
        sum(case
            when v.video_type in (
                'Standard Video',
                'Live Stream',
                'Premiere'
            ) then 1
            else 0
        end) as long_form_views
    from analytics.fact_events e
    join analytics.dim_video v
        on e.video_key = v.video_key
    where e.event_name = 'video_start'
    group by e.user_key
),

user_data as (
    select
        u.user_id,
        isnull(s.total_sessions, 0) as total_sessions,
        isnull(s.active_weeks, 0) as active_weeks,
        s.first_active_date,
        s.last_active_date,
        datediff(
            day,
            s.last_active_date,
            m.last_data_date
        ) as days_since_last_activity,
        isnull(s.search_sessions, 0) as search_sessions,
        isnull(s.recommendation_sessions, 0) as recommendation_sessions,
        round(isnull(v.total_watch_hours, 0), 2) as total_watch_hours,
        isnull(v.videos_watched, 0) as videos_watched,
        isnull(e.engagement_actions, 0) as engagement_actions,
        isnull(t.traffic_source, 'Unknown') as primary_traffic_source,
        isnull(c.video_category, 'Unknown') as preferred_content_category,
        isnull(f.short_views, 0) as short_views,
        isnull(f.long_form_views, 0) as long_form_views,
        m.last_data_date
    from analytics.dim_user u
    cross join max_date m
    left join session_summary s
        on u.user_key = s.user_key
    left join view_summary v
        on u.user_key = v.user_key
    left join engagement_summary e
        on u.user_key = e.user_key
    left join traffic_rank t
        on u.user_key = t.user_key
       and t.rank_number = 1
    left join content_rank c
        on u.user_key = c.user_key
       and c.rank_number = 1
    left join video_format f
        on u.user_key = f.user_key
)

select
    user_id,

    case
        when total_sessions = 0
          or days_since_last_activity >= 60
            then 'Churned Viewers'

        when days_since_last_activity between 30 and 59
            then 'At-Risk Viewers'

        when first_active_date >= dateadd(day, -30, last_data_date)
            then 'New Viewers'

        when total_sessions >= 20
         and total_watch_hours >= 10
         and engagement_actions >= 10
            then 'Highly Engaged Viewers'

        when search_sessions >= total_sessions * 0.50
            then 'Search-Driven Viewers'

        when recommendation_sessions >= total_sessions * 0.50
            then 'Recommendation-Driven Viewers'

        when short_views > long_form_views
            then 'Short-Form Viewers'

        when long_form_views > short_views
            then 'Long-Form Viewers'

        when total_sessions <= 5
         and total_watch_hours < 2
            then 'Casual Viewers'

        when active_weeks >= 4
            then 'Regular Viewers'

        else 'Casual Viewers'
    end as user_segment,

    total_sessions,
    total_watch_hours,
    videos_watched,
    engagement_actions,
    last_active_date,
    days_since_last_activity,
    primary_traffic_source,
    preferred_content_category

from user_data;

go


-- check segment sizes
select
    user_segment,
    count(*) as user_count
from reporting.vw_user_segments
group by user_segment
order by user_count desc;


-- check sample users
select top 20 *
from reporting.vw_user_segments;
