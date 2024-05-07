# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# defining the providers for the recipe module
terraform {
  required_providers {
    k3d = {
      source = "pvotal-tech/k3d"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }

    minio = {
      source  = "aminueza/minio"
      version = "1.10.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "1.0.3"
    }

    external = {
      source  = "hashicorp/external"
      version = "2.2.3"
    }
  }

  required_version = ">= 0.14.8"
}
