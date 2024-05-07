# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# set up tekton pipelines
resource "null_resource" "tekton" {
  triggers = {
    pipeline_version  = var.pipeline_version
    dashboard_version = var.dashboard_version
  }

  provisioner "local-exec" {
    command = "kubectl apply --filename 'https://storage.googleapis.com/tekton-releases/pipeline/previous/v${self.triggers.pipeline_version}/release.yaml'"
  }

  provisioner "local-exec" {
    command = "kubectl apply --filename 'https://storage.googleapis.com/tekton-releases/dashboard/previous/v${self.triggers.dashboard_version}/tekton-dashboard-release.yaml'"
  }


  # destroy-time provisioners
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete --filename 'https://storage.googleapis.com/tekton-releases/dashboard/previous/v${self.triggers.dashboard_version}/tekton-dashboard-release.yaml'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete --filename 'https://storage.googleapis.com/tekton-releases/pipeline/previous/v${self.triggers.pipeline_version}/release.yaml'"
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
  name: tekton-ui-ingress
  namespace: tekton-pipelines
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
      secretName: tekton-ui-tls
%{endif}
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: tekton-dashboard
                port:
                  number: 9097
      host: ${var.ingress_host}
YAML
  depends_on = [
    null_resource.tekton
  ]
}
