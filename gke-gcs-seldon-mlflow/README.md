# EKS, S3, Seldon and MLflow Stack 

This is the stack recipe for having EKS as the orchestrator, S3 as the artifact store, Seldon Core as the model deployer and MLflow as the experiment tracker.

## Structure of the directory

- Every file has a script responsible for creation of its namesake resources.
- Two modules have been implemented for use within the recipe and in future implementations. These are:

| Module | Description |
--- | ---
mlflow-module | A module to start an MLflow tracking server behind an NGINX proxy|
seldon | Installs Seldon Core along with Istio |

- The `locals` file holds the configuration which is used for provisioning the stack.

> **Warning:** 
> The `prefix` variable you assign should have a unique value for each stack. This ensures that the resources don't interfere with each other.

> **Warning:**
> The CIDR block used for the VPC needs to be unique too. For example, if `10.10.0.0/16` is already under use by some VPC in your account, you can use `10.11.0.0/16` instead.

## Running the script

After customizing the script using your values, run the following commands.

> **Note**
>  You need to have your AWS credentials saved locally under ~/.aws/credentials

```
terraform init
```

```
terraform apply
```

## Outputs

The script, after running, outputs the following.
| Output | Description |
--- | ---
eks-cluster-name | Name of the eks cluster set up. This is helpful when setting up `kubectl` access |
s3-bucket-path | The path of the S3 bucket. Useful while registering the artifact store|
ingress-controller-name | Used for getting the ingress URL for the MLflow tracking server|
ingress-controller-namespace | Used for getting the ingress URL for the MLflow tracking server|
seldon-core-workload-namespace | Namespace in which seldon workloads will be created|

## Registering the ZenML Stack

1. Set up the local kubectl client using the output values.
```
aws eks --region REGION update-kubeconfig --name <eks-cluster-name> --alias terraform
```

2. Register the kubernetes orchestrator. 

```
zenml orchestrator register k8s_orchestrator
    --flavor=kubernetes
    --kubernetes_context=terraform
    --synchronous=True
```

3. Register the S3 artifact store.
```
zenml artifact-store register s3_store 
    --flavor=s3 
    --path=s3://<s3-bucket-path>
```

4. Register the MLflow experiment tracker.
```
zenml experiment-tracker register mlflow_tracker
    --type=mlflow
    --tracking_uri=""
    --tracking_username=""
    --tracking_password=""

```

5. Register the Seldon Core model deployer. The Ingress host has to be obtained by using the following command. The exact value couldn't be outputted due to the fact that the ingress is set up using a custom resource.

```
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

Now, register the Seldon Core model deployer.

```
zenml model-deployer register seldon_eks --type=seldon \
  --kubernetes_context=terraform \ --kubernetes_namespace=<seldon-core-workload-namespace> \
  --base_url=http://$INGRESS_HOST \
  --secret=""
```

> **Note**
> The tracking username and password should be the same that were used to generate the `.htpasswd` string used to set up the MLflow tracking server.

> **Note**
> The folowing command can be used to get the tracking URL for the MLflow server. The EXTERNAL_IP field is the IP of the ingress controller and the path "/" is configured already to direct to the MLflow tracking server.
 `kubectl get service <ingress-controller-name> -n <ingress-controller-namespace>`

## Deleting Resources

Usually, the simplest way to delete all resources deployed by Terraform is to run the `terraform destroy` command. In this case, however, due to existing problems with Kubernetes and Terraform, there might be some resources that get stuck in the `Terminating` state forever. 

To combat this, there's a script in the root directory, by the name `cleanup.sh` which can be run instead. It will internally run the destroy command along with commands to clean up any dangling resources!


## Known Problems

- Running the script for the first time might result in an error with one of the resources - the Istio Ingressway. This is because of a limitation with the resource `kubectl_manifest` that needs the cluster to be set up before it installs its own resources. 

Fix - Run `terraform apply` again in a few minutes and this should get resolved.

- `timeout while waiting for plugin to start` 

Fix - If you encounter this error with `apply`, `plan` or `destroy`, do `terraform init` and run your command again.

- `Failed to construct REST client` while running `terraform apply`

Fix - Run the `aws eks --region REGION update-kubeconfig --name <eks-cluster-name> --alias terraform` command and do `apply` again.

- `context deadline exceeded`

Fix - This problem could arise due to strained system resources. Try running the command again after some time.