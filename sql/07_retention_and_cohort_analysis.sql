-- one row per user with retention flags
create or alter view reporting.vw_user_retention as

with activity as (
    select distinct
        s.user_key,
        d.full_date as activity_date
    from analytics.fact_sessions s
    join analytics.dim_date d
        on s.date_key = d.date_key
),

first_activity as (
    select
        user_key,
        min(activity_date) as first_activity_date
    from activity
    group by user_key
),

device_counts as (
    select
        s.user_key,
        d.device_type,
        count(*) as session_count
    from analytics.fact_sessions s
    join analytics.dim_device d
        on s.device_key = d.device_key
    group by s.user_key, d.device_type
),

device_rank as (
    select
        user_key,
        device_type,
        row_number() over (
            partition by user_key
            order by session_count desc
        ) as rank_number
    from device_counts
),

country_counts as (
    select
        s.user_key,
        g.country,
        count(*) as session_count
    from analytics.fact_sessions s
    join analytics.dim_geography g
        on s.geography_key = g.geography_key
    group by s.user_key, g.country
),

country_rank as (
    select
        user_key,
        country,
        row_number() over (
            partition by user_key
            order by session_count desc
        ) as rank_number
    from country_counts
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
)

select
    f.user_key,
    u.user_id,
    f.first_activity_date,
    datefromparts(
        year(f.first_activity_date),
        month(f.first_activity_date),
        1
    ) as cohort_month,
    u.acquisition_channel,
    u.subscription_type,
    isnull(d.device_type, 'Unknown') as preferred_device,
    isnull(c.country, 'Unknown') as country,
    isnull(t.traffic_source, 'Unknown') as traffic_source,
    isnull(p.video_category, 'Unknown') as content_preference,

    case when exists (
        select 1
        from activity a
        where a.user_key = f.user_key
          and a.activity_date = dateadd(day, 1, f.first_activity_date)
    ) then 1 else 0 end as day_1_retained,

    case when exists (
        select 1
        from activity a
        where a.user_key = f.user_key
          and a.activity_date = dateadd(day, 7, f.first_activity_date)
    ) then 1 else 0 end as day_7_retained,

    case when exists (
        select 1
        from activity a
        where a.user_key = f.user_key
          and a.activity_date = dateadd(day, 14, f.first_activity_date)
    ) then 1 else 0 end as day_14_retained,

    case when exists (
        select 1
        from activity a
        where a.user_key = f.user_key
          and a.activity_date = dateadd(day, 30, f.first_activity_date)
    ) then 1 else 0 end as day_30_retained,

    case when exists (
        select 1
        from activity a
        where a.user_key = f.user_key
          and a.activity_date > f.first_activity_date
    ) then 1 else 0 end as returning_user

from first_activity f
join analytics.dim_user u
    on f.user_key = u.user_key
left join device_rank d
    on f.user_key = d.user_key
   and d.rank_number = 1
left join country_rank c
    on f.user_key = c.user_key
   and c.rank_number = 1
left join traffic_rank t
    on f.user_key = t.user_key
   and t.rank_number = 1
left join content_rank p
    on f.user_key = p.user_key
   and p.rank_number = 1;

go


-- overall retention metrics
create or alter view reporting.vw_retention_metrics as

select
    count(*) as total_users,
    round(
        sum(day_1_retained) * 100.0 / count(*),
        2
    ) as day_1_retention,
    round(
        sum(day_7_retained) * 100.0 / count(*),
        2
    ) as day_7_retention,
    round(
        sum(day_14_retained) * 100.0 / count(*),
        2
    ) as day_14_retention,
    round(
        sum(day_30_retained) * 100.0 / count(*),
        2
    ) as day_30_retention,
    round(
        sum(returning_user) * 100.0 / count(*),
        2
    ) as returning_user_rate
from reporting.vw_user_retention;

go


-- weekly retention
create or alter view reporting.vw_weekly_retention as

with activity as (
    select distinct
        s.user_key,
        d.full_date as activity_date
    from analytics.fact_sessions s
    join analytics.dim_date d
        on s.date_key = d.date_key
),

first_activity as (
    select
        user_key,
        min(activity_date) as first_activity_date
    from activity
    group by user_key
),

weekly_activity as (
    select distinct
        a.user_key,
        d.year as cohort_year,
        d.week_number as cohort_week,
        datediff(
            day,
            f.first_activity_date,
            a.activity_date
        ) / 7 as retention_week
    from activity a
    join first_activity f
        on a.user_key = f.user_key
    join analytics.dim_date d
        on f.first_activity_date = d.full_date
),

cohort_size as (
    select
        d.year as cohort_year,
        d.week_number as cohort_week,
        count(*) as cohort_users
    from first_activity f
    join analytics.dim_date d
        on f.first_activity_date = d.full_date
    group by d.year, d.week_number
)

select
    w.cohort_year,
    w.cohort_week,
    w.retention_week,
    c.cohort_users,
    count(distinct w.user_key) as retained_users,
    round(
        count(distinct w.user_key) * 100.0
        / c.cohort_users,
        2
    ) as retention_percentage
from weekly_activity w
join cohort_size c
    on w.cohort_year = c.cohort_year
   and w.cohort_week = c.cohort_week
group by
    w.cohort_year,
    w.cohort_week,
    w.retention_week,
    c.cohort_users;

go


-- monthly cohort retention
create or alter view reporting.vw_monthly_retention as

with activity as (
    select distinct
        s.user_key,
        d.full_date as activity_date
    from analytics.fact_sessions s
    join analytics.dim_date d
        on s.date_key = d.date_key
),

first_activity as (
    select
        user_key,
        min(activity_date) as first_activity_date
    from activity
    group by user_key
),

monthly_activity as (
    select distinct
        a.user_key,
        datefromparts(
            year(f.first_activity_date),
            month(f.first_activity_date),
            1
        ) as cohort_month,
        datediff(
            month,
            datefromparts(
                year(f.first_activity_date),
                month(f.first_activity_date),
                1
            ),
            datefromparts(
                year(a.activity_date),
                month(a.activity_date),
                1
            )
        ) as month_number
    from activity a
    join first_activity f
        on a.user_key = f.user_key
),

cohort_size as (
    select
        datefromparts(
            year(first_activity_date),
            month(first_activity_date),
            1
        ) as cohort_month,
        count(*) as cohort_users
    from first_activity
    group by
        datefromparts(
            year(first_activity_date),
            month(first_activity_date),
            1
        )
)

select
    m.cohort_month,
    m.month_number,
    c.cohort_users,
    count(distinct m.user_key) as retained_users,
    round(
        count(distinct m.user_key) * 100.0
        / c.cohort_users,
        2
    ) as retention_percentage
from monthly_activity m
join cohort_size c
    on m.cohort_month = c.cohort_month
group by
    m.cohort_month,
    m.month_number,
    c.cohort_users;

go


-- retention by user group
create or alter view reporting.vw_retention_by_segment as

select
    'Acquisition Channel' as segment_type,
    acquisition_channel as segment_value,
    count(*) as total_users,
    round(sum(day_1_retained) * 100.0 / count(*), 2) as day_1_retention,
    round(sum(day_7_retained) * 100.0 / count(*), 2) as day_7_retention,
    round(sum(day_14_retained) * 100.0 / count(*), 2) as day_14_retention,
    round(sum(day_30_retained) * 100.0 / count(*), 2) as day_30_retention,
    round(sum(returning_user) * 100.0 / count(*), 2) as returning_user_rate
from reporting.vw_user_retention
group by acquisition_channel

union all

select
    'Subscription Type',
    subscription_type,
    count(*),
    round(sum(day_1_retained) * 100.0 / count(*), 2),
    round(sum(day_7_retained) * 100.0 / count(*), 2),
    round(sum(day_14_retained) * 100.0 / count(*), 2),
    round(sum(day_30_retained) * 100.0 / count(*), 2),
    round(sum(returning_user) * 100.0 / count(*), 2)
from reporting.vw_user_retention
group by subscription_type

union all

select
    'Preferred Device',
    preferred_device,
    count(*),
    round(sum(day_1_retained) * 100.0 / count(*), 2),
    round(sum(day_7_retained) * 100.0 / count(*), 2),
    round(sum(day_14_retained) * 100.0 / count(*), 2),
    round(sum(day_30_retained) * 100.0 / count(*), 2),
    round(sum(returning_user) * 100.0 / count(*), 2)
from reporting.vw_user_retention
group by preferred_device

union all

select
    'Country',
    country,
    count(*),
    round(sum(day_1_retained) * 100.0 / count(*), 2),
    round(sum(day_7_retained) * 100.0 / count(*), 2),
    round(sum(day_14_retained) * 100.0 / count(*), 2),
    round(sum(day_30_retained) * 100.0 / count(*), 2),
    round(sum(returning_user) * 100.0 / count(*), 2)
from reporting.vw_user_retention
group by country

union all

select
    'Traffic Source',
    traffic_source,
    count(*),
    round(sum(day_1_retained) * 100.0 / count(*), 2),
    round(sum(day_7_retained) * 100.0 / count(*), 2),
    round(sum(day_14_retained) * 100.0 / count(*), 2),
    round(sum(day_30_retained) * 100.0 / count(*), 2),
    round(sum(returning_user) * 100.0 / count(*), 2)
from reporting.vw_user_retention
group by traffic_source

union all

select
    'Content Preference',
    content_preference,
    count(*),
    round(sum(day_1_retained) * 100.0 / count(*), 2),
    round(sum(day_7_retained) * 100.0 / count(*), 2),
    round(sum(day_14_retained) * 100.0 / count(*), 2),
    round(sum(day_30_retained) * 100.0 / count(*), 2),
    round(sum(returning_user) * 100.0 / count(*), 2)
from reporting.vw_user_retention
group by content_preference;

go


-- check the results
select *
from reporting.vw_retention_metrics;

select *
from reporting.vw_weekly_retention
order by cohort_year, cohort_week, retention_week;

select *
from reporting.vw_monthly_retention
order by cohort_month, month_number;

select *
from reporting.vw_retention_by_segment
order by segment_type, segment_value;
