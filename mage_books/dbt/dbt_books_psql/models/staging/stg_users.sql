{{
    config(
        materialized='view'
    )
}}


WITH usersdata AS (
    SELECT
        *
    FROM
        {{ source('staging', 'users') }}
),
cuontry_lut AS (
    SELECT
        *
    FROM
        {{ ref('dim_country_lut') }}
),
mapped_users AS (
    SELECT
        user_id,
        age,
        INITCAP(city) AS city,
        INITCAP(_state) AS _state,
        COALESCE(
            lut.country_out,
            CASE 
                WHEN TRIM(INITCAP(usersdata.country)) = '' THEN 'Unknown'
                ELSE INITCAP(usersdata.country)
            END
        ) AS country
    FROM
        usersdata
    LEFT JOIN cuontry_lut AS lut
    ON
        LOWER(usersdata.country) = LOWER(lut.country_in)
)
SELECT 
	* 
FROM 
	mapped_users
	