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
  }

  backend "BACKENDREPLACEME" {
    bucket = "BUCKETNAMEREPLACEME"
    prefix = "terraform/state"
  }

  required_version = ">= 0.14.8"
}

provider "google" {
  project = var.project_id
}
