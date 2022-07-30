# set up local kubectl client to access the newly created cluster
resource "null_resource" "configure-local-kubectl" {
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${local.prefix}-${local.aks.cluster_name} --context terraform-${module.aks.cluster_name}"
  }
  depends_on = [
    module.aks
  ]
}