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
    command = "kubectl delete -f https://github.com/knative/net-istio/releases/download/knative-v${self.triggers.knative_version}/net-istio.yaml --ignore-not-found"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f https://github.com/knative/serving/releases/download/knative-v${self.triggers.knative_version}/serving-core.yaml --ignore-not-found"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f https://github.com/knative/serving/releases/download/knative-v${self.triggers.knative_version}/serving-crds.yaml --ignore-not-found"
  }

}
