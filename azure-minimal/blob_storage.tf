resource "azurerm_storage_account" "zenml-account" {
  name                     = "${local.prefix}${local.blob_storage.account_name}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

resource "azurerm_storage_container" "artifact-store" {
  name                  = "${local.prefix}-${local.blob_storage.container_name}"
  storage_account_name  = azurerm_storage_account.zenml-account.name
  container_access_type = "private"
}

data "azurerm_storage_account" "zenml-account" {
  name                = azurerm_storage_account.zenml-account.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "storage" {
  name                 = "aks-storage-access"
  scope                = azurerm_storage_account.zenml-account.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}