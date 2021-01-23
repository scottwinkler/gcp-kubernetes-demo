locals {
  services = [
    "sourcerepo.googleapis.com",
    "cloudbuild.googleapis.com",
    "container.googleapis.com",
    "run.googleapis.com",
    "iam.googleapis.com",
  ]
}

resource "google_project_service" "enabled_service" {
  for_each = toset(local.services)
  project  = var.project_id
  service  = each.key

  provisioner "local-exec" {
    command = "sleep 60"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sleep 15"
  }
}

module "gke" {
  depends_on = [google_project_service.enabled_service]
  source     = "./modules/gke"
  namespace  = var.namespace
  region     = var.region
}

module "cicd" {
  depends_on   = [google_project_service.enabled_service]
  source       = "./modules/cicd"
  project_id   = var.project_id
  namespace    = var.namespace
  region       = var.region
  cluster_name = module.gke.cluster_name
}
