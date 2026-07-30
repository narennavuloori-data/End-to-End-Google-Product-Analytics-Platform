-- row counts
select 'users' as table_name, count(*) as row_count
from staging.users
union all
select 'channels', count(*) from staging.channels
union all
select 'videos', count(*) from staging.videos
union all
select 'sessions', count(*) from staging.sessions
union all
select 'events', count(*) from staging.events
union all
select 'experiment_assignments', count(*) from staging.experiment_assignments;


-- duplicate primary keys
select user_id, count(*) as duplicate_count
from staging.users
group by user_id
having count(*) > 1;

select channel_id, count(*) as duplicate_count
from staging.channels
group by channel_id
having count(*) > 1;

select video_id, count(*) as duplicate_count
from staging.videos
group by video_id
having count(*) > 1;

select session_id, count(*) as duplicate_count
from staging.sessions
group by session_id
having count(*) > 1;

select event_id, count(*) as duplicate_count
from staging.events
group by event_id
having count(*) > 1;

select experiment_id, user_id, count(*) as duplicate_count
from staging.experiment_assignments
group by experiment_id, user_id
having count(*) > 1;


-- null primary keys
select count(*) as null_user_ids
from staging.users
where user_id is null;

select count(*) as null_channel_ids
from staging.channels
where channel_id is null;

select count(*) as null_video_ids
from staging.videos
where video_id is null;

select count(*) as null_session_ids
from staging.sessions
where session_id is null;

select count(*) as null_event_ids
from staging.events
where event_id is null;

select count(*) as null_experiment_keys
from staging.experiment_assignments
where experiment_id is null
   or user_id is null;


-- missing foreign keys
select count(*) as orphan_session_users
from staging.sessions s
left join staging.users u
    on s.user_id = u.user_id
where u.user_id is null;

select count(*) as orphan_event_sessions
from staging.events e
left join staging.sessions s
    on e.session_id = s.session_id
where s.session_id is null;

select count(*) as orphan_event_users
from staging.events e
left join staging.users u
    on e.user_id = u.user_id
where u.user_id is null;

select count(*) as invalid_video_references
from staging.events e
left join staging.videos v
    on e.video_id = v.video_id
where e.video_id is not null
  and v.video_id is null;

select count(*) as videos_without_valid_channels
from staging.videos v
left join staging.channels c
    on v.channel_id = c.channel_id
where c.channel_id is null;

select count(*) as orphan_experiment_users
from staging.experiment_assignments e
left join staging.users u
    on e.user_id = u.user_id
where u.user_id is null;


-- invalid timestamps and durations
select count(*) as invalid_session_timestamps
from staging.sessions
where session_start_timestamp is null
   or session_end_timestamp is null
   or session_end_timestamp < session_start_timestamp;

select count(*) as negative_session_duration
from staging.sessions
where session_duration_minutes < 0;

select count(*) as events_outside_session_time
from staging.events e
inner join staging.sessions s
    on e.session_id = s.session_id
where e.event_timestamp < s.session_start_timestamp
   or e.event_timestamp > s.session_end_timestamp;

select count(*) as negative_watch_duration
from staging.events
where watch_duration_seconds < 0;


-- experiment checks
select experiment_id, user_id
from staging.experiment_assignments
group by experiment_id, user_id
having count(distinct variant) > 1;

select variant, count(*) as user_count
from staging.experiment_assignments
group by variant
order by variant;



