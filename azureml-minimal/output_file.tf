# Export Terraform output variable values to a stack yaml file 
# that can be consumed by zenml stack import
resource "local_file" "stack_file" {
  content  = <<-ADD
    # Stack configuration YAML
    # Generated by the AzureML Minimal MLOps stack recipe.
    zenml_version: ${var.zenml-version}
    stack_name: azureml_minimal_stack_${replace(substr(timestamp(), 0, 16), ":", "_")}
    components:
      artifact_store:
        flavor: azure
        name: azureml_artifact_store
        authentication_secret: azureml-storage-secret
        path: az://${azurerm_storage_container.artifact-store.name}
      metadata_store:
        database: zenml
        flavor: mysql
        host: ${azurerm_mysql_flexible_server.mysql.name}.mysql.database.azure.com}
        name: azureml_mysql_metadata_store
        port: 3306
        secret: azureml-mysql-secret
        upgrade_migration_enabled: true
      step_operator:
        flavor: azureml
        name: azureml_step_orchestrator
        subscription_id: ${data.azurerm_client_config.current.subscription_id}
        resource_group_name: ${azurerm_resource_group.rg.name}
        compute_target_name: ${azurerm_machine_learning_compute_cluster.cluster.name}
      secrets_manager:
        flavor: azure_key_vault
        name: azureml_secrets_manager
        key_vault_name: ${azurerm_key_vault.secret_manager.name}
      experiment_tracker:
        flavor: mlflow
        name: azureml_mlflow_experiment_tracker
        tracking_uri: "azureml://${azurerm_resource_group.rg.location}.api.azureml.ms/mlflow/v1.0/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.MachineLearningServices/workspaces/${local.prefix}-${local.azureml.cluster_name}-mlw"
    ADD
  filename = "./azureml_minimal_stack_${replace(substr(timestamp(), 0, 16), ":", "_")}.yml"
}