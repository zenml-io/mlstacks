#!/usr/bin/env bash

main() {
  INFO='\033[0;34m'
  NOFORMAT='\033[0m'
  ERROR='\033[0;31m'
  WARNING='\033[0;33m'

  # run destroy to clear all resources except the potentially 
  # troubling kubernetes resources
  terraform destroy -auto-approve

  # clear dangling k8s resources (temporary hack but simple)
  kubectl delete node --all 

  # run terraform destroy again to clean up EKS
  terraform destroy -auto-approve
}

msg() {
  echo >&2 -e "${1-}"
}

main
