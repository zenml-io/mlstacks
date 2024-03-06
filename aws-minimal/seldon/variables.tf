# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# variables are values that should be supplied 
# by the calling module

# seldon variables
variable "seldon_name" {}
variable "seldon_namespace" {}

# eks cluster variables for setting up 
# the kubernetes and kubectl providers
variable "cluster_endpoint" {}
variable "cluster_ca_certificate" {}
variable "cluster_token" {}
