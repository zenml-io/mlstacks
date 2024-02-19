# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

resource "google_storage_bucket" "artifact-store" {
  count    = var.enable_artifact_store ? 1 : 0
  name     = "${local.prefix}-${local.gcs.name}"
  project  = var.project_id
  location = var.region

  force_destroy = true

  uniform_bucket_level_access = true
}
