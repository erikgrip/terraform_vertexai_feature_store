#!/bin/bash
. .env  # load .env file for the environment

# Create a new project
gcloud projects create $PROJECT_ID

# Set the project
gcloud config set project $PROJECT_ID

# Link the billing account
gcloud beta billing projects link $PROJECT_ID \
    --billing-account $(gcloud beta billing accounts list --format='value(ACCOUNT_ID)')

# Enable Vertex AI API
gcloud services enable \
    aiplatform.googleapis.com \
    bigquerystorage.googleapis.com \
    --project $PROJECT_ID

# Create service account
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --description="Service account for Terraform" \
    --display-name="Terraform"

# Grant service account access to the manage Vertex AI
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/aiplatform.admin

# Grant service account access to the manage storage
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/storage.admin

# Grant service account access to the manage BigQuery
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/bigquery.admin

# Create service account key
gcloud iam service-accounts keys create $SERVICE_ACCOUNT_KEY_FILE \
    --iam-account $SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
    --key-file-type json
  