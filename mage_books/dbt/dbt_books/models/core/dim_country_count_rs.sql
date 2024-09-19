{{
    config(
        materialized='table'
    )
}}

WITH users AS (
    SELECT
        *
    FROM
        {{ ref('stg_users_rs') }}
),
ratings AS (
    SELECT
        *
    FROM
        {{ ref('stg_ratings_rs') }}

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
