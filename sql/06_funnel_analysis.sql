-- creating the funnel data
drop table if exists #funnel_data;
drop table if exists #funnel_stages;

with event_flags as (
    select
        session_id,
        user_key,
        video_key,
        max(case when event_name = 'video_impression' then 1 else 0 end) as impression,
        max(case when event_name = 'video_click' then 1 else 0 end) as click_event,
        max(case when event_name = 'video_start' then 1 else 0 end) as start_event,
        max(case when event_name = 'video_progress_50' then 1 else 0 end) as watched_50,
        max(case when event_name = 'video_complete' then 1 else 0 end) as completed,
        max(case
            when event_name in ('like', 'share', 'subscribe_channel')
            then 1 else 0
        end) as engaged
    from analytics.fact_events
    where video_key is not null
    group by session_id, user_key, video_key
)
select
    f.session_id,
    f.user_key,
    f.video_key,
    dv.device_type,
    g.country,
    s.traffic_source,
    v.video_category,
    u.subscription_type,
    case
        when u.signup_date = d.full_date then 'New'
        else 'Returning'
    end as user_type,
    isnull(x.variant, 'Not in Experiment') as variant,
    f.impression,
    case
        when f.impression = 1 and f.click_event = 1
        then 1 else 0
    end as clicked,
    case
        when f.impression = 1
         and f.click_event = 1
         and f.start_event = 1
        then 1 else 0
    end as started,
    case
        when f.impression = 1
         and f.click_event = 1
         and f.start_event = 1
         and f.watched_50 = 1
        then 1 else 0
    end as watched_50,
    case
        when f.impression = 1
         and f.click_event = 1
         and f.start_event = 1
         and f.watched_50 = 1
         and f.completed = 1
        then 1 else 0
    end as completed,
    case
        when f.impression = 1
         and f.click_event = 1
         and f.start_event = 1
         and f.watched_50 = 1
         and f.completed = 1
         and f.engaged = 1
        then 1 else 0
    end as engaged
into #funnel_data
from event_flags f
join analytics.fact_sessions s
    on f.session_id = s.session_id
join analytics.dim_device dv
    on s.device_key = dv.device_key
join analytics.dim_geography g
    on s.geography_key = g.geography_key
join analytics.dim_video v
    on f.video_key = v.video_key
join analytics.dim_user u
    on f.user_key = u.user_key
join analytics.dim_date d
    on s.date_key = d.date_key
left join analytics.fact_experiments x
    on f.user_key = x.user_key
   and s.date_key >= x.exposure_date_key
where f.impression = 1;


-- putting all funnel stages into one table
select
    session_id,
    user_key,
    device_type,
    country,
    traffic_source,
    video_category,
    subscription_type,
    user_type,
    variant,
    1 as stage_number,
    'Video Impression' as stage_name,
    impression as reached_stage
into #funnel_stages
from #funnel_data

union all

select
    session_id, user_key, device_type, country, traffic_source,
    video_category, subscription_type, user_type, variant,
    2, 'Video Click', clicked
from #funnel_data

union all

select
    session_id, user_key, device_type, country, traffic_source,
    video_category, subscription_type, user_type, variant,
    3, 'Video Start', started
from #funnel_data

union all

select
    session_id, user_key, device_type, country, traffic_source,
    video_category, subscription_type, user_type, variant,
    4, 'Watched 50%', watched_50
from #funnel_data

union all

select
    session_id, user_key, device_type, country, traffic_source,
    video_category, subscription_type, user_type, variant,
    5, 'Video Complete', completed
from #funnel_data

union all

select
    session_id, user_key, device_type, country, traffic_source,
    video_category, subscription_type, user_type, variant,
    6, 'Like, Share or Subscribe', engaged
from #funnel_data;


-- overall funnel
with stage_counts as (
    select
        stage_number,
        stage_name,
        count(distinct user_key) as users_entering_stage
    from #funnel_stages
    where reached_stage = 1
    group by stage_number, stage_name
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
from funnel
order by stage_number;


-- funnel by device, country and other user groups
with segment_counts as (
    select
        segments.segment_type,
        segments.segment_value,
        f.stage_number,
        f.stage_name,
        count(distinct f.user_key) as users_entering_stage
    from #funnel_stages f
    cross apply (
        values
            ('Device', f.device_type),
            ('Country', f.country),
            ('Traffic Source', f.traffic_source),
            ('Video Category', f.video_category),
            ('Subscription Type', f.subscription_type),
            ('User Type', f.user_type),
            ('Experiment Variant', f.variant)
    ) segments(segment_type, segment_value)
    where f.reached_stage = 1
      and (
          segments.segment_type <> 'Experiment Variant'
          or segments.segment_value in ('Control', 'Treatment')
      )
    group by
        segments.segment_type,
        segments.segment_value,
        f.stage_number,
        f.stage_name
),
segment_funnel as (
    select
        segment_type,
        segment_value,
        stage_number,
        stage_name,
        users_entering_stage,
        lag(users_entering_stage) over (
            partition by segment_type, segment_value
            order by stage_number
        ) as previous_stage_users,
        first_value(users_entering_stage) over (
            partition by segment_type, segment_value
            order by stage_number
        ) as first_stage_users
    from segment_counts
)
select
    segment_type,
    segment_value,
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
from segment_funnel
order by
    segment_type,
    segment_value,
    stage_number;


-- largest overall drop-off
with stage_counts as (
    select
        stage_number,
        stage_name,
        count(distinct user_key) as users_entering_stage
    from #funnel_stages
    where reached_stage = 1
    group by stage_number, stage_name
),
drop_offs as (
    select
        stage_number,
        stage_name,
        lag(stage_name) over (
            order by stage_number
        ) as previous_stage,
        users_entering_stage,
        lag(users_entering_stage) over (
            order by stage_number
        ) as previous_stage_users
    from stage_counts
)
select top 1
    previous_stage,
    stage_name as next_stage,
    previous_stage_users - users_entering_stage as drop_off_count,
    round(
        (previous_stage_users - users_entering_stage) * 100.0
        / nullif(previous_stage_users, 0),
        2
    ) as drop_off_percentage,
    case
        when stage_name = 'Video Click'
            then 'Improve thumbnail and title relevance.'
        when stage_name = 'Video Start'
            then 'Reduce loading time and playback errors.'
        when stage_name = 'Watched 50%'
            then 'Improve the opening and content relevance.'
        when stage_name = 'Video Complete'
            then 'Improve video pacing and viewer satisfaction.'
        when stage_name = 'Like, Share or Subscribe'
            then 'Use clearer engagement prompts after viewing.'
    end as suggested_action
from drop_offs
where previous_stage_users is not null
order by drop_off_count desc;
