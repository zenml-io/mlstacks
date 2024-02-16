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
    module.gke,
  ]
}


# allow the kubeflow kubernetes sa to access GKE's IAM role
# the GKE IAM role should have access to Storage resources
resource "google_service_account_iam_member" "kubeflow-storage-access" {
  service_account_id = google_service_account.gke-service-account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[kubeflow/default]"
  depends_on = [
    null_resource.kubeflow
  ]
}
  
# add annotation to kubernetes sa pipeline-runner
resource "kubernetes_annotations" "pipeline-runner" {
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name      = "pipeline-runner"
    namespace = "kubeflow"
  }
  annotations = {
    "iam.gke.io/gcp-service-account" = "${google_service_account.gke-service-account.email}"
  }
}