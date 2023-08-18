# defining the providers for the recipe module
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.16.0"
    }
  }

  required_version = ">= 0.14.8"
}

provider "azurerm" {
  features {}
}