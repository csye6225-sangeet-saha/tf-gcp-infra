variable "project_id" {
    description = "Google Cloud project ID"
    default = "csye-6225-001"
}

variable "credentials_file" {
    description = "Path service account key file"
    default = "/Users/para/Downloads/csye-6225-001-a4682363897a.json"
}

variable "region" {
    description = "GCP region"
    default     = "us-central1"
}

variable "vpc_name"{
    description = "Name of a new vpc network"
    default     = "test-vpc-network"
}