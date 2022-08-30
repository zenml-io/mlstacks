module "metadata_store" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/mysql"
  version = "11.0.0"

  project_id       = local.project_id
  name             = "${local.prefix}-${local.cloudsql.name}"
  database_version = "MYSQL_8_0"
  region           = local.region
  zone             = "${local.region}-c"

  user_name     = var.metadata-db-username
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

# create the client certificate for CloudSQL
resource "google_sql_ssl_cert" "client_cert" {
  common_name = "sql-cert"
  instance    = module.metadata_store.instance_name
}

# create the certificate files
resource "local_file" "server-ca" {
  content  = google_sql_ssl_cert.client_cert.server_ca_cert
  filename = "./server-ca.pem"
}
resource "local_file" "client-cert" {
  content  = google_sql_ssl_cert.client_cert.cert
  filename = "./client-cert.pem"
}
resource "local_file" "client-key" {
  content  = google_sql_ssl_cert.client_cert.private_key
  filename = "./client-key.pem"
}