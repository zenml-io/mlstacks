# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

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
  count = var.istio_enabled ? 0 : 1

  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kubeflow-ui-ingress
  namespace: kubeflow
  annotations:
%{if var.tls_enabled}
    cert-manager.io/cluster-issuer: letsencrypt-staging
%{endif}
    ingress.annotations.nginx.ingress.kubernetes.io/ssl-redirect: "${var.tls_enabled}"
spec:
%{if !var.istio_enabled}
  ingressClassName: nginx
%{else}
  ingressClassName: istio
%{endif}
%{if var.tls_enabled}
  tls:
    - hosts:
        - ${var.ingress_host}
      secretName: kubeflow-ui-tls
%{endif}
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


# Create Gateway and VirtualService if istio is enabled
resource "kubectl_manifest" "kubeflow-ui-gateway" {
  count     = var.istio_enabled ? 1 : 0
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: zenml-kubeflow-ui-gateway
  namespace: kubeflow
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      name: http
      number: 80
      protocol: HTTP
    hosts:
    - '*'
  %{if var.tls_enabled}
    tls:
      httpsRedirect: false
  - port:
      name: https
      number: 443
      protocol: HTTPS
    hosts:
    - '*'
    tls:
      mode: SIMPLE # enables HTTPS on this port
      credentialName: kubeflow-ui-tls
    %{endif}
YAML    
  depends_on = [
    null_resource.kubeflow
  ]
}

resource "kubectl_manifest" "kubeflow-ui-virtualservice" {
  count     = var.istio_enabled ? 1 : 0
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: kubeflow-ui-virtualservice
  namespace: kubeflow
spec:
  hosts:
  - ${var.ingress_host}
  gateways:
  - zenml-kubeflow-ui-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: ml-pipeline-ui
        port:
          number: 80
YAML    
  depends_on = [
    null_resource.kubeflow
  ]
}
