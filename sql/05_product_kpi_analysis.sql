-- daily active users
select
    d.full_date,
    count(distinct s.user_key) as daily_active_users
from analytics.fact_sessions s
join analytics.dim_date d
    on s.date_key = d.date_key
group by d.full_date
order by d.full_date;


-- weekly active users
select
    d.[year],
    d.week_number,
    count(distinct s.user_key) as weekly_active_users
from analytics.fact_sessions s
join analytics.dim_date d
    on s.date_key = d.date_key
group by d.[year], d.week_number
order by d.[year], d.week_number;


-- monthly active users
select
    d.[year],
    d.[month],
    d.month_name,
    count(distinct s.user_key) as monthly_active_users
from analytics.fact_sessions s
join analytics.dim_date d
    on s.date_key = d.date_key
group by d.[year], d.[month], d.month_name
order by d.[year], d.[month];


-- monthly stickiness
with daily_users as (
    select
        d.[year],
        d.[month],
        d.full_date,
        count(distinct s.user_key) as dau
    from analytics.fact_sessions s
    join analytics.dim_date d
        on s.date_key = d.date_key
    group by d.[year], d.[month], d.full_date
),
monthly_users as (
    select
        d.[year],
        d.[month],
        count(distinct s.user_key) as mau
    from analytics.fact_sessions s
    join analytics.dim_date d
        on s.date_key = d.date_key
    group by d.[year], d.[month]
)
select
    du.[year],
    du.[month],
    round(avg(du.dau * 1.0) / mu.mau * 100, 2) as dau_mau_stickiness
from daily_users du
join monthly_users mu
    on du.[year] = mu.[year]
   and du.[month] = mu.[month]
group by du.[year], du.[month], mu.mau
order by du.[year], du.[month];


-- new and returning users
select
    d.full_date,
    count(distinct case
        when u.signup_date = d.full_date then s.user_key
    end) as new_users,
    count(distinct case
        when u.signup_date < d.full_date then s.user_key
    end) as returning_users
from analytics.fact_sessions s
join analytics.dim_date d
    on s.date_key = d.date_key
join analytics.dim_user u
    on s.user_key = u.user_key
group by d.full_date
order by d.full_date;


-- session metrics
select
    count(*) as total_sessions,
    round(avg(session_duration_minutes), 2) as average_session_minutes,
    round(
        count(*) * 1.0 / count(distinct user_key),
        2
    ) as sessions_per_user,
    round(
        (
            select count(*)
            from analytics.fact_events
            where event_name = 'video_start'
        ) * 1.0 / count(*),
        2
    ) as videos_watched_per_session
from analytics.fact_sessions;


-- viewing metrics
with video_views as (
    select
        e.session_id,
        e.user_key,
        e.video_key,
        max(case
            when e.event_name = 'video_start' then 1
            else 0
        end) as started,
        max(case
            when e.event_name = 'video_complete' then 1
            else 0
        end) as completed,
        max(isnull(e.watch_duration_seconds, 0)) as watch_seconds
    from analytics.fact_events e
    where e.video_key is not null
    group by
        e.session_id,
        e.user_key,
        e.video_key
)
select
    count(*) as total_views,
    round(sum(v.watch_seconds) / 3600.0, 2) as total_watch_hours,
    round(
        sum(v.watch_seconds) / count(distinct v.user_key) / 60.0,
        2
    ) as average_watch_minutes_per_user,
    round(
        sum(v.watch_seconds) / count(distinct v.session_id) / 60.0,
        2
    ) as average_watch_minutes_per_session,
    round(
        avg(v.watch_seconds * 100.0 / nullif(d.duration_seconds, 0)),
        2
    ) as average_watch_percentage,
    round(
        sum(v.completed) * 100.0 / nullif(sum(v.started), 0),
        2
    ) as video_completion_rate
from video_views v
join analytics.dim_video d
    on v.video_key = d.video_key
where v.started = 1;


-- discovery metrics
with discovery as (
    select
        sum(case when event_name = 'video_impression' then 1 else 0 end) as impressions,
        sum(case when event_name = 'video_click' then 1 else 0 end) as clicks,
        sum(case
            when event_name = 'video_impression'
             and recommendation_source <> 'Search Results'
            then 1 else 0
        end) as recommendation_impressions,
        sum(case
            when event_name = 'video_click'
             and recommendation_source <> 'Search Results'
            then 1 else 0
        end) as recommendation_clicks
    from analytics.fact_events
),
search_sessions as (
    select
        session_id,
        max(case when event_name = 'search' then 1 else 0 end) as searched,
        max(case
            when event_name = 'video_click'
             and recommendation_source = 'Search Results'
            then 1 else 0
        end) as search_click
    from analytics.fact_events
    group by session_id
)
select
    d.impressions as video_impressions,
    d.clicks as video_clicks,
    round(d.clicks * 100.0 / nullif(d.impressions, 0), 2) as impression_ctr,
    round(
        sum(s.search_click) * 100.0 / nullif(sum(s.searched), 0),
        2
    ) as search_success_rate,
    round(
        d.recommendation_clicks * 100.0
        / nullif(d.recommendation_impressions, 0),
        2
    ) as recommendation_ctr
from discovery d
cross join search_sessions s
group by
    d.impressions,
    d.clicks,
    d.recommendation_impressions,
    d.recommendation_clicks;


-- engagement metrics
select
    sum(case when event_name = 'like' then 1 else 0 end) as total_likes,
    sum(case when event_name = 'comment' then 1 else 0 end) as total_comments,
    sum(case when event_name = 'share' then 1 else 0 end) as total_shares,
    sum(case
        when event_name = 'subscribe_channel' then 1
        else 0
    end) as total_channel_subscriptions,
    round(
        count(distinct case
            when event_name in (
                'like',
                'comment',
                'share',
                'subscribe_channel'
            )
            then user_key
        end) * 100.0
        / nullif(
            count(distinct case
                when event_name = 'video_start' then user_key
            end),
            0
        ),
        2
    ) as engagement_rate
from analytics.fact_events;
