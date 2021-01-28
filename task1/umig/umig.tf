resource "google_compute_instance_group" "webservers" {
  depends_on = [  google_compute_instance.wp_instance1 , google_compute_instance.wp_instance2 ]
  name        = "umig1"
  description = "Terraform test instance group"

  instances = [
    google_compute_instance.instance1.id,
    google_compute_instance.instance2.id,
    google_compute_instance.db_instance1.id
  ]

  named_port {
    name = "http"
    port = "8080"
  }

  named_port {
    name = "https"
    port = "8443"
  }

  zone = "us-central1-a"
}