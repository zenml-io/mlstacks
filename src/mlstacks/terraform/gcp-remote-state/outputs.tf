output "bucket_url" {
  value = "gs://${google_storage_bucket.terraform_state.name}"
}
