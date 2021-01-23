// can also set credentials path using environment variable
// export GOOGLE_CREDENTIALS="./account.json"
provider "google" {
  credentials = file("${path.module}/account.json")
  project     = var.project_id
  region      = var.region
}

provider "google-beta" {
  credentials = file("${path.module}/account.json")
  project     = var.project_id
  region      = var.region
}