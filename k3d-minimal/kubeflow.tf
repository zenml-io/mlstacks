# set up kubeflow
resource "null_resource" "kubeflow" {
  provisioner "local-exec" {
    command = "kubectl apply -k 'github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=1.8.3' --request-timeout=120"
    environment = {
      PIPELINE_VERSION = local.kubeflow.pipeline_version
    }
  }
  provisioner "local-exec" {
    command = "kubectl wait --for condition=established --timeout=60s crd/applications.app.k8s.io"
  }
  provisioner "local-exec" {
    command = "kubectl apply -k 'github.com/kubeflow/pipelines/manifests/kustomize/env/dev?ref=1.8.3' --request-timeout=120"
    environment = {
      PIPELINE_VERSION = local.kubeflow.pipeline_version
    }
  }
  provisioner "local-exec" {
    command = "kubectl wait deployment -n kubeflow ml-pipeline-visualizationserver --for condition=Available=True --timeout=900s"
  }
  # destroy-time provisioners
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -k 'github.com/kubeflow/pipelines/manifests/kustomize/env/dev?ref=1.8.3' --request-timeout=300"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -k 'github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=1.8.3' --request-timeout=120"
  }

  depends_on = [
    k3d_cluster.zenml-cluster,
  ]
}

# Expose Kubeflow UI
resource "kubernetes_ingress_v1" "kubeflow-ui-ingress" {
  metadata {
    name = "kubeflow-ui-ingress"
    namespace = "kubeflow"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path      = "/kubeflow/?(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = "ml-pipeline-ui"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    null_resource.kubeflow,
    module.minio_server,
  ]
}