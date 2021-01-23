variable "region" {
  description = "The region to host the cluster in"
  default     = "us-central1"
}

variable "project_id" {
  description = "The GCP project id to deploy into"
  default     = "kubernetes-demo-302609"
}

variable "namespace" {
  description = "a unique project namespace"
  default     = "hellworld-demo"
}