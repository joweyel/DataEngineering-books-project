{{
    config(
        materialized='view'
    )
}}

WITH ratingsdata AS
(
    SELECT
        *
    FROM
        {{ source('staging', 'ratings')}}
)
SELECT
    user_id,
    isbn,
    rating
FROM
    ratingsdata