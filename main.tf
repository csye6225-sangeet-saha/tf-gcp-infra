
provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}

# Create VPC

resource "google_compute_network" "test_vpc_network" {
    project                 = var.project_id
    name                    = var.vpc_name
    auto_create_subnetworks = false
    routing_mode            = "REGIONAL"
    mtu                     = 1460
}

# Create Subnets

resource "google_compute_subnetwork" "webapp_subnet" {
  name          = "webapp-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.test_vpc_network.id
  depends_on = [google_compute_network.test_vpc_network]
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = "db-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.test_vpc_network.id
  depends_on = [google_compute_network.test_vpc_network]
}

resource "google_compute_route" "webapp_route" {
  name              = "webapp-route"
  network           = google_compute_network.test_vpc_network.id
  dest_range        = "0.0.0.0/0"
  next_hop_gateway  = "default-internet-gateway"  
  depends_on        = [google_compute_subnetwork.webapp_subnet]
}