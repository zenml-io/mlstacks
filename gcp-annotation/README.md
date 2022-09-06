# 🖋️ GCP Annotation MLOps Stack Recipe 

There can be many motivations behind taking your ML application setup to a cloud environment, from neeeding specialized compute 💪 for training jobs to having a 24x7 load-balanced deployment of your trained model serving user requests 🚀.

We know that the process to set up an MLOps stack can be daunting. There are many components (ever increasing) and each have their own requirements. To make your life easier, we already have a [documentation page](https://docs.zenml.io/cloud-guide/overview) that takes you step-by-step through the entire journey in a cloud platform of your choice (AWS, GCP and Azure supported for now). This recipe, however, goes one step further. 

You can have a simple MLOps stack ready for running your machine learning workloads after you execute this recipe 😍. It sets up the following resources: 
- A GCS Bucket as an [artifact store](https://docs.zenml.io/mlops-stacks/artifact-stores), which can be used to store all your ML artifacts like the model, checkpoints, etc. 
- An CloudSQL instance as a [metadata store](https://docs.zenml.io/mlops-stacks/metadata-stores) that is essential to track all your metadata and its location in your artifact store.  
- A [secrets manager](https://docs.zenml.io/mlops-stacks/secrets-managers) enabled for storing your secrets. 

Keep in mind, this is a basic setup to get you up and running on GCP with a minimal MLOps stack and more configuration options are coming in the form of new recipes! 👀

## Prerequisites

* You must have a GCP project where you have sufficient permissions to create and destroy resources that will be created as part of this recipe. Supply the name of your project in the `locals.tf` file.
* Have [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform) and [Helm](https://helm.sh/docs/intro/install/#from-script) installed on your system.


## 🍏 Inputs

Before starting, you should know the values that you have to keep ready for use in the script. 
- Check out the `locals.tf` file to configure basic information about your deployments.
- Take a look at the `values.tfvars.json` file to know what values have to be supplied during the execution of the script. These are mostly sensitive values like MLflow passwords, etc. Make sure you don't commit them!

> **Warning** 
> The `prefix` local variable you assign should have a unique value for each stack. This ensures that the stack you create doesn't interfere with the stacks somebody else in your organization has created with this script.

## 🧑‍🍳 Cooking the recipe

It is not neccessary to use the MLOps stacks recipes presented here alongisde the
[ZenML](https://github.com/zenml-io/zenml) framework. You can simply use the Terraform scripts
directly.

However, ZenML works seamlessly with the infrastructure provisioned through these recipes. The ZenML CLI has an integration with this repository that makes it really simple to pull and deploy these recipes. A simple flow could look like the following:

1. Pull this recipe to your local system.

    ```shell
    zenml stack recipe pull gcp-annotation
    ```
2. 🎨 Customize your deployment by editing the default values in the `locals.tf` file.

3. 🔐 Add your secret information like keys and passwords into the `values.tfvars.json` file which is not committed and only exists locally.

5. 🚀 Deploy the recipe with this simple command.

    ```
    zenml stack recipe deploy gcp-annotation
    ```

    > **Note**
    > If you want to allow ZenML to automatically import the created resources as a ZenML stack, pass the `--import` flag to the command above. By default, the imported stack will have the same name as the stack recipe and you can provide your own with the `--stack-name` option.
    

6. You'll notice that a ZenML stack configuration file gets created after the previous command executes 🤯! This YAML file can be imported as a ZenML stack manually by running the following command.

    ```
    zenml stack import <STACK_NAME> <PATH-TO-THE-CREATED-STACK-CONFIG-YAML>
    ```



> **Note**
>
>  You need to have your GCP credentials saved locally for the `apply` function to work.

### Configuring your secrets

To make the imported ZenML stack work, you'll have to create secrets that some stack components need. If you inspect the generated YAML file, you can figure out that one secret should be created:
- `labelstudio_secret` - for allowing access to your LabelStudio instance.

    - Start a temporary / one-off label-studio instance to get your API key:
        
        ```
        label-studio start -p 8094
        ```

    -  Sign up using an email and a password. Then visit http://localhost:8094/ to log in, and then visit http://localhost:8094/user/account and get your Label Studio API key (from the upper right hand corner). 

    - Now, register the ZenML secret using the following command:

        ```
        zenml secrets-manager secret register labelstudio_secret --api_key="<YOUR_API_KEY>"
        ```

## 🥧 Outputs 

The script, after running, outputs the following.
| Output | Description |
--- | ---
gcs-bucket-path | The path of the GCS bucket. Useful while registering the artifact store|
container-registry-URI | The path to the GCP container registry |

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
    zenml stack recipe destroy gcp-annotation
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

3. Initiliaze Terraform modules and download provider definitions.
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

*  When executing terraform commands, an error like this one: `timeout while waiting for plugin to start` 
\
    💡 Fix - If you encounter this error with `apply`, `plan` or `destroy`, do `terraform init` and run your command again.

* While running `terraform init`, an error which says `Failed to query available provider packages... No available releases match the given constraint`
\
    💡 Fix - First of all, you should create an issue so that we can take a look. Meanwhile, if you know Terraform, make sure all the modules that are being used are on their latest version.

* While running a terraform command, this error might appear too: `context deadline exceeded`
\
    💡 Fix - This problem could arise due to strained system resources. Try running the command again after some time.
