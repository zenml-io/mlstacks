# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# set up istio for kserve
resource "null_resource" "create-knative-serving" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.6.0/serving-crds.yaml"
  }
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.6.0/serving-core.yaml"
  }

  # destroy-time provisioners
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f https://github.com/knative/serving/releases/download/knative-v1.6.0/serving-crds.yaml"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f https://github.com/knative/serving/releases/download/knative-v1.6.0/serving-core.yaml"
  }

}
