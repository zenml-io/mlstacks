# resource "random_string" "sa_id" {
#   length           = 6
#   special          = false
# }

# resource "google_service_account" "sa" {
#   account_id   = random_string.sa_id
#   display_name = "A service account for ZenML GKE cluster"
# }

# resource "google_service_account_iam_binding" "storage-admin-iam" {
#   service_account_id = google_service_account.sa.name
#   role               = "roles/iam.serviceAccountUser"

#   members = [
#     "user:jane@example.com",
#   ]
# }