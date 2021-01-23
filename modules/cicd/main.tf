resource "google_sourcerepo_repository" "repo" {
  provider = google
  name     = "${var.namespace}-repo"
}

locals {
  image = "gcr.io/${var.project_id}/${var.namespace}"
  steps = [
    {
      name = "gcr.io/cloud-builders/go"
      args = ["test"]
      env  = ["PROJECT_ROOT=${var.namespace}"]
    },
    {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", local.image, "."]
    },
    {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", local.image]
    },
    {
      name = "gcr.io/cloud-builders/gcloud"
      args = ["run", "deploy", "helloworld", "--image", local.image, "--cluster-location", var.region, "--cluster", var.cluster_name, "--platform", "gke", "-q"]
    }

  ]
}

resource "google_cloudbuild_trigger" "trigger" {
  trigger_template {
    branch_name = "master"
    repo_name   = google_sourcerepo_repository.repo.name
  }

  build {
    dynamic "step" {
      for_each = local.steps
      content {
        name = step.value.name
        args = step.value.args
        env  = lookup(step.value, "env", null)
      }
    }
  }
}

data "google_project" "project" {}

resource "google_project_iam_member" "cloudbuild_roles" {
  for_each = toset(["roles/run.admin", "roles/iam.serviceAccountUser", "roles/container.admin"])
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

data "shell_script" "domain_name" {
  lifecycle_commands {
    read = <<-EOF
      sleep 30
      gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT_ID
      external_ip=$(kubectl get svc istio-ingressgateway -n istio-system -o json | jq -r '.status.loadBalancer.ingress[0].ip')
      domain_name="$external_ip.xip.io"
      echo '{"domain_name": "'"$domain_name"'"}'
    EOF
  }

  environment = {
    CLUSTER_NAME = var.cluster_name
    REGION       = var.region
    PROJECT_ID   = var.project_id
  }
}

resource "shell_script" "cluster_domain_mapping" {
  lifecycle_commands {
    create = <<-EOF
      kubectl patch configmap config-domain --namespace knative-serving --patch '{"data": {"example.com": null, "'"$DOMAIN_NAME"'": ""}}'
    EOF

    delete = <<-EOF
      kubectl patch configmap config-domain --namespace knative-serving --patch '{"data": {"example.com": null, "'"$DOMAIN_NAME"'": null}}'
    EOF
  }

  environment = {
    CLUSTER_NAME = var.cluster_name
    REGION       = var.region
    PROJECT_ID   = var.project_id
    DOMAIN_NAME  = data.shell_script.domain_name.output["domain_name"]
  }
}
