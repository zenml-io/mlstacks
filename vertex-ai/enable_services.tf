data "google_project" "project" {
  project_id = local.project_id
}

resource "null_resource" "enable-vertexai" {
  provisioner "local-exec" {
    command = "gcloud services enable aiplatform.googleapis.com --project=${local.project_id}"
  }
}

resource "null_resource" "enable-secretmanager" {
  provisioner "local-exec" {
    command = "gcloud services enable secretmanager.googleapis.com --project=${local.project_id}"
  }
}

resource "null_resource" "enable-containerregistry" {
  provisioner "local-exec" {
    command = "gcloud services enable containerregistry.googleapis.com --project=${local.project_id}"
  }
}

# resource "null_resource" "enable-artifactregistry" {
#   provisioner "local-exec" {
#     command = "gcloud services enable artifactregistry.googleapis.com --project=${local.project_id}"
#   }
# }

