{{
    config(materialized='table')
}}

WITH facts_all AS (
    SELECT * FROM {{ ref('facts_all_rs') }}
),
age_brackets AS (
    SELECT
        age,
        CASE
            WHEN age = 0 THEN 'Age Missing'
            WHEN age BETWEEN  1 AND 10 THEN '1-10'
            WHEN age BETWEEN 11 AND 20 THEN '11-20'
            WHEN age BETWEEN 21 AND 30 THEN '21-30'
            WHEN age BETWEEN 31 AND 40 THEN '31-40'
            WHEN age BETWEEN 41 AND 50 THEN '41-50'
            WHEN age BETWEEN 51 AND 60 THEN '51-60'
            WHEN age BETWEEN 61 AND 70 THEN '61-70'
            WHEN age BETWEEN 71 AND 80 THEN '71-80'
            WHEN age BETWEEN 81 AND 90 THEN '81-90'
            WHEN age BETWEEN 91 AND 99 THEN '91-99'
            ELSE '+100(OLD)'
        END AS age_bracket,
        rating
    FROM
        facts_all
)

SELECT
    age_bracket,
    COUNT(rating) AS rating_count
FROM
    age_brackets
GROUP BY
	age_bracket
ORDER BY
	MIN(age)