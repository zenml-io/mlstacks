# 🍭 Modular K3d based MLOps Local Stack Recipe with Kubeflow, Minio Storage, MLflow and more 

There can be many motivations behind taking your ML application setup to a cloud environment, from needing specialized compute 💪 for training jobs to having a 24x7 load-balanced deployment of your trained model serving user requests 🚀.

We know that the process to set up an MLOps stack can be daunting. There are many components (ever increasing) and each have their own requirements. To make your life easier, we already have a [documentation page](https://docs.zenml.io/cloud-guide/overview) that takes you step-by-step through the entire journey in a cloud platform of your choice (AWS, GCP and Azure supported for now). In addition to that, we have created a local MLOps stack recipe that you can use to get started with your MLOps journey in a local environment 🤩.

You can have a simple MLOps stack ready for running your machine learning workloads after you execute this recipe 😍. It sets up the following resources:
- A K3D cluster which you can use directly as [Kubernetes ZenML orchestrator](https://docs.zenml.io/component-gallery/orchestrators/kubernetes) for your workloads.
- A [local container registry](https://docs.zenml.io/component-gallery/container-registries/default) where container images built by your orchestrator are stored and used to run pipelines.
- A Minio S3 Bucket as an [S3 artifact store](https://docs.zenml.io/component-gallery/artifact-stores/amazon-s3), which can be used to store all your ML artifacts like the model, checkpoints, etc.

In addition to the above, the following optional components can be enabled by setting various local variables to `true` in the `locals.tf` file:

- set `kubeflow.enable` to install Kubeflow and use it as a [Kubeflow orchestrator](https://docs.zenml.io/component-gallery/orchestrators/kubeflow) in your ZenML stack.
- set `mlflow.enable` to deploy an MLflow tracking server as an [experiment tracker](https://docs.zenml.io/component-gallery/experiment-trackers/mlflow) which can be used for logging data while running your applications. It also has a beautiful UI that you can use to view everything in one place.
- you can deploy Tekton and use it as a [pipeline orchestrator](https://docs.zenml.io/component-gallery/orchestrators/tekton) instead of or in addition to Kubeflow or the native ZenML Kubernetes orchestrator by setting `tekton.enable` to `true`.
- to install and use Seldon as a [model deployer](https://docs.zenml.io/component-gallery/model-deployers/seldon) in your ZenML pipelines, set `seldon.enable` to `true`.
- to install and use KServe as a [model deployer](https://docs.zenml.io/component-gallery/model-deployers/kserve) in your ZenML pipelines, set `kserve.enable` to `true`.

Naturally, you can combine any of the stack component resources provisioned by this recipe with other local or remote ZenML stack components to create a custom MLOps stack that suits your needs.

## Prerequisites

* You must have a working installation of [Docker](https://docs.docker.com/get-docker/) on your system and a working installation of k3d. You can install k3d by following the instructions [here](https://k3d.io/#installation). Supply the name of your local cluster in the `locals.tf` file.
* Have [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform) and [Helm](https://helm.sh/docs/intro/install/#from-script) installed on your system.


## 🍉 Inputs

Before starting, you should know the values that you have to keep ready for use in the recipe. 
- Check out the `locals.tf` file to configure basic information about your deployments.
- Take a look at the `values.tfvars.json` file to know what values have to be supplied during the execution of the script. These are mostly sensitive values like usernames, passwords, etc. Make sure you don't commit them!

> **Warning** 
> Certain local variables should have a unique value for each recipe deployment to ensures that the local resources created by the recipe don't overlap with other deployments of the same recipe that you might have on your system. These variables are:
> - `k3d.cluster_name` - used to derive the name of the K3D cluster
> - `k3d.registry_name` - used to derive the name of the local container registry
> - `k3d.registry_port` - used to derive the port on which the local container registry is exposed

The `k3d.local_stores_path` variable is used to customize the path on your system where ZenML keeps the local stores files, such as the files where the local artifact store artifacts are saved. This is only useful if you plan on using a combination of local stack components and K3D backed stack components - for example, if you wish to use the local (default) artifact store with any of the orchestrators deployed by this recipe. If left empty, the default value is computed by looking up your active ZenML client configuration. For this purpose, you should run the terraform commands with an active Python environment that has ZenML installed. If this is not possible, you can manually set the `k3d.local_stores_path` variable to the path where ZenML stores the local stores files, which is shown in the `zenml status` output, or leave it empty and avoid using local stack components.

## 🧑‍🍳 Cooking the recipe

It is not necessary to use the MLOps stacks recipes presented here alongisde the
[ZenML](https://github.com/zenml-io/zenml) framework. You can simply use the Terraform scripts
directly.

However, ZenML works seamlessly with the infrastructure provisioned through these recipes. The ZenML CLI has an integration with this repository that makes it really simple to pull and deploy these recipes. A simple flow could look like the following:

1. Pull this recipe to your local system.

    ```shell
    zenml stack recipe pull k3d-modular
    ```
2. 🎨 Customize your deployment by editing the default values in the `locals.tf` file.

3. 🔐 Add your secret information like keys and passwords into the `values.tfvars.json` file which is not committed and only exists locally.

4. 🚀 Deploy the recipe with this simple command.

    ```
    zenml stack recipe deploy k3d-modular
    ```
    
    > **Note**
    > If you want to allow ZenML to automatically import the created resources as a ZenML stack, pass the `--import` flag to the command above. By default, the imported stack will have the same name as the stack recipe and you can provide your own with the `--stack-name` option.
    

5. You'll notice that a ZenML stack configuration file gets created after the previous command executes 🤯! This YAML file can be imported as a ZenML stack manually by running the following command.

    ```
    zenml stack import <stack-name> <path-to-the-created-stack-config-yaml>
    ```

    > **Important**
    > You may need to wait a few minutes for all Kubernetes workloads to start up successfully. You can use the following command to check the status of the pods in your cluster. When all pods are in the `Running` state, you can proceed to running pipelines with your stack(s):
    >
    > ```shell
    > kubectl get -A pods
    > ```

## 🍹 Outputs 

The outputs of the recipe are the resources that are created by the recipe.

For outputs that are sensitive, you'll see that they are not shown directly on the logs. To view the full list of outputs, run the following command.

```bash
terraform output
```

To view individual sensitive outputs, use the following format. For example: 

```bash
terraform output mlflow-password
```

## Deleting Resources

Using the ZenML stack recipe CLI commands, you can run the following commands to delete your resources and optionally clean up the recipe files that you had downloaded to your local system.

1. 🗑️ Run the destroy command which removes all resources and their dependencies from the cloud.

    ```shell
    zenml stack recipe destroy gcp-kubeflow-kserve
    ```

2. (Optional) 🧹 Clean up all stack recipe files that you had pulled to your local system.

    ```shell
    zenml stack recipe clean
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
    terraform apply --var-file=values.tfvars.json
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

* While running `terraform init`, an error which says `Failed to query available provider packages... No available releases match the given constraint`
\
    💡 Fix - First of all, you should create an issue so that we can take a look. Meanwhile, if you know Terraform, make sure all the modules that are being used are on their latest version.

* While running a terraform command, this error might appear too: `context deadline exceeded`
\
    💡 Fix - This problem could arise due to strained system resources. Try running the command again after some time.

* If you change any of the `k3d` locals variables, you may run into an error like the following:
    ```
    Error: Get "http://localhost/api/v1/namespaces/zenml-workloads-k8s": dial tcp 127.0.0.1:80: connect: connection refused
    ```
\
    💡 Fix - This is a due to a fundamental limitation of Terraform that makes it impossible to create a dependency between a provider (kubernetes) and another resource (the K3D cluster). The solution is to run `terraform destroy` first, without changing the k3d configuration attributes, and only then to apply the changes and run `terraform apply`.
