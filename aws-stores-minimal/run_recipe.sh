#!/usr/bin/env bash

set -eo pipefail

# Initialise the configuration
terraform_init() {

  if [ -d ".ignoreme" ]; then
    msg "${INFO}Terraform already initialized, ${NOFORMAT}terraform init${WARNING} will not be executed."
  else
    terraform init -input=false
    mkdir .ignoreme
  fi
}

main() {
  INFO='\033[0;34m'
  NOFORMAT='\033[0m'
  ERROR='\033[0;31m'
  WARNING='\033[0;33m'

  # terraform_init
  terraform_init

  # create a plan and apply automatically
  terraform apply -input=false -auto-approve -var-file="values.tfvars"

  # write the path to the stack YAML file into stack_info.txt
  terraform output stack-yaml-path > stack_info.txt
}

msg() {
  echo >&2 -e "${1-}"
}

main
