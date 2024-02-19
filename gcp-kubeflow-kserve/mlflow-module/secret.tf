# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# create a secret with user credentials
resource "kubernetes_secret" "name" {
  metadata {
    name = "basic-auth"
  }

  type = "Opaque"
  # the key should be auth for nginx ingress to work
  # throws a 503 error if the key is not auth
  data = {
    "auth" = var.htpasswd
  }
}
