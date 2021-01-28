resource "google_compute_network" "vpc_network" {
  name = "vpc-network"
  mtu  = 1500
  project = "grand-signifier-282707"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public_subnet" {
  depends_on = [ google_compute_network.vpc_network ]
  name          = "app-subnet1"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "private_subnet" {
  depends_on = [ google_compute_network.vpc_network ]
  name          = "db-subnet1"
  ip_cidr_range = "10.3.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  depends_on = [ google_compute_network.vpc_network ]
  name    = "my-router"
  region  = google_compute_subnetwork.private_subnet.region
  network = google_compute_network.vpc_network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  depends_on = [ google_compute_router.router ]
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


