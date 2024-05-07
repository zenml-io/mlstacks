# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

resource "google_storage_bucket" "artifact-store" {
  name     = "${local.prefix}-${local.gcs.name}"
  project  = local.project_id
  location = local.gcs.location

  force_destroy = true

  uniform_bucket_level_access = true
}
