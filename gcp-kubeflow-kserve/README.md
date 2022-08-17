# 🍭 Kubeflow, Vertex, GCS, CloudSQL, MLflow and Kserve MLOps Stack Recipe 

There can be many motivations behind taking your ML application setup to a cloud environment, from neeeding specialized compute 💪 for training jobs to having a 24x7 load-balanced deployment of your trained model serving user requests 🚀.

We know that the process to set up an MLOps stack can be daunting. There are many components (ever increasing) and each have their own requirements. To make your life easier, we already have a [documentation page](https://docs.zenml.io/cloud-guide/overview) that takes you step-by-step through the entire journey in a cloud platform of your choice (AWS, GCP and Azure supported for now). This recipe, however, goes one step further. 

You can have a simple MLOps stack ready for running your machine learning workloads after you execute this recipe 😍. It sets up the following resources: 
- A GKE cluster with Kubeflow installed that can act as an [orchestrator](https://docs.zenml.io/mlops-stacks/orchestrators) for your workloads.
- A GCS Bucket as an [artifact store](https://docs.zenml.io/mlops-stacks/artifact-stores), which can be used to store all your ML artifacts like the model, checkpoints, etc. 
- An CloudSQL instance as a [metadata store](https://docs.zenml.io/mlops-stacks/metadata-stores) that is essential to track all your metadata and its location in your artifact store.  
- An MLflow tracking server as an [experiment tracker](https://docs.zenml.io/mlops-stacks/experiment-trackers) which can be used for logging data while running your applications. It also has a beautiful UI that you can use to view everything in one place.
- A Kserve serverless deployment as a [model deployer](https://docs.zenml.io/mlops-stacks/model-deployers) to have your trained model deployed on a Kubernetes cluster to run inference on. 
- A [secrets manager](https://docs.zenml.io/mlops-stacks/secrets-managers) enabled for storing your secrets. 
- Vertex AI is enabled which can be used a [step operator](https://docs.zenml.io/mlops-stacks/step-operators).


## Prerequisites

* You must have a GCP project where you have sufficient permissions to create and destroy resources that will be created as part of this recipe. Supply the name of your project in the `locals.tf` file.
* Have [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform) and [Helm](https://helm.sh/docs/intro/install/#from-script) installed on your system.


## 🍉 Inputs

Before starting, you should know the values that you have to keep ready for use in the script. 
- Check out the `locals.tf` file to configure basic information about your deployments.
- Take a look at the `variables.tf` file to know what values have to be supplied during the execution of the script. These are mostly sensitive values like MLflow passwords, etc. You can add these values in the `values.tfvars.json` file and make sure you don't commit them!
- If you want to avoid having to type these in, with every  `terraform apply` execution, you can add your values as the `default` inside the definition of each variable. 

    As an example, we've set the default value of `metadata-db-username` as "admin" to avoid having to supply it repeatedly. 

    ```hcl
    variable "metadata-db-username" {
      description = "The username for the CloudSQL metadata store"
      default = "admin"
      type = string
    }
    ```
> **Warning** 
> The `prefix` local variable you assign should have a unique value for each stack. This ensures that the stack you create doesn't interfere with the stacks somebody else in your organization has created with this script.

> **Warning**
> The CIDR block used for the VPC (inside the vpc.tf file) needs to be unique too, preferably. For example, if `10.10.0.0/16` is already under use by some VPC in your account, you can use `10.11.0.0/16` instead. However, this is not required.

## 🧑‍🍳 Cooking the recipe

After customizing the script using your values, run the following commands.



```bash
terraform init
```

```bash
terraform apply
```

> **Note**
>
>  You need to have your GCP credentials saved locally for the `apply` function to work.

## 🍹 Outputs 

The script, after running, outputs the following.
| Output | Description |
--- | ---
gke-cluster-name | Name of the GKE cluster that is created. This is helpful when setting up `kubectl` access |
gcs-bucket-path | The path of the GCS bucket. Useful while registering the artifact store|
ingress-controller-name | Used for getting the ingress URL for the MLflow tracking server|
ingress-controller-namespace | Used for getting the ingress URL for the MLflow tracking server|
mlflow-tracking-URL | The URL for the MLflow tracking server |
kserve-workload-namespace | Namespace in which kserve workloads will be created |
kserve-base-url | The URL to use for your Kserve deployment |
metadata-db-host | The host endpoint of the deployed metadata store |
metadata-db-username | The username for the database user |
metadata-db-password | The master password for the database |
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

Usually, the simplest way to delete all resources deployed by Terraform is to run the `terraform destroy` command 🤯. In this case, however, due to existing problems with Kubernetes and Terraform, there might be some resources that get stuck in the `Terminating` state forever. 

To combat this, there's a script in the root directory, by the name `cleanup.sh` which can be run instead. It will internally run the destroy command along with commands to clean up any dangling resources!

> **Note**
>
> While deleting the metadata store, the Options Group might not get deleted straight away. If that happens, wait for around 30 mins and run `terraform destroy` again.

## Known Problems

* Running the script for the first time might result in an error with one of the resources - the Istio Ingressway. This is because of a limitation with the resource `kubectl_manifest` that needs the cluster to be set up before it installs its own resources.
\
    💡 Fix - Run `terraform apply` again in a few minutes and this should get resolved.    



*  When executing terraform commands, an error like this one: `timeout while waiting for plugin to start` 
\
    💡 Fix - If you encounter this error with `apply`, `plan` or `destroy`, do `terraform init` and run your command again.

* While running `terraform init`, an error which says `Failed to query available provider packages... No available releases match the given constraint`
\
    💡 Fix - First of all, you should create an issue so that we can take a look. Meanwhile, if you know Terraform, make sure all the modules that are being used are on their latest version.

* While running a terraform command, this error might appear too: `context deadline exceeded`
\
    💡 Fix - This problem could arise due to strained system resources. Try running the command again after some time.

* Error while creating the CloudSQL instance through terraform, `│ Error: Error, failed to create instance jayesh-zenml-metadata-store: googleapi: Error 409: The Cloud SQL instance already exists. When you delete an instance, you can't reuse the name of the deleted instance until one week from the deletion date., instanceAlreadyExists`
\
    💡 Fix - Simply change the name of the CloudSQL instance inside the `locals.tf` file and reuse the older name only after a week.


## Registering the ZenML Stack ✨

It is not neccessary to use the MLOps stacks recipes presented here alongisde the
[ZenML](https://github.com/zenml-io/zenml) framework. You can simply use the Terraform scripts
directly.

However, ZenML works seamlessly with the infrastructure provisioned through these recipes. The ZenML CLI has an integration with this repository that makes it really simple to pull and deploy these recipes. A simple flow could look like the following:

1. 📃 List the available recipes in the repository.

    ```shell
    zenml stack recipe list
    ```
2. Pull the recipe that you wish to deploy, to your local system.

    ```shell
    zenml stack recipe pull <stack-recipe-name>
    ```
3. 🎨 Customize your deployment by editing the default values in the `locals.tf` file.

4. ⚙️ Make sure that have the `gcp`, `kubeflow`, `kserve` and `mlflow` integrations installed, without which the stack import would fail.

    ```shell
    zenml integration install gcp kubeflow kserve mlflow
    ```

5. 🚀 Deploy the recipe with this simple command.

    ```shell
    zenml stack recipe deploy <stack-recipe-name>
    ```
    > **Note**
    > You'll notice that a ZenML stack configuration file gets created 🤯!
    This command will also import this YAML file as a ZenML stack, using the stack recipe's name by default. You can set your own name by using the `--stack-name` option. 
    
6. If you wish to prevent this behaviour and prefer making any modifications to the generated configuration file before importing, pass the `--no-import` flag with the `deploy` command. You can then run the following command to import the resources set as your current stack, manually.

    ```shell
    zenml stack import <stack-name> <path-to-the-created-stack-config-yaml>
    ```

To learn more about ZenML and how it empowers you to develop a stack-agnostic MLOps solution, head
over to the [ZenML docs](https://docs.zenml.io).
