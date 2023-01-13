# set up kubeflow pipelines
resource "null_resource" "kubeflow" {
  triggers = {
    pipeline_version = var.pipeline_version
  }

  provisioner "local-exec" {
    command = "kubectl apply -k 'github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=${self.triggers.pipeline_version}&timeout=5m'"
  }
  provisioner "local-exec" {
    command = "kubectl wait --for condition=established --timeout=60s crd/applications.app.k8s.io"
  }
  provisioner "local-exec" {
    command = "kubectl apply -k 'github.com/kubeflow/pipelines/manifests/kustomize/env/dev?ref=${self.triggers.pipeline_version}&timeout=5m'"
  }

  # destroy-time provisioners
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -k 'github.com/kubeflow/pipelines/manifests/kustomize/env/dev?ref=${self.triggers.pipeline_version}'"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -k 'github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=${self.triggers.pipeline_version}'"
  }
}

# create an ingress
# cannot use kubernetes_manifest resource since it practically 
# doesn't support CRDs. Going with kubectl instead.
resource "kubectl_manifest" "ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kubeflow-ui-ingress
  namespace: kubeflow
  annotations:
%{ if var.tls_enabled }
    cert-manager.io/cluster-issuer: letsencrypt-staging
%{ endif }
    ingress.annotations.nginx.ingress.kubernetes.io/ssl-redirect: "${var.tls_enabled}"
spec:
  ingressClassName: nginx
%{ if var.tls_enabled }
  tls:
    - hosts:
        - ${var.ingress_host}
      secretName: kubeflow-ui-tls
%{ endif }
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ml-pipeline-ui
                port:
                  number: 80
      host: ${var.ingress_host}
YAML    
  depends_on = [
    null_resource.kubeflow
  ]
}
