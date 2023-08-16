# 🍭 Kubeflow, S3, MLflow and Kserve MLOps Stack Recipe 

There can be many motivations behind taking your ML application setup to a cloud environment, from needing specialized compute 💪 for training jobs to having a 24x7 load-balanced deployment of your trained model serving user requests 🚀.

We know that the process to set up an MLOps stack can be daunting. There are many components (ever increasing) and each have their own requirements. To make your life easier, we already have a [documentation page](https://docs.zenml.io/user-guide/starter-guide/switch-to-production) that shows you different ways of switching to a production-grade setting. This recipe, however, goes one step further. 

You can have a simple MLOps stack ready for running your pipelines after you execute this recipe 😍. It sets up the following resources: 
- An EKS cluster with Kubeflow installed that can act as an [orchestrator](https://docs.zenml.io/stacks-and-components/component-guide/orchestrators) for your workloads.
- An S3 bucket as an [artifact store](https://docs.zenml.io/stacks-and-components/component-guide/artifact-stores), which can be used to store all your ML artifacts like the model, checkpoints, etc. 
- An MLflow tracking server as an [experiment tracker](https://docs.zenml.io/stacks-and-components/component-guide/experiment-trackers) which can be used for logging data while running your applications. It also has a beautiful UI that you can use to view everything in one place.
- A Kserve serverless deployment as a [model deployer](https://docs.zenml.io/stacks-and-components/component-guide/model-deployers) to have your trained model deployed on a Kubernetes cluster to run inference on. 
- A [secrets manager](https://docs.zenml.io/stacks-and-components/component-guide/secrets-managers) enabled for storing your secrets. 

Keep in mind, this is a basic setup to get you up and running on AWS with a minimal MLOps stack and more configuration options are coming in the form of new recipes! 👀

## Prerequisites

* You must have an AWS account where you have sufficient permissions to create and destroy resources that will be created as part of this recipe.
* Have [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform) and [Helm](https://helm.sh/docs/intro/install/#from-script) installed on your system.


## 🍅 Inputs

Before starting, you should know the values that you have to keep ready for use in the script. 
- Check out the `locals.tf` file to configure basic information about your deployments.
- Take a look at the `values.tfvars.json` file to know what values have to be supplied during the execution of the script. These are mostly sensitive values like MLflow passwords, AWS access keys, etc. Make sure you don't commit them!

> **Warning** 
> The `prefix` local variable you assign should have a unique value for each stack. This ensures that the stack you create doesn't interfere with the stacks somebody else in your organization has created with this script.

> **Warning**
> The CIDR block used for the VPC (inside the vpc.tf file) needs to be unique too, preferably. For example, if `10.10.0.0/16` is already under use by some VPC in your account, you can use `10.11.0.0/16` instead. However, this is not required.

## 🧑‍🍳 Cooking the recipe

It is not necessary to use the MLOps stacks recipes presented here alongside the
[ZenML](https://github.com/zenml-io/zenml) framework. You can simply use the Terraform scripts
directly.

However, ZenML works seamlessly with the infrastructure provisioned through these recipes. The ZenML CLI has an integration with this repository that makes it really simple to pull and deploy these recipes. A simple flow could look like the following:

1. Pull this recipe to your local system.

    ```shell
    zenml stack recipe pull aws-kubeflow-kserve
    ```
2. 🎨 Customize your deployment by editing the default values in the `locals.tf` file.

3. 🔐 Add your secret information like keys and passwords into the `values.tfvars.json` file which is not committed and only exists locally.

5. 🚀 Deploy the recipe with this simple command.

    ```
    zenml stack recipe deploy aws-kubeflow-kserve
    ```

    > **Tip**
    > If the command fails to run on the first try due to an error with `EnvoyFilters`, simply running `deploy` again should get you going.
    
    > **Note**
    > If you want to allow ZenML to automatically import the created resources as a ZenML stack, pass the `--import` flag to the command above. By default, the imported stack will have the same name as the stack recipe and you can provide your own with the `--stack-name` option.
    

6. You'll notice that a ZenML stack configuration file gets created after the previous command executes 🤯! This YAML file can be imported as a ZenML stack manually by running the following command.

    ```
    zenml stack import <STACK_NAME> -f <PATH_TO_THE_CREATED_STACK_CONFIG_YAML>

    # set the stack as an active stack
    zenml stack set <STACK-NAME>
    ```

> **Note**
>
>  You need to have your AWS credentials saved locally under ~/.aws/credentials

### Configuring your secrets

To make the imported ZenML stack work, you'll have to create secrets that some stack components need. If you inspect the generated YAML file, you can figure out that one secret should be created:
- `aws_kserve_secret` - for allowing KServe access to your S3 bucket.
 
    - We're going to use an AWS credentials file for this. Make sure that the credentials you have in your file have access to S3.
    - Locate the file and note its path. Also, make sure it has a "[default]" section. If not, rename the section to "default". The file should look like the following.
        ```
        [default]
        aws_access_key_id = ...
        aws_secret_access_key = ...
        ```
    - Create the ZenML secret using this command. The path is usually `~/.aws/credentials` in Linux and under the `%UserProfile%` directory in Windows with the same name.
        ```
        zenml secrets-manager secret register -s kserve_s3 aws_kserve_secret --credentials=@"<PATH-TO-CREDENTIALS-FILE>"
        ```


## 🍜 Outputs 

The script, after running, outputs the following.
| Output | Description |
--- | ---
eks-cluster-name | Name of the eks cluster set up. This is helpful when setting up `kubectl` access |
s3-bucket-path | The path of the S3 bucket. Useful while registering the artifact store|
ingress-controller-name | Used for getting the ingress URL for the MLflow tracking server|
ingress-controller-namespace | Used for getting the ingress URL for the MLflow tracking server|
mlflow-tracking-URI | The URL for the MLflow tracking server |
kserve-workload-namespace | Namespace in which kserve workloads will be created |
kserve-base-url | The URL to use for your Kserve deployment |
container-registry-URI | The URI of your container registry |
stack-yaml-path | The path to the ZenML stack configuration YAML file which gets created |

For outputs that are sensitive, you'll see that they are not shown directly on the logs. To view the full list of outputs, run the following command.

```bash
terraform output
```

To view individual sensitive outputs, use the following format. Here, the metadata password is being obtained. 

```bash
terraform output metadata-db-password
```
## Deleting Resources

Using the ZenML stack recipe CLI commands, you can run the following commands to delete your resources and optionally clean up the recipe files that you had downloaded to your local system.

1. 🗑️ Run the destroy command which removes all resources and their dependencies from the cloud.

    ```shell
    zenml stack recipe destroy aws-kubeflow-kserve
    ```

2. (Optional) 🧹 Clean up all stack recipe files that you had pulled to your local system.

    ```shell
    zenml stack recipe clean
    ```


In the case of this recipe, due to existing problems with Kubernetes and Terraform, there might be some resources that get stuck in the `Terminating` state forever. 

To combat this, either delete the Kubernetes nodes from the cloud console directly (recommended) or run the following command after double-checking that your local `kubectl` client is configured to talk to the created cluster. 

```bash
# WARNING: only run this when you are sure that kubectl points to the right cluster.
kubectl delete node --all
```

## Using the recipes without the ZenML CLI

As mentioned above, you can still use the recipe without having using the `zenml stack recipe` CLI commands or even without installing ZenML. Since each recipe is a group of Terraform modules, you can simply employ the terraform CLI to perform `apply` and `destroy` operations.

### Create the resources

1. 🎨 Customize your deployment by editing the default values in the `locals.tf` file.

2. 🔐 Add your secret information like keys and passwords into the `values.tfvars.json` file which is not committed and only exists locally.

3. Initialize Terraform modules and download provider definitions.
    ```bash
    terraform init
    ```

4. Apply the recipe.
    ```bash
    terraform apply
    ```

### Deleting resources

1. 🗑️ Run the destroy function to clean up all resources.

    ```
    terraform destroy
    ```


## Troubleshoot Known Problems

These are some known problems that might arise out of running this recipe. Some of these 
are terraform commands but running `zenml stack recipe apply` would also achieve similar results as `terraform init` and `terraform apply`.

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
    
    
