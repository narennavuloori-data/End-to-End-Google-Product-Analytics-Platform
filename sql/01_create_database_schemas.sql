-- creating project schemas

create schema staging;


create schema analytics;


create schema reporting;

-- checking the schemas

select name as schema_name
from sys.schemas
where name in ('staging', 'analytics', 'reporting');