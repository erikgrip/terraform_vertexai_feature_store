SELECT
    CAST(movie_id AS STRING) AS entity_id,  -- FeatureGruop ID must be string
    movie_name,
    genre,
    genre_code,
    language,
    running_time,
    embedding,
    CURRENT_TIMESTAMP() AS feature_timestamp
FROM
    `${project}.${dataset}.${table}`

