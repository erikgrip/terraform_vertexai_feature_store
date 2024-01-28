#!/bin/bash
. .env  # Use PROJECT_ID from .env file

# Take in the region, feature store name, feature view name, and entity ID
REGION=$1
FEATURE_ONLINESTORE_NAME=$2
FEATURE_VIEW_NAME=$3
ENTITY_ID=$4

echo "-------------------------"
echo "INPUT:"
echo "PROJECT_ID: $PROJECT_ID"
echo "REGION: $REGION"
echo "FEATURE_ONLINESTORE_NAME: $FEATURE_ONLINESTORE_NAME"
echo "FEATURE_VIEW_NAME: $FEATURE_VIEW_NAME"
echo "ENTITY_ID: $ENTITY_ID"
echo "-------------------------"


URL="https://$REGION-aiplatform.googleapis.com/v1/projects/$PROJECT_ID/locations/$REGION/featureOnlineStores/$FEATURE_ONLINESTORE_NAME/featureViews/$FEATURE_VIEW_NAME:fetchFeatureValues"
DATA=$(printf '{"data_key": {"key": "%s"}}' $ENTITY_ID)

# Make curl request and print response in terminal
feature_values=$(curl -s -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d "$DATA" \
    $URL)

echo "OUTPUT:"
echo $feature_values
echo "-------------------------"

