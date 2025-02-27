{{ config(materialized='table') }}

with trips_data as (
    select * from {{ ref('fact_trips') }}
),
cte as ( 
    select 
    service_type,
    extract(year from pickup_datetime) as year,
    extract(month from pickup_datetime) as month,
    fare_amount
    from trips_data
    where fare_amount > 0 and trip_distance > 0 
    and payment_type_description in ('Cash', 'Credit card')),
cte2 as (select service_type,
percentile_cont(fare_amount,0.97) over (partition by service_type,year,month) as p97,
percentile_cont(fare_amount,0.95) over (partition by service_type,year,month) as p95,
percentile_cont(fare_amount,0.9) over (partition by service_type,year,month) as p90
from cte where year=2020 and month=4)
select distinct*from cte2 order by service_type