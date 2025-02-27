{{ config(materialized="view") }}

with
    tripdata as (
        select*from {{ source("staging", "fhv_tripdata") }}
        where dispatching_base_num is not null
    )
select
    -- identifiers
    {{ dbt.safe_cast("PULocationID", api.Column.translate_type("integer")) }}
    as pickup_locationid,
    {{ dbt.safe_cast("DOLocationID", api.Column.translate_type("integer")) }}
    as dropoff_locationid,
    -- timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropOff_datetime as timestamp) as dropoff_datetime,
from tripdata

-- dbt build --select <model.sql> --vars '{'is_test_run: false}'
{% if var("is_test_run", default=false) %} limit 100 {% endif %}
