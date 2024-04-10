variable "region"{
    description = "region"
}

variable "project_id"{
    description = "project_id"
}

resource "google_kms_key_ring" "my_key_ring" {
  name     = "my-key-ring-${formatdate("YYYY-MM-DD_hh-mm-ss", timestamp())}"
  location = var.region
}

resource "google_kms_crypto_key" "virtual_machines_key" {
  name            = "virtual-machines-key"
  key_ring        = google_kms_key_ring.my_key_ring.id
  rotation_period = "2592000s"
  purpose         = "ENCRYPT_DECRYPT"
  version_template {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }
  lifecycle {
    prevent_destroy = false
  }
  depends_on = [google_kms_key_ring.my_key_ring]
}

resource "google_kms_crypto_key" "cloudsql_instances_key" {
  name            = "cloudsql-instances-key"
  key_ring        = google_kms_key_ring.my_key_ring.id
  rotation_period = "2592000s"
  purpose         = "ENCRYPT_DECRYPT"
  version_template {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }
  lifecycle {
    prevent_destroy = false
  }
  depends_on = [google_kms_key_ring.my_key_ring]
}

resource "google_kms_crypto_key" "cloud_storage_buckets_key" {
  name            = "cloud-storage-buckets-key"
  key_ring        = google_kms_key_ring.my_key_ring.id
  rotation_period = "2592000s"
  purpose         = "ENCRYPT_DECRYPT"
  version_template {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }
  lifecycle {
    prevent_destroy = false
  }
  depends_on = [google_kms_key_ring.my_key_ring]
}

resource "google_project_iam_member" "vm_instance_binding" {
  role       = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  project    = var.project_id
  member     = "serviceAccount:service-208232011006@compute-system.iam.gserviceaccount.com"
  depends_on = [ google_kms_crypto_key.virtual_machines_key]
}

resource "google_project_iam_binding" "sql_kms_binding" {
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  project = var.project_id
  members = ["serviceAccount:service-208232011006@gcp-sa-cloud-sql.iam.gserviceaccount.com"]
  depends_on = [ google_kms_crypto_key.cloudsql_instances_key]
}

resource "google_project_iam_member" "grant-google-storage-service-encrypt-decrypt" {
  role       = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  project    = var.project_id
  member     = "serviceAccount:service-208232011006@gs-project-accounts.iam.gserviceaccount.com"
  depends_on = [ google_kms_crypto_key.cloud_storage_buckets_key]
}

output "storage_kms_key" {
    value = google_kms_crypto_key.cloud_storage_buckets_key
}

output "sql_kms_key" {
    value = google_kms_crypto_key.cloudsql_instances_key
}

output "vm_kms_key" {
    value = google_kms_crypto_key.virtual_machines_key
}