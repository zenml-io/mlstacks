output "artifact_store_configuration" {
  value = "gs://${google_storage_bucket.terraform_state.name}"
}
