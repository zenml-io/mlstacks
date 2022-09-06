# service account for storage access
resource "google_service_account" "storage_sa" {
  account_id   = local.service_account.account_id
  project      = local.project_id
  display_name = "${local.prefix}-${local.service_account.account_id}"
}

locals {
  roles_to_grant_to_storage_service_account = [
    "roles/iam.serviceAccountTokenCreator",
    "roles/storage.admin"   
  ]
}

resource "google_project_iam_member" "roles-sa" {
  project = local.project_id

  member   = "serviceAccount:${google_service_account.storage_sa.email}"
  for_each = toset(local.roles_to_grant_to_storage_service_account)
  role     = each.value
}

# creating a sa key
resource "google_service_account_key" "storage_sa_key" {
  service_account_id = google_service_account.storage_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# create the credentials file JSON
resource "local_file" "sa_key_file" {
  content  = base64decode(google_service_account_key.storage_sa_key.private_key)
  filename = "./ls-annotation-credentials.json"
}