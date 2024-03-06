# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

locals {
  enable_vertex = (var.enable_step_operator_vertex || var.enable_orchestrator_vertex)
}

# workload service account for Vertex pipelines
resource "google_service_account" "sa" {
  count = local.enable_vertex ? 1 : 0

  account_id   = "${local.prefix}-${local.vertex.service_account_id}"
  project      = var.project_id
  display_name = "${local.prefix}-${local.vertex.service_account_id}"
}

# creating a sa key
resource "google_service_account_key" "vertex_sa_key" {
  count = local.enable_vertex ? 1 : 0

  service_account_id = google_service_account.sa[0].name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# create the credentials file JSON
resource "local_file" "sa_key_file" {
  count    = local.enable_vertex ? 1 : 0
  content  = base64decode(google_service_account_key.vertex_sa_key[0].private_key)
  filename = "./vertex_sa_key.json"
}

locals {
  roles_to_grant_to_custom_service_account = local.enable_vertex ? [
    "roles/aiplatform.customCodeServiceAgent",
    "roles/aiplatform.serviceAgent",
    "roles/containerregistry.ServiceAgent",
    "roles/secretmanager.admin",
    "roles/iam.serviceAccountUser"
  ] : []
}

resource "google_project_iam_member" "roles-custom-sa" {
  project = var.project_id

  for_each = toset(local.roles_to_grant_to_custom_service_account)
  role     = each.value
  member   = "serviceAccount:${google_service_account.sa[0].email}"
}


# create custom code service agent by triggering a dummy run
resource "null_resource" "vertex-dummy-run" {
  count = local.enable_vertex ? 1 : 0

  provisioner "local-exec" {
    command = "gcloud beta ai custom-jobs create --display-name dummy --region ${var.region} --worker-pool-spec=replica-count=1,machine-type=e2-standard-4,container-image-uri=gcr.io/google-appengine/python --project ${var.project_id}"
  }

  depends_on = [
    google_project_service.vertex_ai
  ]
}
# add iam policy binding
resource "null_resource" "add-admin-policy-cc" {
  count = local.enable_vertex ? 1 : 0

  provisioner "local-exec" {
    command = "gcloud iam service-accounts add-iam-policy-binding --role=roles/iam.serviceAccountAdmin --member=serviceAccount:service-${data.google_project.project[0].number}@gcp-sa-aiplatform-cc.iam.gserviceaccount.com ${google_service_account.sa[0].email} --project ${var.project_id}"
  }

  depends_on = [
    null_resource.vertex-dummy-run
  ]
}
# add permissions to the service agent
locals {
  roles_to_grant_to_service_agent = local.enable_vertex ? [
    "roles/aiplatform.customCodeServiceAgent",
    "roles/aiplatform.serviceAgent",
    "roles/containerregistry.ServiceAgent",
    "roles/secretmanager.admin",
  ] : []
}
resource "google_project_iam_member" "roles-service-agent-cc" {
  project = var.project_id

  for_each = toset(local.roles_to_grant_to_service_agent)
  role     = each.value

  member = "serviceAccount:service-${data.google_project.project[0].number}@gcp-sa-aiplatform-cc.iam.gserviceaccount.com"

  depends_on = [
    null_resource.vertex-dummy-run,
    google_service_account.sa
  ]
}


# get service agent for Vertex
resource "null_resource" "get-vertex-agent" {
  count = local.enable_vertex ? 1 : 0

  provisioner "local-exec" {
    command = "gcloud beta services identity create --service aiplatform.googleapis.com --project ${var.project_id}"
  }
}
# add iam policy binding
resource "null_resource" "add-admin-policy" {
  count = local.enable_vertex ? 1 : 0

  provisioner "local-exec" {
    command = "gcloud iam service-accounts add-iam-policy-binding --role=roles/iam.serviceAccountAdmin --member=serviceAccount:service-${data.google_project.project[0].number}@gcp-sa-aiplatform.iam.gserviceaccount.com ${google_service_account.sa[0].email} --project ${var.project_id}"
  }

  depends_on = [
    null_resource.get-vertex-agent
  ]
}
# add permissions to the service agent
resource "google_project_iam_member" "roles-service-agent" {
  project = var.project_id

  for_each = toset(local.roles_to_grant_to_service_agent)
  role     = each.value

  member = "serviceAccount:service-${data.google_project.project[0].number}@gcp-sa-aiplatform.iam.gserviceaccount.com"

  depends_on = [
    null_resource.get-vertex-agent,
    google_service_account.sa
  ]
}
