# the seldon istio ingress gateway
# cannot use kubernetes_manifest resource since it practically 
# doesn't support CRDs. Going with kubectl instead.
resource "kubectl_manifest" "gateway" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: seldon-gateway
  namespace: default
spec:
  selector:
    istio: ingressgateway # use istio default controller
  servers:
  - port:
      number: 8082
      name: http
      protocol: HTTP
    hosts:
    - "*"
YAML    
  override_namespace = kubernetes_namespace.seldon-ns.metadata[0].name
  depends_on = [
    resource.kubernetes_namespace.seldon-ns
  ]
}

# # creating a namespace for the gateway
# resource "kubernetes_namespace" "istio-ingress-ns" {
#   metadata {
#     name = "istio-ingress"
#     labels = {
#       istio-injection = "enabled"
#     }
#   }
# }

# creating the ingress gateway
# resource "helm_release" "istio-ingress" {
#   name       = "istio-ingress-seldon"
#   repository = helm_release.istiod.repository
#   chart      = "gateway"
# 
#   # dependency on istio-ingress-ns
#   namespace = kubernetes_namespace.istio-ingress-ns.metadata[0].name
# }
