# create a access role based on service principal created in compute cluster
data "azurerm_client_config" "config" {
  depends_on = [
    azurerm_machine_learning_compute_cluster.cluster
  ]
}

resource "azurerm_role_assignment" "ra" {
  scope                = "/subscriptions/${data.azurerm_client_config.config.subscription_id}/resourceGroups/${azurerm_resource_group.rg.name}"
  role_definition_name = "Owner"
  principal_id         = azurerm_machine_learning_compute_cluster.cluster.identity[0].principal_id
}


resource "azurerm_key_vault_access_policy" "kv-access" {
  key_vault_id = azurerm_key_vault.secret_manager.id
  tenant_id    = azurerm_machine_learning_compute_cluster.cluster.identity[0].tenant_id
  object_id    = azurerm_machine_learning_compute_cluster.cluster.identity[0].principal_id

  key_permissions = [
    "Get", "List", "Create", "Delete", "Update"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete"
  ]

  storage_permissions = [
    "Get", "List", "Set", "Delete", "Update"
  ]
}

resource "azurerm_key_vault_access_policy" "kv-access-user" {
  key_vault_id = azurerm_key_vault.secret_manager.id
  tenant_id    = azurerm_machine_learning_compute_cluster.cluster.identity[0].tenant_id
  object_id    = data.azurerm_client_config.config.object_id

  key_permissions = [
    "Get", "List", "Create", "Delete", "Update"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete"
  ]

  storage_permissions = [
    "Get", "List", "Set", "Delete", "Update"
  ]
}

