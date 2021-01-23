# Kubernetes Deployment with Anthos and CI/CD on GCP
This Terraform module deploys an Anthos Kubernetes cluster on GCP and sets up a Cloud Build pipeline for deploying "serverless" Cloud Run containers onto it.

## Prerequisites
You will need to create a GCP project, link a billing account to it, create a service account, download credentials for that service account, and enable a few APIs. This is needed by Terraform in order to deploy resources into your account. The `bootstrap.sh` file makes this process easier. Simply run:

```
./bootstrap.sh  <project name>
```
Your credentials will be saved as `accounts.json`. Make sure this is in your root module, because its referenced by the provider configuration.

This module also makes use of some local-exec commands, since the GCP provider has limited support for Cloud Run. You will need the following packages installed on your local machine:
* kubectl
* gcloud
* jq


## Deploy
The only required variable is `var.project_id`. Set this to your project id. To deploy, first perform a `terraform init` followed by `terraform apply`

Your output after deploying will contain two URLs that you will need for the CI/CD process:

```
...
module.gke.google_container_node_pool.primary_preemptible_nodes: Still creating... [40s elapsed]
module.gke.google_container_node_pool.primary_preemptible_nodes: Still creating... [50s elapsed]
module.gke.google_container_node_pool.primary_preemptible_nodes: Still creating... [1m0s elapsed]
module.gke.google_container_node_pool.primary_preemptible_nodes: Creation complete after 1m5s [id=projects/kubernetes-demo-302609/locations/us-central1/clusters/hellworld-demo-gke-cluster/nodePools/hellworld-demo-node-pool]

Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:

urls = {
  "app"  = "http://helloworld.default.34.122.239.7.xip.io/helloworld"
  "repo" = "https://source.developers.google.com/p/kubernetes-demo-302609/r/hellworld-demo-repo"
}
```

## Kick Off CI/CD
For the Cloud Run service to be deployed, you have to  push the code to Cloud Source. First switch into the src/docker folder:

```
cd ./src/docker
```

Then run the following commands to initialize the Git repo and push changes to GCP:

```
git init && git add -A && git commit -m "initial push"
git config --global credential.https://source.developers.google.com.helper gcloud.sh
git remote add google <urls.repo value from Terraform output>
gcloud auth login && git push --all google
```

Once Cloud Build finishes running, your service will be avalable at `urls.app`, for example: `http://helloworld.default.34.122.239.7.xip.io/helloworld`

