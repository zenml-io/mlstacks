# set up istio for kserve
resource "null_resource" "create-istio-kserve" {
  provisioner "local-exec" {
    command = "kubectl apply -l knative.dev/crd-install=true -f https://github.com/knative/net-istio/releases/download/knative-v1.6.0/istio.yaml"
  }
  # repeating the same command as a hack to prevent errors in subsequent commands
  # running it only once would have caused the next command to fail with no envoyfilter CRDs.
  provisioner "local-exec" {
    command = "kubectl apply -l knative.dev/crd-install=true -f https://github.com/knative/net-istio/releases/download/knative-v1.6.0/istio.yaml"
  }
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-v1.6.0/istio.yaml"
  }
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-v1.6.0/net-istio.yaml"
  }

  # destroy-time provisioners
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -l knative.dev/crd-install=true -f https://github.com/knative/net-istio/releases/download/knative-v1.6.0/istio.yaml"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f https://github.com/knative/net-istio/releases/download/knative-v1.6.0/istio.yaml"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f https://github.com/knative/net-istio/releases/download/knative-v1.6.0/net-istio.yaml"
  }

  depends_on = [
    null_resource.create-knative-serving,
  ]
}