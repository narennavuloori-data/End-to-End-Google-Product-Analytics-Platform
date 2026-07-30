-- date dimension
create table analytics.dim_date (
    date_key int primary key,
    full_date date,
    day int,
    day_name varchar(10),
    week_number int,
    month int,
    month_name varchar(10),
    quarter int,
    year int,
    is_weekend bit
);

declare @current_date date = '2010-01-01';
declare @end_date date = '2026-07-26';

while @current_date <= @end_date
begin
    insert into analytics.dim_date
    values (
        convert(int, convert(char(8), @current_date, 112)),
        @current_date,
        day(@current_date),
        datename(weekday, @current_date),
        datepart(week, @current_date),
        month(@current_date),
        datename(month, @current_date),
        datepart(quarter, @current_date),
        year(@current_date),
        case
            when datename(weekday, @current_date) in ('Saturday', 'Sunday')
            then 1 else 0
        end
    );

    set @current_date = dateadd(day, 1, @current_date);
end;


-- user dimension
create table analytics.dim_user (
    user_key int identity(1,1) primary key,
    user_id varchar(10) unique,
    signup_date date,
    age_group varchar(10),
    preferred_language varchar(30),
    subscription_type varchar(30),
    acquisition_channel varchar(30),
    account_status varchar(15)
);

insert into analytics.dim_user (
    user_id,
    signup_date,
    age_group,
    preferred_language,
    subscription_type,
    acquisition_channel,
    account_status
)
select
    user_id,
    signup_date,
    age_group,
    preferred_language,
    subscription_type,
    acquisition_channel,
    account_status
from staging.users;


-- channel dimension
create table analytics.dim_channel (
    channel_key int identity(1,1) primary key,
    channel_id varchar(10) unique,
    channel_name varchar(120),
    channel_category varchar(30),
    creator_country varchar(50),
    primary_language varchar(30),
    subscriber_band varchar(20)
);

insert into analytics.dim_channel (
    channel_id,
    channel_name,
    channel_category,
    creator_country,
    primary_language,
    subscriber_band
)
select
    channel_id,
    channel_name,
    channel_category,
    creator_country,
    primary_language,
    subscriber_band
from staging.channels;


-- video dimension
create table analytics.dim_video (
    video_key int identity(1,1) primary key,
    video_id varchar(10) unique,
    channel_id varchar(10),
    upload_date date,
    video_category varchar(30),
    video_type varchar(30),
    video_language varchar(30),
    duration_seconds int,
    content_rating varchar(20)
);

insert into analytics.dim_video (
    video_id,
    channel_id,
    upload_date,
    video_category,
    video_type,
    video_language,
    duration_seconds,
    content_rating
)
select
    video_id,
    channel_id,
    upload_date,
    video_category,
    video_type,
    video_language,
    duration_seconds,
    content_rating
from staging.videos;


-- device dimension
create table analytics.dim_device (
    device_key int identity(1,1) primary key,
    device_type varchar(20),
    operating_system varchar(30),
    app_version varchar(20),
    network_type varchar(20)
);

insert into analytics.dim_device (
    device_type,
    operating_system,
    app_version,
    network_type
)
select distinct
    device_type,
    operating_system,
    isnull(app_version, 'Unknown'),
    isnull(network_type, 'Unknown')
from staging.sessions;


-- geography dimension
create table analytics.dim_geography (
    geography_key int identity(1,1) primary key,
    country varchar(50),
    region varchar(60)
);

insert into analytics.dim_geography (
    country,
    region
)
select distinct
    country,
    isnull(region, 'Unknown')
from staging.users

union

select distinct
    country,
    'Unknown'
from staging.sessions;


-- sessions fact table
create table analytics.fact_sessions (
    session_id varchar(12) primary key,
    user_key int,
    date_key int,
    device_key int,
    geography_key int,
    session_start_timestamp datetime2(3),
    session_end_timestamp datetime2(3),
    session_duration_minutes decimal(10,2),
    traffic_source varchar(40),

    foreign key (user_key) references analytics.dim_user(user_key),
    foreign key (date_key) references analytics.dim_date(date_key),
    foreign key (device_key) references analytics.dim_device(device_key),
    foreign key (geography_key) references analytics.dim_geography(geography_key)
);

insert into analytics.fact_sessions (
    session_id,
    user_key,
    date_key,
    device_key,
    geography_key,
    session_start_timestamp,
    session_end_timestamp,
    session_duration_minutes,
    traffic_source
)
select
    s.session_id,
    u.user_key,
    d.date_key,
    dv.device_key,
    g.geography_key,
    s.session_start_timestamp,
    s.session_end_timestamp,
    s.session_duration_minutes,
    s.traffic_source
from staging.sessions s
join analytics.dim_user u
    on s.user_id = u.user_id
join analytics.dim_date d
    on cast(s.session_start_timestamp as date) = d.full_date
join analytics.dim_device dv
    on s.device_type = dv.device_type
   and s.operating_system = dv.operating_system
   and isnull(s.app_version, 'Unknown') = dv.app_version
   and isnull(s.network_type, 'Unknown') = dv.network_type
join analytics.dim_geography g
    on s.country = g.country
   and g.region = 'Unknown';


-- events fact table
create table analytics.fact_events (
    event_id varchar(12) primary key,
    session_id varchar(12),
    user_key int,
    video_key int,
    channel_key int,
    date_key int,
    device_key int,
    geography_key int,
    event_timestamp datetime2(3),
    event_name varchar(40),
    event_sequence_number int,
    watch_duration_seconds decimal(12,3),
    video_position_seconds decimal(12,3),
    recommendation_source varchar(30),
    is_autoplay bit,

    foreign key (session_id) references analytics.fact_sessions(session_id),
    foreign key (user_key) references analytics.dim_user(user_key),
    foreign key (video_key) references analytics.dim_video(video_key),
    foreign key (channel_key) references analytics.dim_channel(channel_key),
    foreign key (date_key) references analytics.dim_date(date_key),
    foreign key (device_key) references analytics.dim_device(device_key),
    foreign key (geography_key) references analytics.dim_geography(geography_key)
);

insert into analytics.fact_events (
    event_id,
    session_id,
    user_key,
    video_key,
    channel_key,
    date_key,
    device_key,
    geography_key,
    event_timestamp,
    event_name,
    event_sequence_number,
    watch_duration_seconds,
    video_position_seconds,
    recommendation_source,
    is_autoplay
)
select
    e.event_id,
    e.session_id,
    s.user_key,
    v.video_key,
    c.channel_key,
    d.date_key,
    s.device_key,
    s.geography_key,
    e.event_timestamp,
    e.event_name,
    e.event_sequence_number,
    e.watch_duration_seconds,
    e.video_position_seconds,
    e.recommendation_source,
    e.is_autoplay
from staging.events e
join analytics.fact_sessions s
    on e.session_id = s.session_id
join analytics.dim_date d
    on e.event_date = d.full_date
left join analytics.dim_video v
    on e.video_id = v.video_id
left join analytics.dim_channel c
    on e.channel_id = c.channel_id;


-- experiments fact table
create table analytics.fact_experiments (
    experiment_id varchar(50),
    user_key int,
    variant varchar(12),
    assignment_date_key int,
    exposure_date_key int,
    eligible_flag bit,

    primary key (experiment_id, user_key),
    foreign key (user_key) references analytics.dim_user(user_key),
    foreign key (assignment_date_key) references analytics.dim_date(date_key),
    foreign key (exposure_date_key) references analytics.dim_date(date_key)
);

insert into analytics.fact_experiments (
    experiment_id,
    user_key,
    variant,
    assignment_date_key,
    exposure_date_key,
    eligible_flag
)
select
    e.experiment_id,
    u.user_key,
    e.variant,
    a.date_key,
    x.date_key,
    e.eligible_flag
from staging.experiment_assignments e
join analytics.dim_user u
    on e.user_id = u.user_id
join analytics.dim_date a
    on e.assignment_date = a.full_date
left join analytics.dim_date x
    on e.first_exposure_date = x.full_date;


-- checking row counts
select 'dim_date' as table_name, count(*) as row_count
from analytics.dim_date
union all
select 'dim_user', count(*) from analytics.dim_user
union all
select 'dim_channel', count(*) from analytics.dim_channel
union all
select 'dim_video', count(*) from analytics.dim_video
union all
select 'dim_device', count(*) from analytics.dim_device
union all
select 'dim_geography', count(*) from analytics.dim_geography
union all
select 'fact_sessions', count(*) from analytics.fact_sessions
union all
select 'fact_events', count(*) from analytics.fact_events
union all
select 'fact_experiments', count(*) from analytics.fact_experiments;
