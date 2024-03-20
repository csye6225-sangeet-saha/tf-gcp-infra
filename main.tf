
provider "google" {
  # credentials = file(var.credentials_file)
  credentials = var.credentials_file
  project     = var.project_id
  region      = var.region
}


resource "random_password" "password" {
  length           = 8
  special          = false
}

resource "random_string" "user_name" {
  length           = 6
  special          = false
}

# Create VPC

resource "google_compute_network" "test_vpc_network" {
    project                 = var.project_id
    name                    = var.vpc_name
    auto_create_subnetworks = false
    routing_mode            = var.routing_mode
    mtu                     = 1460
    delete_default_routes_on_create = true
}

# Create Subnets

resource "google_compute_subnetwork" "webapp_subnet" {
  name          = var.webapp_subnet_name
  ip_cidr_range = var.webapp_subnet_cidr
  region        = var.region
  network       = google_compute_network.test_vpc_network.id
  depends_on = [google_compute_network.test_vpc_network]
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = var.db_subnet_name
  ip_cidr_range = var.db_subnet_cidr
  region        = var.region
  network       = google_compute_network.test_vpc_network.id
  private_ip_google_access = true
  depends_on = [google_compute_network.test_vpc_network]
}

resource "google_compute_route" "webapp_route" {
  name              = "webapp-route"
  network           = google_compute_network.test_vpc_network.id
  dest_range        = "0.0.0.0/0"
  next_hop_gateway  = "default-internet-gateway"  
  depends_on        = [google_compute_subnetwork.webapp_subnet]
}

resource "google_compute_firewall" "webapp_firewall" {
  name    = "webapp-firewall"
  network = google_compute_network.test_vpc_network.name
  direction      = "INGRESS"
  source_ranges  = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = [8080]
  }

  depends_on = [google_compute_subnetwork.webapp_subnet]
}

resource "google_compute_global_address" "default" {
  project      = google_compute_network.test_vpc_network.project
  name         = "private-google-access-ip"
  address_type = "INTERNAL"
  purpose      = "VPC_PEERING"
  prefix_length = 24
  network      = google_compute_network.test_vpc_network.id
  # address      = var.computeGlobalAddress
  depends_on = [google_compute_network.test_vpc_network]
}

resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.test_vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.default.name]
  depends_on = [google_compute_global_address.default]
}

resource "google_sql_database_instance" "cloudsql_instance" {
  name             = "your-cloudsql-instance-name"
  project          = var.project_id
  region           = var.region
  database_version = "MYSQL_8_0"

  settings {
    tier = "db-custom-1-3840"
    disk_size = var.disk_size
    disk_type = var.disk_type
    availability_type = var.availability_type
    ip_configuration {
      ipv4_enabled    = var.ipv4_enabled
      private_network = google_compute_network.test_vpc_network.id
    }
    backup_configuration {
      enabled = true
      binary_log_enabled = true
    }
  }
  deletion_protection = var.deletion_protection

  depends_on = [google_compute_global_address.default, google_service_networking_connection.default]
}

resource "google_sql_database" "testdb" {
  name     = "webapp"
  instance = google_sql_database_instance.cloudsql_instance.name
  depends_on = [google_sql_database_instance.cloudsql_instance]
}

resource "google_sql_user" "test_user" {
  name     = join("-", ["test",random_string.user_name.result])
  instance = google_sql_database_instance.cloudsql_instance.name
  password = random_password.password.result
  depends_on = [google_sql_database_instance.cloudsql_instance]
}

resource "google_service_account" "logging_service_account" {
  account_id   = "logging-service-account"
  display_name = "Logging Service Account"
}

resource "google_project_iam_binding" "logging_admin_binding" {
  project = var.project_id
  role    = "roles/logging.admin"
  members = [
    "serviceAccount:${google_service_account.logging_service_account.email}",
  ]
  depends_on = [google_service_account.logging_service_account]
}

resource "google_project_iam_binding" "metric_writer_binding" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  members = [
    "serviceAccount:${google_service_account.logging_service_account.email}",
  ]
  depends_on = [google_project_iam_binding.logging_admin_binding]
}

module "compute" {
  source = "./compute"
  zone = var.zone
  subnetwork_name = google_compute_subnetwork.webapp_subnet.self_link
  db_name = google_sql_database.testdb.name
  db_user = google_sql_user.test_user.name
  db_password = google_sql_user.test_user.password
  db_ip = google_sql_database_instance.cloudsql_instance.private_ip_address
  service_account = google_service_account.logging_service_account.email
  depends_on = [google_sql_user.test_user, google_sql_database.testdb, google_sql_database_instance.cloudsql_instance,
    google_project_iam_binding.metric_writer_binding]
}

locals {
  vm_ip_address = module.compute.vm_ip_address
  depends_on = [module.compute]
}

# resource "google_dns_managed_zone" "my_zone" {
#   name        = "my-zone"
#   dns_name    = "paracloud.site."
#   description = "Managed by Terraform"
#   depends_on = [module.compute]
# }

resource "google_dns_record_set" "my_record" {
  name    = "paracloud.site."
  type    = "A"
  ttl     = 300
  managed_zone = "sangeet-dns-zone"
  rrdatas = [local.vm_ip_address]
  depends_on =  [module.compute]
}


