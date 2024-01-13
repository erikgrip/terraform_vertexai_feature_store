# terraform-vertexai-feature-store
Use terraform to set up a feature store in GCP's Vertex AI

## Set Up  
Create a GCP Account and add a project
Enable APIs

**Install Google's gcloud CLI**:  
https://cloud.google.com/sdk/docs/install

Initialize gcloud
```bash
gcloud init
```

**Install Terraform**:  
Follow the instructions on Hashicorp's webite ([here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli))


Create a service account with access   
Make sure to keep the key file safe. We'll store it in a local directory called "secrets" and add it to .gitignore so it's not accidentally committed to source control. That's fine for this demo, but in a real project you should use [best practices](https://cloud.google.com/iam/docs/best-practices-for-managing-service-account-keys) for storing and managing secrets.

