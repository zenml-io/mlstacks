# create a access role based on service principal created in compute cluster
data "azurerm_client_config" "current" {
}

resource "azurerm_role_assignment" "ra" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.rg.name}"
  role_definition_name = "Owner"
  principal_id         = azurerm_machine_learning_compute_cluster.cluster.identity.principal_id
}
