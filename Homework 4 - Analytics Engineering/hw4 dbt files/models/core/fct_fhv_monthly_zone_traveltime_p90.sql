{{ config(materialized='table') }}

with trips_data as (
    select * from {{ ref('fhv_trips') }}
),
cte as ( 
    select 
    year, month, pickup_zone, dropoff_zone, pickup_locationid, dropoff_locationid,
    DATETIME_DIFF(dropoff_datetime,pickup_datetime,second) as trip_duration
    from trips_data
    where pickup_zone in ('Newark Airport', 'SoHo', 'Yorkville East') and year=2019 and month=11),
cte2 as (select pickup_zone,dropoff_zone,
percentile_cont(trip_duration,0.90) over (partition by year, month, pickup_locationid, dropoff_locationid) as p90
from cte),
cte3 as (select distinct*from cte2 order by dropoff_zone, p90 desc),
cte4 as (select *, rank() over (partition by pickup_zone order by p90 desc) as ranking from cte3)
select pickup_zone, dropoff_zone, p90 from cte4 where ranking=2 order by pickup_zone