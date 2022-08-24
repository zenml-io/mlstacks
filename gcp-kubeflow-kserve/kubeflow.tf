# set up kubeflow
resource "null_resource" "kubeflow" {
  provisioner "local-exec" {
    command = "kubectl apply -k 'github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=1.8.3'"
    environment = {
      PIPELINE_VERSION = local.kubeflow.pipeline_version
    }
  }
  provisioner "local-exec" {
    command = "kubectl wait --for condition=established --timeout=60s crd/applications.app.k8s.io"
  }
  provisioner "local-exec" {
    command = "kubectl apply -k 'github.com/kubeflow/pipelines/manifests/kustomize/env/dev?ref=1.8.3'"
    environment = {
      PIPELINE_VERSION = local.kubeflow.pipeline_version
    }
  }

  # destroy-time provisioners
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -k 'github.com/kubeflow/pipelines/manifests/kustomize/env/dev?ref=1.8.3'"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -k 'github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=1.8.3'"
  }

  depends_on = [
    null_resource.configure-local-kubectl,
    google_container_cluster.gke,
  ]
}