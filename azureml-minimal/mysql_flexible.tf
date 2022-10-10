resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "${local.prefix}-${local.mysql.name}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = var.metadata-db-username
  administrator_password = var.metadata-db-password == "" ? random_password.mysql_password.result : var.metadata-db-password
  backup_retention_days  = 7
  sku_name               = "B_Standard_B1s"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_IPs" {
  name                = "all_traffic"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

resource "random_password" "mysql_password" {
  length  = 12
  special = false
}

# download SSL certificate
resource "null_resource" "download-SSL-certificate" {
  provisioner "local-exec" {
    command = "wget https://dl.cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem"
  }

}
