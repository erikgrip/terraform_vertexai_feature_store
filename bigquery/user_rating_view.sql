SELECT
    CAST(user_id AS STRING) AS entity_id,
    COUNT(rating) AS rating_count_90d,
    AVG(rating) AS avg_rating_90d,
    day AS feature_timestamp
FROM (
    -- Generate a timestamp range table
    SELECT
        day,
        ROW_NUMBER() OVER(ORDER BY day) AS time_seq
    FROM UNNEST(
        GENERATE_TIMESTAMP_ARRAY(
            TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 365 DAY),
            CURRENT_TIMESTAMP(),
            INTERVAL 1 DAY
        )
    ) AS day
) timestamp_range_table
JOIN `vertex-feature-store.example_dataset.rating`
ON review_timestamp BETWEEN TIMESTAMP_SUB(day, INTERVAL 90 DAY) AND day 
GROUP BY 1, 4





