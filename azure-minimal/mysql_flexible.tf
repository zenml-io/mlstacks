resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "${local.prefix}-${local.mysql.name}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = var.metadata-db-username
  administrator_password = var.metadata-db-password == "" ? random_password.mysql_password.result : var.metadata-db-password
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.mysql_vnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql_dns.id
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

resource "azurerm_private_dns_zone" "mysql_dns" {
  name                = "zenml.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "mysqllink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql_dns.name
  virtual_network_id    = module.network.vnet_id
}