module "metadata_store" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/mysql"
  version = "11.0.0"

  project_id = local.project_id
  name = "${local.prefix}-${local.cloudsql.name}"
  database_version = "8.0.26"
  region = local.region

  user_name = var.metadata-db-username
  user_password = var.metadata-db-password

  deletion_protection = false

  ip_configuration = {
    authorized_networks = local.cloudsql.authorized_networks
    ipv4_enabled        = true
    private_network     = null
    require_ssl         = local.cloudsql.require_ssl
    allocated_ip_range  = null
  }
}