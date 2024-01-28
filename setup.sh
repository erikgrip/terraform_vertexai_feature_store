#!/bin/bash
. .env  # load .env file for the environment


# Create a new project
gcloud projects create $PROJECT_ID


# Set the project
gcloud config set project $PROJECT_ID


# Link the billing account
gcloud beta billing projects link $PROJECT_ID \
    --billing-account $(gcloud beta billing accounts list --format='value(ACCOUNT_ID)')


# Create service account and store the key locally
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --description="Service account for Terraform" \
    --display-name="Terraform"

gcloud iam service-accounts keys create $SERVICE_ACCOUNT_KEY_FILE \
    --iam-account $SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
    --key-file-type json


# Let the service account enable APIs
gcloud services enable cloudresourcemanager.googleapis.com \
    --project $PROJECT_ID

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/serviceusage.serviceUsageAdmin

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/servicemanagement.quotaAdmin


# Grant service account access to the manage Vertex AI, BigQuery and Storage
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/aiplatform.admin

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/bigquery.admin

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/storage.admin
