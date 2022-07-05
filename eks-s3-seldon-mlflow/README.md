# 🥗 EKS, S3, RDS, MLflow and Seldon MLOps Stack Recipe 

Once you have gotten a hang of what ZenML is and how basic pipelines work, it is only natural to have the thought of deploying the pipeline to a cloud environment. There can be many motivations behind this, from neeeding specialized compute 💪 for training jobs to having a 24x7 load-balanced deployment of your trained model serving user requests 🚀.

We know that the process to set up an MLOps stack can be daunting. There are many components (ever increasing) and each have their own requirements. To make your life easier, we already have a [documentation page](addlink) that takes you step-by-step through the entire journey in a cloud platform of your choice (AWS and GCP supported for now). This recipe, however, goes one step further. 

You can have a simple MLOps stack ready for running your pipelines after you execute this recipe. It sets up the following resources: 
- An EKS cluster that can act as an orchestrator for your pipelines using the Kubernetes **orchestrator** stack component in ZenML. 
- An S3 **artifact store** that is spun up, which can be used to store all your pipeline artifacts like the model, checkpoints, etc. 
- An AWS RDS **metadata store** that is essential to track all your metadata and its location in your artifact store.  
- An MLflow **experiment tracker** which can be used for logging data while running your pipelines. It also has a beautiful UI that you can use to view everything in one place.
- A Seldon Core **model deployer** to have your trained model deployed on a Kubernetes cluster to run inference on. 

Keep in mind, this is a basic setup to get you up and running on AWS with a minimal MLOps stack and more configuration options for each of the ZenML stack components are coming in the form of new recipes! 👀

## Structure of the recipe

- Every file has a script responsible for creation of its namesake resources.
- Two modules have been implemented for use within the recipe and in future implementations. These are:

| Module | Description |
--- | ---
mlflow-module | A module to start an MLflow tracking server behind an NGINX proxy|
seldon | Installs Seldon Core along with Istio |



## 🍅 Inputs

Before starting, you should know the values that you have to keep ready for use in the script. 
- Check out the `locals.tf` file to configure basic information about your deployments.
- Take a look at the `variables.tf` file to know what values have to be supplied during the execution of the script. These are mostly sensitive values like MLflow passwords, AWS access keys, etc.
- If you want to avoid having to type these in, with every  `terraform apply` execution, you can add your values as the `default` inside the definition of each variable. 

    As an example, we've set the default value of `metadata-db-username` as "admin" to avoid having to supply it repeatedly. 

    ```hcl
    variable "metadata-db-username" {
      description = "The username for the AWS RDS metadata store"
      default = "admin"
      type = string
    }
    ```
> **Warning:** 
> The `prefix` local variable you assign should have a unique value for each stack. This ensures that the stack you create doesn't interfere with the stacks somebody else in your organization has created with this script.

> **Warning:**
> The CIDR block used for the VPC needs to be unique too. For example, if `10.10.0.0/16` is already under use by some VPC in your account, you can use `10.11.0.0/16` instead.

# 🧑‍🍳Cooking the recipe

After customizing the script using your values, run the following commands.



```bash
terraform init
```

```bash
terraform apply
```

> **Note**
>  You need to have your AWS credentials saved locally under ~/.aws/credentials

## 🍜Outputs 

The script, after running, outputs the following.
| Output | Description |
--- | ---
eks-cluster-name | Name of the eks cluster set up. This is helpful when setting up `kubectl` access |
s3-bucket-path | The path of the S3 bucket. Useful while registering the artifact store|
ingress-controller-name | Used for getting the ingress URL for the MLflow tracking server|
ingress-controller-namespace | Used for getting the ingress URL for the MLflow tracking server|
seldon-core-workload-namespace | Namespace in which seldon workloads will be created|
metadata-db-host | The host endpoint of the deployed metadata store |
metadata-db-username | The username for the database user |
metadata-db-password | The master password for the database |

For outputs that are sensitive, you'll see that they are shown directly on the logs. To view the full list of outputs, run the following command.

```bash
terraform output
```

To view individual sensitive outputs, use the following format. Here, the metadata password is being obtained. 

```bash
terraform output metadata-db-password
```

## Registering the ZenML Stack ✨

1. Set up the local `kubectl` client using the output values.

    ```bash
    aws eks --region REGION update-kubeconfig --name <eks-cluster-name> --alias terraform
    ```

2. Register the Kubernetes orchestrator. 

    ```bash
    zenml orchestrator register k8s_orchestrator
        --flavor=kubernetes
        --kubernetes_context=terraform
        --synchronous=True
    ```

3. Register the S3 artifact store.

    ```bash
    zenml artifact-store register s3_store 
        --flavor=s3 
        --path=s3://<s3-bucket-path>
    ```

4. Register the secrets manager. A secrets manager comes out of the box with your AWS account so no setup is needed. 

    ```bash
    zenml secrets-manager register aws_secrets_manager \
        --flavor=aws \
        --region_name=<region>
    ```

5. Register a ZenML secret to use with the metadata store.

    ```bash
    zenml secret register rds_authentication \
        --schema=mysql \
        --user=<metadata-db-username> \
        --password=<metadata-db-password>
    ```

6. Register the AWS RDS metadata store. Here we are using a MySQL store.
    ```
    zenml metadata-store register rds_mysql \
        --flavor=mysql \
        --database=zenml \
        --secret=rds_authentication \
        --host=<metadata-db-host>
    ```

7. Register the MLflow experiment tracker.
    ```
    zenml experiment-tracker register mlflow_tracker
        --type=mlflow
        --tracking_uri=""
        --tracking_username=""
        --tracking_password=""

    ```

8. Register the Seldon Core model deployer. 

    The Ingress host has to be obtained by using the following command. The exact value couldn't be outputted due to the fact that the ingress is set up using a custom resource.

    ```bash
    export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    ```


    Now, register the Seldon Core model deployer.

    ```bash
    zenml model-deployer register seldon_eks --type=seldon \
    --kubernetes_context=terraform \ --kubernetes_namespace=<seldon-core-workload-namespace> \
    --base_url=http://$INGRESS_HOST \
    --secret=""
    ```

> **Note**
> The tracking username and password should be the same that were used to generate the `.htpasswd` string used to set up the MLflow tracking server.

> **Note**
> The folowing command can be used to get the tracking URL for the MLflow server. The EXTERNAL_IP field is the IP of the ingress controller and the path "/" is configured already to direct to the MLflow tracking server.
 ```bash
 kubectl get service <ingress-controller-name> -n <ingress-controller-namespace>
 ```

## Deleting Resources

Usually, the simplest way to delete all resources deployed by Terraform is to run the `terraform destroy` command 🤯. In this case, however, due to existing problems with Kubernetes and Terraform, there might be some resources that get stuck in the `Terminating` state forever. 

To combat this, there's a script in the root directory, by the name `cleanup.sh` which can be run instead. It will internally run the destroy command along with commands to clean up any dangling resources!

> **Note**
> While deleting the metadata store, the Options Group might not get deleted straight away. If that happens, wait for around 30 mins and run `terraform destroy` again.

## Known Problems

* Running the script for the first time might result in an error with one of the resources - the Istio Ingressway. This is because of a limitation with the resource `kubectl_manifest` that needs the cluster to be set up before it installs its own resources.
\
    💡 Fix - Run `terraform apply` again in a few minutes and this should get resolved.    



*  When executing terraform commands, an error like this one: `timeout while waiting for plugin to start` 
\
    💡 Fix - If you encounter this error with `apply`, `plan` or `destroy`, do `terraform init` and run your command again.

* While running `terraform apply`, an error which says `Failed to construct REST client` 
\
    💡 Fix - Run the `aws eks --region REGION update-kubeconfig --name <eks-cluster-name> --alias terraform` command and do `apply` again.

* While running a terraform command, this error might appear too: `context deadline exceeded`
\
    💡 Fix - This problem could arise due to strained system resources. Try running the command again after some time.
