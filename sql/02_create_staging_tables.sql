-- users table
create table staging.users (
    user_id varchar(10),
    signup_date date,
    country varchar(50),
    region varchar(60),
    age_group varchar(10),
    preferred_language varchar(30),
    subscription_type varchar(30),
    acquisition_channel varchar(30),
    preferred_device varchar(20),
    account_status varchar(15)
);

-- channels table
create table staging.channels (
    channel_id varchar(10),
    channel_name varchar(120),
    channel_category varchar(30),
    creator_country varchar(50),
    primary_language varchar(30),
    channel_created_date date,
    subscriber_band varchar(20),
    content_rating varchar(20)
);

-- videos table
create table staging.videos (
    video_id varchar(10),
    channel_id varchar(10),
    upload_date date,
    video_category varchar(30),
    video_type varchar(30),
    video_language varchar(30),
    duration_seconds int,
    content_rating varchar(20),
    title_length int,
    thumbnail_style varchar(30)
);

-- sessions table
create table staging.sessions (
    session_id varchar(12),
    user_id varchar(10),
    session_start_timestamp datetime2(3),
    session_end_timestamp datetime2(3),
    device_type varchar(20),
    operating_system varchar(30),
    country varchar(50),
    traffic_source varchar(40),
    app_version varchar(20),
    network_type varchar(20),
    session_duration_minutes decimal(10,2)
);

-- events table
create table staging.events (
    event_id varchar(12),
    session_id varchar(12),
    user_id varchar(10),
    event_timestamp datetime2(3),
    event_name varchar(40),
    event_sequence_number int,
    video_id varchar(10),
    channel_id varchar(10),
    recommendation_source varchar(30),
    search_category varchar(30),
    watch_duration_seconds decimal(12,3),
    video_position_seconds decimal(12,3),
    is_autoplay bit,
    watch_duration_minutes decimal(12,3),
    event_date date,
    event_hour int,
    day_of_week varchar(10),
    is_weekend bit,
    is_engagement_event bit,
    is_video_completion bit
);

-- experiment assignments table
create table staging.experiment_assignments (
    experiment_id varchar(50),
    user_id varchar(10),
    variant varchar(12),
    assignment_date date,
    first_exposure_date date,
    eligible_flag bit
);

-- checking the created tables
select table_schema, table_name
from information_schema.tables
where table_schema = 'staging'
order by table_name;
