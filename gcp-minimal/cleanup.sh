# run destroy to clear all resources except the potentially 
# troubling kubernetes resources
terraform destroy

# clear dangling k8s resources (temporary hack but simple)
kubectl delete node --all 

# run terraform destroy again to clean up EKS
terraform destroy
