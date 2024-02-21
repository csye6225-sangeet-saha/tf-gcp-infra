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
    default     = "us-east4"
}

variable "vpc_name"{
    description = "Name of a new vpc network"
    default     = "test-vpc-network-004"
}

variable "webapp_subnet_name"{
    description = "Name of a webapp subnet"
    default     = "webapp-subnet-001"
}

variable "db_subnet_name"{
    description = "Name of a db subnet"
    default     = "db-subnet-001"
}

variable "webapp_subnet_cidr"{
    description = "CIDR of a new subnet"
    default     = "10.0.3.0/16"
}

variable "db_subnet_cidr"{
    description = "CIDR of a new subnet"
    default     = "10.0.4.0/16"
}

variable "routing_mode"{
    description = "routing mode"
    default = "REGIONAL"
}






