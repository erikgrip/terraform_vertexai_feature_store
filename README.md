# terraform-vertexai-feature-store

With this project, you can effortlessly create a Feature Store in Google Cloud Platform's Vertex AI using Terraform. You can also use Google's Python SDK to retrieve some features served by the online store.

## Table of Contents


- [Technologies](#technologies)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
  - [Run Setup Script](#1-run-setup-script)
  - [Create GCP Resources](#2-create-gcp-resources)
- [Retrieve Online Feature Values](#retrieve-online-feature-values)
- [Cleanup](#cleanup)
  - [Delete Feature Store and Associated Resources](#delete-feature-store-and-associated-resources)
  - [Delete Entire Project](#delete-entire-project)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)


## Technologies  

The project was created using

* Google Cloud Platform (GCP)  
* Terraform  
* Python  
* Poetry  
* Bash  

## Prerequisites

1. **GCP Account**: Ensure you have a Google Cloud Platform (GCP) account with an active billing account.

2. **Google Cloud SDK**: Install Google's `gcloud` CLI.
   - [Google Cloud SDK Installation Guide](https://cloud.google.com/sdk/docs/install)
   - Initialize `gcloud`:
     ```bash
     gcloud init
     ```

3. **Terraform**: Install Terraform by following the instructions on HashiCorp's website.
   - [Terraform Installation Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

4. **Poetry**: (Optional) If you plan to run the `serving.ipynb` notebook, install Poetry to manage dependencies.
   - [Poetry Installation Guide](https://python-poetry.org/docs/#installation)
   - Navigate to the root of this project and run:
     ```bash
     poetry install
     ```

## Setup

### 1. Run Setup Script

Run the setup script to create a project linked to your billing account, enable necessary APIs, and configure other settings:
```bash
./setup_project.sh
```

### 2. Create GCP Resources

Use Terraform to create the GCP resources:
```bash
cd infra
terraform apply
```
This step may take a few minutes. Once the feature store is created, you need to wait for the first data sync to complete before feature values can be served. To check the data sync status, go to the Vertex AI > Feature Store > Online Store in the GCP console and click on each FeatureView.

The GCP resources created will incur costs. Remember to delete the resources when you are done!

## Retrieve Online Feature Values

Run the `serving.ipynb` notebook to retrieve sample features from your new feature store.

## Cleanup

### Delete Feature Store and Associated Resources

If you want to delete the feature store but keep your project for future use:
```bash
terraform destroy
```

### Delete Entire Project

If you don't plan to recreate the feature store or wish to set it up in another project, delete the project:
```bash
./delete_project.sh
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
