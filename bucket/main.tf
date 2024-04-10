variable region{
    description = "region"
}

variable storage_kms_key{
    description = "storage_kms_key"
}

resource "google_storage_bucket" "my_bucket" {
  name          = "my-bucket-name-para-22339341"
  location      = var.region 
  force_destroy = true
  encryption {
    default_kms_key_name = var.storage_kms_key.id
  }
}

resource "google_storage_bucket_object" "my_zip_file" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.my_bucket.name
  source = "/Users/para/Downloads/function-source.zip"
  depends_on = [google_storage_bucket.my_bucket]
}