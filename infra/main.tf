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
  name     = "user.csv"
  bucket   = google_storage_bucket.data.name
  source   = "../data/user.csv"
}

resource "google_storage_bucket_object" "movie" {
  provider = google
  name     = "movie.csv"
  bucket   = google_storage_bucket.data.name
  source   = "../data/movie.csv"
}

resource "google_storage_bucket_object" "rating" {
  provider = google
  name     = "rating.csv"
  bucket   = google_storage_bucket.data.name
  source   = "../data/rating.csv"
}

#------------------#
##### BigQuery #####
#------------------#

# Create BigQuery dataset
resource "google_bigquery_dataset" "dataset" {
  provider   = google
  dataset_id = "example_dataset"
  location   = "EU"
}

# Create BigQuery tables
resource "google_bigquery_table" "user" {
  provider   = google
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "user"
  schema     = file("../bigquery/user_schema.json")
  external_data_configuration {
    autodetect    = true
    source_format = "CSV"

    csv_options {
      quote             = "\""
      skip_leading_rows = 1
    }

    source_uris = [
      "gs://${google_storage_bucket.data.name}/user.csv"
    ]
  }
  deletion_protection = false
}

resource "google_bigquery_table" "movie" {
  provider   = google
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "movie"
  schema     = file("../bigquery/movie_schema.json")
  external_data_configuration {
    autodetect    = true
    source_format = "CSV"

    csv_options {
      quote             = "\""
      skip_leading_rows = 1
    }

    source_uris = [
      "gs://${google_storage_bucket.data.name}/movie.csv"
    ]
  }
  deletion_protection = false
}

resource "google_bigquery_table" "rating" {
  provider   = google
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "rating"
  schema     = file("../bigquery/rating_schema.json")
  external_data_configuration {
    autodetect    = true
    source_format = "CSV"

    csv_options {
      quote             = "\""
      skip_leading_rows = 1
    }

    source_uris = [
      "gs://${google_storage_bucket.data.name}/rating.csv"
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

#-------------------#
##### Vertex AI #####
#-------------------#

# Create Vertex AI Featurestore
#resource "google_ai_platform_featurestore_featurestore" "featurestore" {
#  provider        = google-beta
#  project         = var.gcp_project
#  region          = var.gcp_region
#  featurestore_id = "example_featurestore"
#  labels = {
#    "example" = "true"
#  }
#}




