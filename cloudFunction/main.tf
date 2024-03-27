variable "project_id" {
  description = "Project ID"
}

variable "vpc_name"{
    description = "VPC Name"
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

variable "sendgrid_key" {
  description = "Sendgrid API Key"
}

variable "region" {
    description = "Region"
    default = "us-east4"
}

resource "google_service_account" "cloud_function_service_account" {
  account_id   = "cloud-function-sa"
  display_name = "Cloud Function Service Account"
}

resource "google_project_iam_binding" "pubsub_subscriber_binding" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  members = [
    "serviceAccount:${google_service_account.cloud_function_service_account.email}",
  ]
}

resource "google_project_iam_binding" "storage_object_viewer_binding" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.cloud_function_service_account.email}",
  ]
}

resource "google_project_iam_binding" "logging_log_writer_binding" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  members = [
    "serviceAccount:${google_service_account.cloud_function_service_account.email}",
  ]
}

resource "google_project_iam_binding" "cloud_sql_client_binding" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  members = [
    "serviceAccount:${google_service_account.cloud_function_service_account.email}",
  ]
}

resource "google_project_iam_binding" "service_account_token_creator_binding" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  members = [
    "serviceAccount:${google_service_account.cloud_function_service_account.email}",
  ]
}

resource "google_pubsub_topic" "sendemail" {
  name = "sendemail"
  message_retention_duration = "604800s"
}

resource "google_vpc_access_connector" "connector" {
  name          = "vpc-con"
  ip_cidr_range = "10.8.0.0/28"
  network       = var.vpc_name
#   region        = "us-central1"
}

resource "google_cloudfunctions2_function" "user_mail_verification" {
  name = "user-mail-verification"
  location = var.region

  build_config {
    runtime = "nodejs16"
    entry_point = "helloPubSub"  # Set the entry point 
    environment_variables = {
        BUILD_CONFIG_TEST = "build_test"
    }
    source {
      storage_source {
        bucket = "mail_function"
        object = "function-source.zip"
      }
    }
  }

  service_config {
    max_instance_count  = 1
    min_instance_count = 0
    available_memory    = "1Gi"
    timeout_seconds     = 60
    max_instance_request_concurrency = 1
    available_cpu = "1"
    environment_variables = {
        SERVICE_CONFIG_TEST = "config_test",
        SENDGRID_API_KEY = "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",
        DATABASE = var.db_name,
        USERNAME = var.db_user,
        PASSWORD = var.db_password,
        HOST = var.db_ip
    }
    ingress_settings = "ALLOW_ALL"
    all_traffic_on_latest_revision = true
    service_account_email = google_service_account.cloud_function_service_account.email
    vpc_connector = google_vpc_access_connector.connector.id
  }

  event_trigger {
    trigger_region = "us-central1"
    event_type = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic = google_pubsub_topic.sendemail.id
    retry_policy = "RETRY_POLICY_RETRY"
  }
  depends_on = [google_vpc_access_connector.connector]
}
