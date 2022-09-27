# create a access role based on service principal created in compute cluster
data "azurerm_client_config" "current" {
}

resource "azurerm_role_assignment" "ra" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.rg.name}"
  role_definition_name = "Owner"
  principal_id         = azurerm_machine_learning_compute_cluster.cluster.identity.principal_id
}


resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = azurerm_key_vault.secrets_manager.id
  tenant_id    = azurerm_machine_learning_compute_cluster.cluster.identity.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "List", "Create", "Delete", "Update"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Update"
  ]

  storage_permissions = [
    "Get", "List", "Set", "Delete", "Update"
  ]
}
