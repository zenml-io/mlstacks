module "cloudsql" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/mysql"
  version = "11.0.0"

  project_id       = var.project_id
  name             = var.name
  db_name          = var.database
  database_version = var.mysql_version
  disk_size        = var.disk_size
  tier             = var.instance_tier
  region           = var.region
  zone             = "${var.region}-c"

  user_name     = var.database_username
  user_password = var.database_password

  deletion_protection = false

  ip_configuration = {
    authorized_networks = [
      {
        name  = "all",
        value = "0.0.0.0/0"
      }
    ]
    ipv4_enabled       = true
    private_network    = null
    require_ssl        = true
    allocated_ip_range = null
  }
}

# create the client certificate for CloudSQL
resource "google_sql_ssl_cert" "client_cert" {
  common_name = "sql-cert"
  instance    = module.metadata_store[0].instance_name
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