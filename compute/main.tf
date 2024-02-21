# resource "google_project_service" "compute" {
#   project = var.project_id
#   service = "compute.googleapis.com"

#   timeouts {
#     create = "30m"
#     update = "40m"
#   }

#   disable_dependent_services = true
# }

variable "subnetwork_name" {
  description = "Subnet name"
}

resource "google_compute_instance" "instance-20240220-172051" {
  boot_disk {
    auto_delete = true
    device_name = "instance-20240220-172051"

    initialize_params {
      image = "projects/csye-6225-001/global/images/mysql-node-custom-image"
        #put your image name = "projects/csye-6225-001/global/images/mysql-node-custom-image"
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "custom-1-1024"
  name         = "instance-20240220-172051"
  project      = "csye-6225-001"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    # queue_count = 0
    # stack_type  = "IPV4_ONLY"
    subnetwork  = var.subnetwork_name
  }

  # scheduling {
  #   automatic_restart   = true
  #   on_host_maintenance = "MIGRATE"
  #   preemptible         = false
  #   provisioning_model  = "STANDARD"
  # }

  service_account {
    email  = "sangeet-csye-6225@csye-6225-001.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  # shielded_instance_config {
  #   enable_integrity_monitoring = true
  #   enable_secure_boot          = false
  #   enable_vtpm                 = true
  # }

  zone = "us-east4-c"
  allow_stopping_for_update = true
}
