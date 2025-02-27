{#
    This macro returns the quarter of pickup datetime 
#}

{% macro pickup_date_quarter(pickup_datetime) -%}

    case 
        when extract(month from {{ dbt.safe_cast("pickup_datetime", api.Column.translate_type("date")) }})<=3 then 'Q1'
        when extract(month from {{ dbt.safe_cast("pickup_datetime", api.Column.translate_type("date")) }})<=6 then 'Q2'
        when extract(month from {{ dbt.safe_cast("pickup_datetime", api.Column.translate_type("date")) }})<=9 then 'Q3'
        else 'Q4'
    end

{%- endmacro %}