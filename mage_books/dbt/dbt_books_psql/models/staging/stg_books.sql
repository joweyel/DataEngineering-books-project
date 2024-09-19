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
        _year >= 0 AND _year <= 2024
)
SELECT
    isbn,
    title,
    author,
    _year,
    publisher
FROM
    booksdata
