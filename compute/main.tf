
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

variable "zone" {
  description = "zone"
}

variable service_account {
  description = "Service account name"
}


resource "google_compute_instance" "instance-20240221-210326" {
  boot_disk {
    auto_delete = true
    device_name = "instance-20240221-210326"

    initialize_params {
      # image = "projects/debian-cloud/global/images/debian-12-bookworm-v20240213"
      image = "projects/csye-6225-dev-415015/global/images/mysql-node-custom-image-2"
      
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "e2-standard-4"
  name         = "instance-20240221-210326"
  project      = "csye-6225-dev-415015"

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
    # email  = "sangeet-dev@csye-6225-dev-415015.iam.gserviceaccount.com"
    # scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    email = var.service_account
    scopes = ["https://www.googleapis.com/auth/cloud-platform","https://www.googleapis.com/auth/pubsub"]
  }

  # shielded_instance_config {
  #   enable_integrity_monitoring = true
  #   enable_secure_boot          = false
  #   enable_vtpm                 = true
  # }

  metadata = {
    startup-script = <<-EOT
    #!/bin/bash
    cat <<EOF > /opt/csye6225/app/.env
    DATABASE=${var.db_name}
    USERNAME=${var.db_user}
    PASSWORD=${var.db_password}
    HOST=${var.db_ip}
    EOF

    chown csye6225:csye6225 /opt/csye6225/app/.env

    EOF

    EOT
  }

  # cat << EOF > /etc/google-cloud-ops-agent/config.yaml
  #   logging:
  #     receivers:
  #       my-app-receiver:
  #         type: files
  #         include_paths:
  #           - /var/log/webapp/application.log
  #         record_log_file_path: true
  #     processors:
  #       my-app-processor:
  #         type: parse_json
  #         time_key: time
  #         time_format: "%Y-%m-%dT%H:%M:%S.%L%Z"
  #       move_severity:
  #         type: modify_fields
  #         fields:
  #           severity:
  #             move_from: jsonPayload.level
  #             map_values:
  #               INFO: "info"
  #               ERROR: "error"
  #               WARNING: "warn"
  #               DEBUG: "debug"
          
  #     service:
  #       pipelines:
  #         default_pipeline:
  #           receivers: [my-app-receiver]
  #           processors: [my-app-processor,move_severity]
  #   EOF

  #   sudo systemctl restart google-cloud-ops-agent

  zone = var.zone

  allow_stopping_for_update = true

}

output "vm_ip_address" {
    description = "VM Internal IP Address"
    value = google_compute_instance.instance-20240221-210326.network_interface[0].access_config[0].nat_ip
    depends_on = [google_compute_instance.instance-20240221-210326]
  }