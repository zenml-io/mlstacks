# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix}-${local.resource_group.name}"
  location = local.resource_group.location
}
