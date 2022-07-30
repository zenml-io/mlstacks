#!/usr/bin/env bash

main() {
  INFO='\033[0;34m'
  NOFORMAT='\033[0m'
  ERROR='\033[0;31m'
  WARNING='\033[0;33m'

  # run destroy to clear all resources
  terraform destroy -auto-approve
}

msg() {
  echo >&2 -e "${1-}"
}

main
