{{
    config(materialized='table')
}}

WITH books AS (
    SELECT
        *
    FROM
        {{ ref('stg_books') }}
),
ratings AS (
    SELECT
        *
    FROM
        {{ ref('stg_ratings') }}
), 
users AS (
    SELECT
        *
    FROM
        {{ ref('stg_users') }}
)



SELECT
	r.user_id AS user_id,
	r.isbn AS isbn,
	r.rating AS rating,
	u.age AS age,
	u.city AS city,
	u._state AS state,
	u.country AS country,
	b.title AS title,
	b.author AS author,
	b._year AS year,
	b.publisher AS publisher
FROM
	ratings AS r
	JOIN users AS u ON r.user_id = u.user_id
	JOIN books AS b ON r.isbn = b.isbn