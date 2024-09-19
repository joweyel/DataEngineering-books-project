{{
    config(
        materialized='table'
    )
}}

WITH users AS (
    SELECT
        *
    FROM
        {{ ref('stg_users') }}
),
ratings AS (
    SELECT
        *
    FROM
        {{ ref('stg_ratings') }}

)

SELECT
    u.country AS country,
    COUNT(r.rating)
FROM
    ratings AS r 
JOIN users AS u 
    ON r.user_id = u.user_id
GROUP BY
    u.country
