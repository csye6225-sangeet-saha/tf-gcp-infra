
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

resource "google_compute_region_instance_template" "web_instance_template" {
  name = "web-instance-template"
  
  disk {
    source_image = "projects/csye-6225-dev-415015/global/images/mysql-node-custom-image-2"
    type  = "pd-balanced"
  }

  machine_type = "e2-small"
  
  network_interface {
    subnetwork = var.subnetwork_name
    access_config {
      network_tier = "PREMIUM"
    }

  }

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

  service_account {
    email  = var.service_account
    scopes = ["https://www.googleapis.com/auth/cloud-platform","https://www.googleapis.com/auth/pubsub"]
  }

  labels = {
    goog-ec-src = "vm_add-tf"
  }
}

resource "google_compute_http_health_check" "web_health_check" {
  name               = "web-health-check"
  check_interval_sec = 15
  timeout_sec        = 15
  port               = 8080
  request_path       = "/healthz"
}

resource "google_compute_region_instance_group_manager" "web_instance_group_manager" {
  name             = "web-instance-group-manager"
  base_instance_name = "web-instance"
  target_size      = 1
  # zone             = var.zone

  version {
    name         = "instance-template"
    instance_template = google_compute_region_instance_template.web_instance_template.self_link
  }

  auto_healing_policies {
    health_check = google_compute_http_health_check.web_health_check.self_link
    initial_delay_sec = 60
  }

  named_port {
    name = "http"
    port = 8080
  }
}

resource "google_compute_region_autoscaler" "web_autoscaler" {
  name               = "web-autoscaler"
  target = google_compute_region_instance_group_manager.web_instance_group_manager.self_link
  # zone             = var.zone

  autoscaling_policy {
    max_replicas    = 10
    min_replicas    = 1
    cooldown_period = 150

    cpu_utilization {
      target = 0.05
    }
  }
}



# output "vm_ip_address" {
#   description = "VM Internal IP Address"
#   value       = google_compute_instance_group_manager.web_instance_group_manager.instance_group.network_interface[0].access_config[0].nat_ip
# }

resource "google_compute_managed_ssl_certificate" "lb_default" {
  provider = google
  name     = "myservice-ssl-cert"

  managed {
    domains = ["paracloud.site"]
  }
}

resource "google_compute_target_https_proxy" "my_proxy" {
  name    = "my-target-http-proxy"
  url_map = google_compute_url_map.my_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.lb_default.self_link]
}


resource "google_compute_global_forwarding_rule" "my_lb" {
  name       = "my-load-balancer"
  target     = google_compute_target_https_proxy.my_proxy.self_link
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range = "443"
}

resource "google_compute_url_map" "my_map" {
  name            = "my-url-map"
  default_service = google_compute_backend_service.my_service.self_link
}

resource "google_compute_backend_service" "my_service" {
  name             = "my-backend-service"
  health_checks    = [google_compute_http_health_check.web_health_check.self_link]
  protocol         = "HTTP"
  timeout_sec      = 10
  load_balancing_scheme = "EXTERNAL_MANAGED"
  locality_lb_policy    = "ROUND_ROBIN"

  backend {
    group = google_compute_region_instance_group_manager.web_instance_group_manager.instance_group
  }
}


output "load_balancer_ip" {
  description = "Load Balancer IP Address"
  value       = google_compute_global_forwarding_rule.my_lb.ip_address
  depends_on = [google_compute_global_forwarding_rule.my_lb]
}
