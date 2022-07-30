resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "${local.prefix}-${local.mysql.name}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = var.metadata-db-username
  administrator_password = var.metadata-db-password == "" ? random_password.mysql_password : var.metadata-db-password
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.mysql_vnet.id

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