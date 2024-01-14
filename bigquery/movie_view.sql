SELECT
    CAST(movie_id AS STRING) AS entity_id,  -- FeatureGruop ID must be string
    genre,
    release_date,
    language,
    running_time,
    CURRENT_TIMESTAMP() AS feature_timestamp
FROM
    `${project}.${dataset}.${table}`

