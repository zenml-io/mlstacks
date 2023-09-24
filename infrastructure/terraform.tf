# defining the providers for the recipe module
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.16.0"
    }
  }

  required_version = ">= 0.14.8"

  backend "azurerm" {
    resource_group_name  = "zenml-developers"
    storage_account_name = "zenmlstorageaccount"
    container_name       = "github-runner-tf"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}