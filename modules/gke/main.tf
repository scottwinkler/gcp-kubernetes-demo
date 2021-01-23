resource "google_container_cluster" "primary" {
  provider                 = google-beta
  name                     = "${var.namespace}-gke-cluster"
  location                 = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  addons_config {
    cloudrun_config {
      disabled = false
    }
    istio_config {
      disabled = false
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "${var.namespace}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n2-standard-2"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",

    ]
  }
}