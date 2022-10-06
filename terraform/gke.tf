data "google_client_config" "this" {}

resource "google_container_cluster" "primary" {
    name = var.name
    location = data.google_client_config.this.region
    initial_node_count = 3

    node_config {
        machine_type = "e2-medium"
        disk_size_gb = 50
    }

    workload_identity_config {
        workload_pool = "${data.google_client_config.this.project}.svc.id.goog"
    }

    # tags = ["flux", "gitops", "observability"]
}

module "gke_auth" {
    source = "terraform-google-modules/kubernetes-engine/google//modules/auth"
    version = "~>21"

    project_id = data.google_client_config.this.project
    cluster_name = var.name
    location     = data.google_client_config.this.region

    depends_on = [google_container_cluster.primary]
}

resource "google_service_account" "service_account" {
    account_id = var.service_account_name
    display_name = var.service_account_name
}


resource "google_project_iam_binding" "gcr" {
  project = data.google_client_config.this.project
  role    = "roles/containerregistry.ServiceAgent"

  members = [
    "serviceAccount:${resource.google_service_account.service_account.email}",
  ]
}

resource "google_service_account_iam_binding" "k8s" {
  service_account_id = google_service_account.service_account.name
  role    = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${data.google_client_config.this.project}.svc.id.goog[${var.namespace}/${var.k8s_serviceaccount}]",
  ]
}

