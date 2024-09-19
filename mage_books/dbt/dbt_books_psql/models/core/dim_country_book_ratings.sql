{{
    config(materialized='table')
}}

WITH books AS (
	SELECT * FROM {{ ref('stg_books') }}
),
ratings AS (
    SELECT * FROM {{ ref('stg_ratings') }}
),
users AS (
	SELECT * FROM {{ ref('stg_users') }}
),
book_ratings AS (
	SELECT
		u.country AS country,
		b.isbn AS isbn,
		b.title AS title,
		ROUND(AVG(r.rating), 6) as avg_score,
		COUNT(r.rating) AS rating_count
	FROM
		ratings AS r
	JOIN users AS u
		ON r.user_id = u.user_id
	JOIN books AS b
		ON r.isbn = b.isbn
	GROUP BY
		u.country,
		b.isbn,
		b.title
)

SELECT
	*
FROM
    book_ratings
