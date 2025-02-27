# Module 4 Homework: Analytics Engineering

<br>

## Question 1: Understanding dbt model resolution

After setting up sources.yml and the environment variables, compile the .sql model outputs

select * 
from `myproject`.`raw_nyc_tripdata`.`ext_green_taxi`

<br>

## Question 2: dbt Variables & Dynamic Models

For command line arguments to take precedence over ENV_VARs, we need var on the outside and then env_var on the inside. So, it would be CURRENT_DATE - INTERVAL '{{ var("days_back", env_var("DAYS_BACK", "30")) }}' DAY.

<br>

## Question 3: dbt Data Lineage and Execution

dbt run --select models/staging/+ would not materialize it because dim_zones.sql would not have been run.

<br>

## Question 4: dbt Macros and Jinja

The first statement is true because without the value of that env variable it would not compile. The second statement is not true because without the value of that env variable, if doesn't affect when model_type == 'core' and when model_type is not 'core' it can use target_env_var if stging_env_var is not set. The third to fifth statements are true because they follow the macro logic.

<br>

## Question 5: Taxi Quarterly Revenue Growth

Refer to 

Answer: green: {best: 2020/Q1, worst: 2020/Q2}, yellow: {best: 2020/Q1, worst: 2020/Q2}

Code: 

{{ config(materialized='table') }}

with trips_data as (
    select * from {{ ref('fact_trips') }}
),
cte as ( 
    select 
    service_type,
    extract(year from pickup_datetime) as year,
    {{pickup_date_quarter("pickup_datetime")}} as quarter,
    sum(total_amount) as quarterly_revenue,
    from trips_data
    where extract(year from pickup_datetime) in (2019,2020)
    group by 1,2,3),
cte2 as (select service_type,year,quarter, quarterly_revenue,
lag(quarterly_revenue) over (partition by service_type,quarter order by year) as previous_year_revenue from cte
order by service_type,quarter,year),
cte3 as (select service_type, concat(year,"/",quarter) as year_quarter,
(quarterly_revenue-previous_year_revenue)/previous_year_revenue*100 as yoy_growth from cte2)
select*from cte3 where yoy_growth is not null order by service_type,yoy_growth desc

<br>

## Question 6: P97/P95/P90 Taxi Monthly Fare

Refer to fct_taxi_trips_monthly_fare_p95.sql

Answer: green: {p97: 55.0, p95: 45.0, p90: 26.5}, yellow: {p97: 31.5, p95: 25.5, p90: 19.0}

Code:

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


<br>

## Question 7: Top #Nth longest P90 travel time Location for FHV

Refer to fct_fhv_monthly_zone_traveltime_p90.sql

Answer: LaGuardia Airport, Chinatown, Garment District

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