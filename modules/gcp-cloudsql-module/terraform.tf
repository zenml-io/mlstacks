# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# defining the providers for the recipe module
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
  }

  required_version = ">= 0.14.8"
}

provider "google" {
  project = var.project_id
}
