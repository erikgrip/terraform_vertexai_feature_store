#-----------------#
####### API #######
#-----------------#

# Enable required APIs
resource "google_project_service" "bigquery" {
  provider                   = google
  project                    = var.gcp_project
  service                    = "bigquery.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "vertexai" {
  provider                   = google
  project                    = var.gcp_project
  service                    = "aiplatform.googleapis.com"
  disable_dependent_services = true
}


#-----------------#
##### Storage #####
#-----------------#

# Bucket to store sample data
resource "google_storage_bucket" "data" {
  provider = google                   # Can be left out if only using one provider
  name     = "example-bq-data-bucket" # Needs to be globally unique
  location = "europe-west1"
}

# Copy local data to bucket
resource "google_storage_bucket_object" "user" {
  provider = google
  name     = "user.parquet"
  bucket   = google_storage_bucket.data.name
  source   = "../data/user.parquet"
}

resource "google_storage_bucket_object" "movie" {
  provider = google
  name     = "movie.parquet"
  bucket   = google_storage_bucket.data.name
  source   = "../data/movie.parquet"
}

resource "google_storage_bucket_object" "movie_emb" {
  provider = google
  name     = "movie_with_embedding.parquet"
  bucket   = google_storage_bucket.data.name
  source   = "../data/movie_with_embedding.parquet"
}

resource "google_storage_bucket_object" "rating" {
  provider = google
  name     = "rating.parquet"
  bucket   = google_storage_bucket.data.name
  source   = "../data/rating.parquet"
}

#------------------#
##### BigQuery #####
#------------------#

# Create BigQuery dataset
resource "google_bigquery_dataset" "dataset" {
  provider   = google
  dataset_id = "example_dataset"
  location   = "EU"
  depends_on = [google_project_service.bigquery]
}

# Create BigQuery tables
resource "google_bigquery_table" "user" {
  provider   = google
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "user"

  external_data_configuration {
    autodetect    = true
    source_format = "PARQUET"
    schema        = file("../bigquery/user_schema.json")

    source_uris = [
      "gs://${google_storage_bucket.data.name}/user.parquet"
    ]
  }
  deletion_protection = false
}

resource "google_bigquery_table" "movie" {
  provider   = google
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "movie"

  external_data_configuration {
    autodetect    = true
    source_format = "PARQUET"
    schema        = file("../bigquery/movie_schema.json")

    source_uris = [
      "gs://${google_storage_bucket.data.name}/movie.parquet"
    ]
  }
  deletion_protection = false
}

resource "google_bigquery_table" "movie_emb" {
  provider   = google
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "movie_with_embedding"

  external_data_configuration {
    autodetect    = true
    source_format = "PARQUET"
    schema        = file("../bigquery/movie_with_embedding_schema.json")

    source_uris = [
      "gs://${google_storage_bucket.data.name}/movie_with_embedding.parquet"
    ]
    parquet_options {
      enable_list_inference = true  # Make embedding column be read correctly
    }
  }
  deletion_protection = false
}


resource "google_bigquery_table" "rating" {
  provider   = google
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "rating"

  external_data_configuration {
    autodetect    = true
    source_format = "PARQUET"
    schema        = file("../bigquery/rating_schema.json")

    source_uris = [
      "gs://${google_storage_bucket.data.name}/rating.parquet"
    ]
  }
  deletion_protection = false
}

# Create BigQuery views
resource "google_bigquery_table" "user_view" {
  provider   = google
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "user_view"
  view {
    query = templatefile(
      "../bigquery/user_view.sql",
      {
        project = var.gcp_project
        dataset = google_bigquery_dataset.dataset.dataset_id
        table   = google_bigquery_table.user.table_id
      }
    )
    use_legacy_sql = false
  }
  deletion_protection = false
}

resource "google_bigquery_table" "movie_view" {
  provider   = google
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "movie_view"
  view {
    query = templatefile(
      "../bigquery/movie_view.sql",
      {
        project = var.gcp_project
        dataset = google_bigquery_dataset.dataset.dataset_id
        table   = google_bigquery_table.movie.table_id
      }
    )
    use_legacy_sql = false
  }
  deletion_protection = false
}

resource "google_bigquery_table" "movie_with_embedding_view" {
  provider   = google
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "movie_with_embedding_view"
  view {
    query = templatefile(
      "../bigquery/movie_with_embedding_view.sql",
      {
        project = var.gcp_project
        dataset = google_bigquery_dataset.dataset.dataset_id
        table   = google_bigquery_table.movie_emb.table_id
      }
    )
    use_legacy_sql = false
  }
  deletion_protection = false
}


resource "google_bigquery_table" "user_rating_view" {
  provider   = google
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "user_rating_view"
  view {
    query = templatefile(
      "../bigquery/user_rating_view.sql",
      {
        project = var.gcp_project
        dataset = google_bigquery_dataset.dataset.dataset_id
        table   = google_bigquery_table.rating.table_id
      }
    )
    use_legacy_sql = false
  }
  deletion_protection = false
}

resource "google_bigquery_table" "user_rating_view_latest" {
  provider   = google
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "user_rating_view_latest"
  view {
    query = templatefile(
      "../bigquery/user_rating_view_latest.sql",
      {
        project = var.gcp_project
        dataset = google_bigquery_dataset.dataset.dataset_id
        table   = google_bigquery_table.user_rating_view.table_id
      }
    )
    use_legacy_sql = false
  }
  deletion_protection = false
}


#-------------------#
##### Vertex AI #####
#-------------------#

## Create Featurestore
#resource "google_vertex_ai_featurestore" "" {
#  provider = google-beta
#  name     = "example_featurestore"
#  region   = var.gcp_region
#  online_serving_config {
#    fixed_node_count = 1
#  }
#  force_destroy = true
#}

# Create FeatureGroups
resource "google_vertex_ai_feature_group" "user" {
  name        = "user_feature_group"
  description = "Feature group with user features"
  region      = var.gcp_region
  big_query {
    big_query_source {
      # The source table must have a column named 'feature_timestamp' of type TIMESTAMP.
      input_uri = "bq://${var.gcp_project}.${google_bigquery_dataset.dataset.dataset_id}.${google_bigquery_table.user_view.table_id}"
    }
    entity_id_columns = ["entity_id"]
  }
}

resource "google_vertex_ai_feature_group" "movie" {
  name        = "movie_feature_group"
  description = "Feature group with movie features"
  region      = var.gcp_region
  big_query {
    big_query_source {
      input_uri = "bq://${var.gcp_project}.${google_bigquery_dataset.dataset.dataset_id}.${google_bigquery_table.movie_view.table_id}"
    }
    entity_id_columns = ["entity_id"]
  }
}


resource "google_vertex_ai_feature_group" "movie_emb" {
  name        = "movie_emb_feature_group"
  description = "Feature group with movie embedding features"
  region      = var.gcp_region
  big_query {
    big_query_source {
      input_uri = "bq://${var.gcp_project}.${google_bigquery_dataset.dataset.dataset_id}.${google_bigquery_table.movie_with_embedding_view.table_id}"
    }
    entity_id_columns = ["entity_id"]
  }

}


resource "google_vertex_ai_feature_group" "user_rating" {
  name        = "user_rating_feature_group"
  description = "Feature group with user rating features"
  region      = var.gcp_region
  big_query {
    big_query_source {
      input_uri = "bq://${var.gcp_project}.${google_bigquery_dataset.dataset.dataset_id}.${google_bigquery_table.user_rating_view.table_id}"
    }
    entity_id_columns = ["entity_id"]
  }
}

# Create Feature Group Features
resource "google_vertex_ai_feature_group_feature" "username" {
  name          = "username"
  region        = var.gcp_region
  feature_group = google_vertex_ai_feature_group.user.name
  description   = "The user's username"
  labels = {
    label-one = "value-one"
  }
}

resource "google_vertex_ai_feature_group_feature" "email" {
  name          = "email"
  region        = var.gcp_region
  feature_group = google_vertex_ai_feature_group.user.name
  description   = "The user's email address"
  labels = {
    label-one = "value-one"
  }
}


# Create Online Store
resource "google_vertex_ai_feature_online_store" "featureonlinestore" {
  provider = google-beta
  name     = "example_online_store"
  region   = var.gcp_region
  bigtable {
    auto_scaling {
      min_node_count         = 1
      max_node_count         = 1
      cpu_utilization_target = 80
    }
  }
  embedding_management {
    enabled = true
  }
  force_destroy = true
  depends_on    = [google_project_service.vertexai]
}

# Create FeatureViews
resource "google_vertex_ai_feature_online_store_featureview" "user_featureview" {
  provider             = google
  name                 = "user_featureview"
  region               = var.gcp_region
  feature_online_store = google_vertex_ai_feature_online_store.featureonlinestore.name
  sync_config {
    cron = "1/5 * * * *" # every 5th minute
  }
  big_query_source {
    uri               = "bq://${var.gcp_project}.${google_bigquery_dataset.dataset.dataset_id}.${google_bigquery_table.user_view.table_id}"
    entity_id_columns = ["entity_id"]
  }
}

resource "google_vertex_ai_feature_online_store_featureview" "user_rating_featureview_latest" {
  provider             = google
  name                 = "user_rating_featureview_latest"
  region               = var.gcp_region
  feature_online_store = google_vertex_ai_feature_online_store.featureonlinestore.name
  sync_config {
    cron = "1/5 * * * *" # every 5th minute
  }
  big_query_source {
    uri               = "bq://${var.gcp_project}.${google_bigquery_dataset.dataset.dataset_id}.${google_bigquery_table.user_rating_view.table_id}"
    entity_id_columns = ["entity_id"]
  }

}

resource "google_vertex_ai_feature_online_store_featureview" "movie_emb_featureview" {
  provider             = google-beta
  name                 = "movie_emb_featureview"
  region               = var.gcp_region
  feature_online_store = google_vertex_ai_feature_online_store.featureonlinestore.name
  sync_config {
    cron = "1/5 * * * *" # every 5th minute
  }
  big_query_source {
    uri               = "bq://${var.gcp_project}.${google_bigquery_dataset.dataset.dataset_id}.${google_bigquery_table.movie_with_embedding_view.table_id}"
    entity_id_columns = ["entity_id"]
  }
  vector_search_config {
    embedding_column      = "embedding"
    filter_columns        = ["genre", "language"]
    crowding_column       = "genre_code"
    distance_measure_type = "DOT_PRODUCT_DISTANCE"
    tree_ah_config {
      leaf_node_embedding_count = "1000"
    }
    embedding_dimension = "1536"
  }
}




