variable "project_id" {
    description = "Google Cloud project ID"
    default = "csye-6225-dev-415015"
}

variable "credentials_file" {
    description = "Path service account key file"
    default = "/Users/para/Downloads/csye-6225-dev-415015-5d28fe9f38ac.json"
}

variable "region" {
    description = "GCP region"
    default     = "us-east1"
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
    default     = "10.0.3.0/24"
}

variable "db_subnet_cidr"{
    description = "CIDR of a new subnet"
    default     = "10.0.4.0/24"
}

variable "routing_mode"{
    description = "routing mode"
    default = "REGIONAL"
}

variable "computeGlobalAddress"{
    description = "address"
    default = "10.3.0.5"
}

#variable for zone
variable "zone"{
    description = "zone"
    default = "us-east1-b"
}

variable "disk_size"{
    description = "disk size"
    default = 10
}

variable "disk_type"{
    description = "disk type"
    default = "PD_SSD"
}

variable "availability_type"{
    description = "availability type"
    default = "REGIONAL"
}

variable "ipv4_enabled"{
    description = "ipv4 enabled"
    default = false
}

variable "database_version"{
    description = "database version"
    default = "MYSQL_5_7"
}

variable "deletion_protection"{
    description = "deletion protection"
    default = false
}

variable "sendgrid_key"{
    description = "sendgrid key"
}






