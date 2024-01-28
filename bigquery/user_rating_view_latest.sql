-- Get the latest feature values for each entity
SELECT
    entity_id,
    rating_count_90d,
    avg_rating_90d,
    feature_timestamp
FROM `${project}.${dataset}.${table}`
QUALIFY ROW_NUMBER() OVER(PARTITION BY entity_id ORDER BY feature_timestamp DESC) = 1





