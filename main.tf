#script para subir um serviço do cloud-run via terraform

provider "google" {
  project = "ageless-span-399117"
  region  = "us-central1"
}

resource "google_cloud_run_service" "default" {
  name     = "dokuwiki-teste"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/pintang-infra-lab/dokuwiki"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  service  = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

