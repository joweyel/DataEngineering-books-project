{{ 
    config(
        materialized='table'
    ) 
}}

SELECT 
    country_in, 
    country_out
FROM
    {{ ref('country_lut') }}