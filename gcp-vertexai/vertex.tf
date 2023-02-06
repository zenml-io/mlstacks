# workload service account for Vertex pipelines
resource "google_service_account" "sa" {
  account_id   = "${local.prefix}-${local.service_account.account_id}"
  project      = local.project_id
  display_name = "${local.prefix}-${local.service_account.account_id}"
}

locals {
  roles_to_grant_to_custom_service_account = [
    "roles/aiplatform.customCodeServiceAgent",
    "roles/aiplatform.serviceAgent",
    "roles/containerregistry.ServiceAgent",
    "roles/secretmanager.admin",
    "roles/iam.serviceAccountUser"
  ]
}

resource "google_project_iam_member" "roles-custom-sa" {
  project = local.project_id

  member   = "serviceAccount:${google_service_account.sa.email}"
  for_each = toset(local.roles_to_grant_to_custom_service_account)
  role     = each.value
}


# create custom code service agent by trigerring a dummy run
resource "null_resource" "vertex-dummy-run" {
  provisioner "local-exec" {
    command = "gcloud beta ai custom-jobs create --display-name dummy --region ${local.region} --worker-pool-spec=replica-count=1,machine-type=e2-standard-4,container-image-uri=gcr.io/google-appengine/python --project ${local.project_id}"
  }

  depends_on = [
    google_project_service.vertex_ai
  ]
}
# add iam policy binding
resource "null_resource" "add-admin-policy-cc" {
  provisioner "local-exec" {
    command = "gcloud iam service-accounts add-iam-policy-binding --role=roles/iam.serviceAccountAdmin --member=serviceAccount:service-${data.google_project.project.number}@gcp-sa-aiplatform-cc.iam.gserviceaccount.com ${google_service_account.sa.email} --project ${local.project_id}"
  }

  depends_on = [
    null_resource.vertex-dummy-run
  ]
}
# add permissions to the service agent
locals {
  roles_to_grant_to_service_agent = [
    "roles/aiplatform.customCodeServiceAgent",
    "roles/aiplatform.serviceAgent",
    "roles/containerregistry.ServiceAgent",
    "roles/secretmanager.admin",
  ]
}
resource "google_project_iam_member" "roles-service-agent-cc" {
  project = local.project_id

  member   = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-aiplatform-cc.iam.gserviceaccount.com"
  for_each = toset(local.roles_to_grant_to_service_agent)
  role     = each.value

  depends_on = [
    null_resource.vertex-dummy-run
  ]
}


# get service agent for Vertex
resource "null_resource" "get-vertex-agent" {
  provisioner "local-exec" {
    command = "gcloud beta services identity create --service aiplatform.googleapis.com --project ${local.project_id}"
  }
}
# add iam policy binding
resource "null_resource" "add-admin-policy" {
  provisioner "local-exec" {
    command = "gcloud iam service-accounts add-iam-policy-binding --role=roles/iam.serviceAccountAdmin --member=serviceAccount:service-${data.google_project.project.number}@gcp-sa-aiplatform.iam.gserviceaccount.com ${google_service_account.sa.email} --project ${local.project_id}"
  }

  depends_on = [
    null_resource.get-vertex-agent
  ]
}
# add permissions to the service agent
resource "google_project_iam_member" "roles-service-agent" {
  project = local.project_id

  member   = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-aiplatform.iam.gserviceaccount.com"
  for_each = toset(local.roles_to_grant_to_service_agent)
  role     = each.value

  depends_on = [
    null_resource.get-vertex-agent
  ]
}
