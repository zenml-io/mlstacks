# The URI of the Apache Airflow Web UI hosted within this environment
output "airflow-uri" {
  value = "https://${aws_mwaa_environment.mwaa.webserver_url}"
}

# output for s3 bucket
output "s3-bucket-path" {
  value       = "s3://${aws_s3_bucket.store.bucket}"
  description = "The S3 bucket path for storing your artifacts"
}

# output for container registry
output "container-registry-URI" {
  value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com"
}

# output the name of the stack YAML file created
output "stack-yaml-path" {
  value = local_file.stack_file.filename
}
  