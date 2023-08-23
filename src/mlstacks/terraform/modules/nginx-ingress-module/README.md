# Nginx Ingress Terraform Module 

## Input Variables

Input | Description
--- | ---

## Outputs

Output | Description
--- | ---
ingress-hostname | Used for getting the hostname for the ingress|
ingress-ip-address | Used for getting the IP address for the ingress|
ingress-controller-namespace | Used for getting the namespace where nginx-ingress is installed|
ingress-controller-name | Used for getting the name of the helm nginx-ingress release|

The ingress hostname or IP address is obtained by querying the relevant Kubernetes service that exposes the ingress service..

However, you can also manually query the hostname by using the following command.

```
kubectl get service <ingress-controller-name>-ingress-nginx-controller -n <ingress-controller-namespace>
```
