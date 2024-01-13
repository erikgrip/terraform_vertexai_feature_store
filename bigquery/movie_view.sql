SELECT
    movie_id AS entity_id,
    genre,
    release_date,
    language,
    running_time,
    CURRENT_TIMESTAMP() AS feature_timestamp
FROM
    `${project}.${dataset}.${table}`

