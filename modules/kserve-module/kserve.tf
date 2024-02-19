# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

resource "null_resource" "kserve" {
  triggers = {
    kserve_version = var.kserve_version
  }

  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/kserve/kserve/releases/download/v${self.triggers.kserve_version}/kserve.yaml"
  }
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/kserve/kserve/releases/download/v${self.triggers.kserve_version}/kserve-runtimes.yaml"
  }

  # destroy-time provisioners
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f https://github.com/kserve/kserve/releases/download/v${self.triggers.kserve_version}/kserve-runtimes.yaml"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f https://github.com/kserve/kserve/releases/download/v${self.triggers.kserve_version}/kserve.yaml"
  }

  depends_on = [
    null_resource.knative-serving,
  ]
}

# resource "null_resource" "kserve-config" {
#   triggers = {
#     kserve_domain = var.kserve_domain
#   }

#   provisioner "local-exec" {
#     command = "kubectl patch configmap/inferenceservice-config -n kserve --type=strategic -p '{\"data\": {\"ingress\": \"{\\\"ingressDomain\\\": \\\"${self.triggers.kserve_domain}\\\"}\"}}'"
#   }

#   depends_on = [
#     null_resource.kserve,
#   ]
# }
