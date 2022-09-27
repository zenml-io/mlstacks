# Resource Group
output "resource-group-name" {
  value = azurerm_resource_group.rg.name
}

# output for the AzureML workspace
output "azureml-workpsace-name" {
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
  value       = local.blob_storage.account_name
  description = "The name of the Azure Blob Storage account name"
}
output "storage-account-key" {
  value       = azurerm_storage_account.zenml-account.primary_access_key
  sensitive   = true
  description = "The Azure Blob Storage account key"
}

# outputs for the Flexible MySQL metadata store
output "metadata-db-host" {
  value = "${azurerm_mysql_flexible_server.mysql.name}.mysql.database.azure.com"
}
output "metadata-db-username" {
  value     = var.metadata-db-username
  sensitive = true
}
output "metadata-db-password" {
  description = "The auto generated default user password if not input password was provided"
  value       = azurerm_mysql_flexible_server.mysql.administrator_password
  sensitive   = true
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
