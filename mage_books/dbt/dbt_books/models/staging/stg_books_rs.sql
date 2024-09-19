{{
    config(
        materialized='view'
    )
}}

WITH booksdata AS
(
    SELECT
        *
    FROM
        {{ source('staging', 'books')}}
    WHERE
        year >= 0 AND year <= 2024
)
SELECT
    isbn,
    title,
    author,
    year,
    publisher
FROM
    booksdata
