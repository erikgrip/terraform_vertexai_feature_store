#!/bin/bash

# Read variables from terraform.tfvars file
PROJECT_ID=$(grep gcp_project infra/terraform.tfvars | cut -d'=' -f2 | tr -d '"')

echo "Deleting project $PROJECT_ID ..."
gcloud projects delete $PROJECT_ID
