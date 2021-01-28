variable "vpc_name" {  
}


resource "google_compute_firewall" "fw_wordpress" {
  name    = "allow-tcp"
  network = var.vpc_name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = [ "103.204.170.238/32" ]
  target_tags = [ "wordpress" ]
}

resource "google_compute_firewall" "fw_db" {
  name    = "allow-tcp-sql"
  network = var.vpc_name
  source_tags = [ "wordpress" ]
  target_tags = [ "db" ]
  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
}