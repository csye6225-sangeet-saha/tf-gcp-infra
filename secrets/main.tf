variable "project_id" {
  description = "Project ID"
}

variable "subnetwork_name" {
  description = "Subnet name"
}

variable "db_name" {
  description = "Database name" 
}

variable "db_user" {
  description = "Database user"
}

variable "db_password" {
  description = "Database password"
}  

variable "db_ip" {
 description = "Database IP"
}

variable "region" {
  description = "region"
}

variable service_account {
  description = "Service account name"
}

locals {
  secrets = {
    project_id       = var.project_id
    subnetwork_name  = var.subnetwork_name
    db_name          = var.db_name
    db_user          = var.db_user
    db_password      = var.db_password
    db_ip            = var.db_ip
    region           = var.region
    service_account  = var.service_account
  }
}

resource "google_secret_manager_secret" "my_secret" {
  for_each = local.secrets

  secret_id = each.key

  replication {
    user_managed {
      replicas {
        location = "us-east1"
      }
      replicas {
        location = "us-east4"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "my_secret_versions" {
  for_each = local.secrets

  secret = google_secret_manager_secret.my_secret[each.key].name

  secret_data = each.value
}
