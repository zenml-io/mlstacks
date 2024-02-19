# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

resource "null_resource" "knative-serving" {
  triggers = {
    knative_version = var.knative_version
  }

  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/knative/serving/releases/download/knative-v${self.triggers.knative_version}/serving-crds.yaml"
  }
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/knative/serving/releases/download/knative-v${self.triggers.knative_version}/serving-core.yaml"
  }
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-v${self.triggers.knative_version}/net-istio.yaml"
  }


  # destroy-time provisioners
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f https://github.com/knative/net-istio/releases/download/knative-v${self.triggers.knative_version}/net-istio.yaml"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f https://github.com/knative/serving/releases/download/knative-v${self.triggers.knative_version}/serving-core.yaml"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f https://github.com/knative/serving/releases/download/knative-v${self.triggers.knative_version}/serving-crds.yaml"
  }

}
