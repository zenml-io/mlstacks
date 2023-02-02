# set up istio for kserve
resource "null_resource" "kserve" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/kserve/kserve/releases/download/v0.9.0/kserve.yaml"
  }
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/kserve/kserve/releases/download/v0.9.0/kserve-runtimes.yaml"
  }

  # destroy-time provisioners
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f https://github.com/kserve/kserve/releases/download/v0.9.0/kserve.yaml --ignore-not-found"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f https://github.com/kserve/kserve/releases/download/v0.9.0/kserve-runtimes.yaml --ignore-not-found"
  }

  depends_on = [
    null_resource.create-istio-kserve,
  ]
}

resource "kubernetes_namespace" "workloads" {
  metadata {
    name = var.workloads_namespace
  }
}