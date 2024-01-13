variable "gcp_project" {
    type        = string
    description = "The GCP project to deploy to."
}

variable "gcp_region" {
    type        = string
    description = "The GCP region to deploy to."
}

variable "gcp_svc_key" {
    type        = string
    description = "The local key file for the service account."
}
