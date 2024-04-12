# defining the providers for the recipe module
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }

    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "1.0.3"
    }

    huggingface-spaces = {
      source  = "strickvl/huggingface-spaces"
      version = ">= 0.0.4"  # Specify the version or version constraint here
    }
  }

  backend "local" {
    # config = {}
  }

  required_version = ">= 0.14.8"
}

provider "google" {
  project = var.project_id
}
