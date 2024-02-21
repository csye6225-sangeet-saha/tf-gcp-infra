
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
    routing_mode            = var.routing_mode
    mtu                     = 1460
    delete_default_routes_on_create = true
}

# Create Subnets

resource "google_compute_subnetwork" "webapp_subnet" {
  name          = var.webapp_subnet_name
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.test_vpc_network.id
  depends_on = [google_compute_network.test_vpc_network]
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = var.db_subnet_name
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

resource "google_compute_firewall" "webapp_firewall" {
  name    = "webapp-firewall"
  network = google_compute_network.test_vpc_network.name
  direction      = "INGRESS"
  source_ranges  = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  depends_on = [google_compute_subnetwork.webapp_subnet]
}


module "compute" {
  source = "./compute"
  subnetwork_name = google_compute_subnetwork.webapp_subnet.self_link
}

