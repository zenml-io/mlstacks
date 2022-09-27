data "azurerm_client_config" "current" {
  depends_on = [azurerm_resource_group.rg]

}

# workspace application insights
resource "azurerm_application_insights" "ai" {
  name                = "${local.prefix}-${local.azureml.cluster_name}-ai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# workspace keyvault
resource "azurerm_key_vault" "secret_manager" {
  name                        = local.key_vault.name
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

# workspace storage account
resource "azurerm_storage_account" "zenml-account" {
  name                     = "${local.prefix}${local.blob_storage.account_name}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

# workspace storage container
resource "azurerm_storage_container" "artifact-store" {
  name                  = "${local.prefix}-${local.blob_storage.container_name}"
  storage_account_name  = azurerm_storage_account.zenml-account.name
  container_access_type = "private"
}

# workspace
resource "azurerm_machine_learning_workspace" "mlw" {
  name                    = "${local.prefix}-${local.azureml.cluster_name}-mlw"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  application_insights_id = azurerm_application_insights.ai.id
  key_vault_id            = azurerm_key_vault.secret_manager.id
  storage_account_id      = azurerm_storage_account.zenml-account.id

  identity {
    type = "SystemAssigned"
  }
}

# virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.prefix}-${local.azureml.cluster_name}-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${local.prefix}-${local.azureml.cluster_name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.0.0/24"]
}

# workspace compute cluster
resource "azurerm_machine_learning_compute_cluster" "cluster" {
  name                          = "${local.prefix}-${local.azureml.cluster_name}"
  location                      = azurerm_resource_group.rg.location
  vm_priority                   = "LowPriority"
  vm_size                       = "Standard_DS2_v2"
  machine_learning_workspace_id = azurerm_machine_learning_workspace.mlw.id
  subnet_resource_id            = azurerm_subnet.subnet.id

  scale_settings {
    min_node_count                       = 0
    max_node_count                       = 1
    scale_down_nodes_after_idle_duration = "PT30S" # 30 seconds
  }

  identity {
    type = "SystemAssigned"
  }
}
