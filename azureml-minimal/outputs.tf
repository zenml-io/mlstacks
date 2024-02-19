# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# subscription id
output "subscription-id" {
  value     = data.azurerm_client_config.current.subscription_id
  sensitive = true
}

# Resource Group
output "resource-group-name" {
  value = azurerm_resource_group.rg.name
}

output "resource-group-location" {
  value = azurerm_resource_group.rg.location
}

# output for the AzureML workspace
output "azureml-workspace-name" {
  value = "${local.prefix}-${local.azureml.cluster_name}-mlw"
}
output "azureml-compute-cluster-name" {
  value = "${local.prefix}-${local.azureml.cluster_name}"
}

# output for the Blob Storage Container
output "blobstorage-container-path" {
  value       = "az://${azurerm_storage_container.artifact-store.name}"
  description = "The Azure Blob Storage Container path for storing your artifacts"
}
output "storage-account-name" {
  value       = "${local.prefix}${local.blob_storage.account_name}"
  description = "The name of the Azure Blob Storage account name"
}
output "storage-account-connection-string" {
  value       = azurerm_storage_account.zenml-account.primary_connection_string
  sensitive   = true
  description = "The Azure Blob Storage account connection string"
}

# key-vault name
output "key-vault-name" {
  value = azurerm_key_vault.secret_manager.name
}

# outputs for the MLflow tracking server
output "mlflow-tracking-URL" {
  value = "https://${azurerm_resource_group.rg.location}.api.azureml.ms/mlflow/v1.0/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.MachineLearningServices/workspaces/${local.prefix}-${local.azureml.cluster_name}-mlw"
}

output "service-principal-id" {
  value = azuread_service_principal.sp.id
}

output "service-principal-tenant-id" {
  value = azuread_service_principal.sp.application_tenant_id
}

output "service-principal-client-id" {
  value = azuread_service_principal.sp.application_id
}

output "service-principal-client-secret" {
  value     = azuread_service_principal_password.sp-pass.value
  sensitive = true
}

# output the name of the stack YAML file created
output "stack-yaml-path" {
  value = local_file.stack_file.filename
}
