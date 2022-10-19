# 🥙 AzureML Minimal MLOps Stack Recipe

There can be many motivations behind taking your ML application setup to a cloud environment, from neeeding specialized compute 💪 for training jobs to having a 24x7 load-balanced deployment of your trained model serving user requests 🚀.

We know that the process to set up an MLOps stack can be daunting. There are many components (ever increasing) and each have their own requirements. To make your life easier, we already have a [documentation page](https://docs.zenml.io/cloud-guide/overview) that takes you step-by-step through the entire journey in a cloud platform of your choice (AWS, GCP and Azure supported for now). This recipe, however, goes one step further.

You can have a simple MLOps stack ready for running your machine learning workloads after you execute this recipe 😍. It sets up the following resources:

- An Azure ML Workspace and cluster that can act as an [step operator](https://docs.zenml.io/mlops-stacks/step-operators) for your workloads.
- An Azure Blob Storage Container as an [artifact store](https://docs.zenml.io/mlops-stacks/artifact-stores), which can be used to store all your ML artifacts like the model, checkpoints, etc.
- A MySQL Flexible server instance as a [metadata store](https://docs.zenml.io/mlops-stacks/metadata-stores) that is essential to track all your metadata and its location in your artifact store.  

For each AzureML Worskpace, azureml automatically provisions a storage account, application insights, key vault, container registry and mlflow server.  

Keep in mind, this is a basic setup to get you up and running on Azure with a minimal MLOps stack and more configuration options are coming in the form of new recipes! 👀

## Prerequisites

- You must have a Azure account where you have sufficient permissions to create and destroy resources that will be created as part of this recipe. 
For running this recipe in particular, your account should have the permission to provision at least 1 `LowPriority` vCPU of type `Standard_DS2_v2`. In case, your account doesn't have this permission, you can refer this guide on how to increase [workspace quota](https://learn.microsoft.com/en-gb/azure/machine-learning/how-to-manage-quotas#workspace-level-quotas) for Azure ML workspace. You can also modify the values for `vm_size` and `vm_priority` in `cluster.tf` to provision VM of your choice before running the recipe.
- Have [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform), [Helm](https://helm.sh/docs/intro/install/#from-script) and [Kubectl](https://kubernetes.io/docs/tasks/tools/) installed on your system.
- Install all azure specific dependencies using - `zenml integration install azure`
- Install [azure-cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) and login to your Azure account using `az login`.
- Setup these system level environment variables to avoid any authentication issues while running this recipe - `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID`. You can refer this section on [Authenticate using Azure CLI](https://learn.hashicorp.com/tutorials/terraform/azure-build?in=terraform/azure-get-started#authenticate-using-the-azure-cli) to understand how to do it.


## 🍏 Inputs

Before starting, you should know the values that you need to modify to run this recipe.

- Check out the `locals.tf` file to configure basic information about your deployments. You can use existing default values for various resources or provide your own. 
- Take a look at the `values.tfvars.json` file to know what values have to be supplied for the execution of this recipe. These are mostly sensitive values like passwords, access keys, etc. Make sure you don't commit them!

For this recipe, please ensure to provide values for:

    1. **metadata-db-username**: This value will be used as a username for the MySQL server. Avoid using `azure_superuser`, `admin`, `administrator`, `root`, `guest` or `public` as usernames as it may lead to an error. 

    2. **metadata-db-password**: This value will be used as a password for the MySQL server. This value should be a combination of at least 3 of the following types - lowercase, uppercase, numbers, non-alphanumeric characters for e.g. `zenMLpass1`

> **Warning**
> The `prefix` local variable you assign should have a unique value for each stack. This ensures that the stack you create doesn't interfere with the stacks somebody else in your organization has created with this script.

> **Warning**
> The CIDR block used for the VPC (inside the vpc.tf file) needs to be unique too, preferably. For example, if `10.10.0.0/16` is already under use by some VPC in your account, you can use `10.11.0.0/16` instead. However, this is not required.

## 🧑‍🍳 Cooking the recipe

It is not neccessary to use the MLOps stacks recipes presented here alongisde the
[ZenML](https://github.com/zenml-io/zenml) framework. You can simply use the Terraform scripts
directly.

However, ZenML works seamlessly with the infrastructure provisioned through these recipes. The ZenML CLI has an integration with this repository that makes it really simple to pull and deploy these recipes. A simple flow could look like the following:

1. Pull this recipe to your local system.

    ```shell
    zenml stack recipe pull azureml-minimal
    ```

2. 🎨 Customize your deployment by editing the default values in the `locals.tf` file.

3. 🔐 Add your secret information like keys and passwords into the `values.tfvars.json` file which is not committed and only exists locally.

4. 🚀 Deploy the recipe with this simple command. Once the recipe has been deployed, you can check out your available resources in the Azure Portal.

    ```shell
    zenml stack recipe deploy azureml-minimal
    ```

    > **Note**
    > If you want to allow ZenML to automatically import the created resources as a ZenML stack, pass the `--import` flag to the command above. By default, the imported stack will have the same name as the stack recipe and you can provide your own with the `--stack-name` option.

5. You'll notice that a ZenML stack configuration file gets created after the previous command executes 🤯! This YAML file can be imported as a ZenML stack manually by running the following command.

    ```shell
    zenml stack import <STACK-NAME> <PATH-TO-THE-CREATED-STACK-CONFIG-YAML>
    ```
    ```shell
    # set the stack as an active stack
    zenml stack set <STACK-NAME>
    ```

> **Note**
>
> You need to have your local `az` client logged in. Run `az login` if not done already.

### Configuring your secrets

To make the imported ZenML stack work, you'll have to create secrets that some stack components need. If you inspect the generated YAML file, you can figure out that three secrets should be created:

- `azure-storage-secret` - for allowing access to the Azure Blob Storage Container.

  - Go into your imported recipe directory. It should be under `zenml_stack_recipes/azureml-minimal`.
  - Run the following commands to get the storage account name and key. 

        ```shell
        terraform output storage-account-name
        ```

        ```shell
        terraform output storage-account-key
        ```
  - Now, register your ZenML secret.

        ```shell
        zenml secrets-manager secret register azureml-storage-secret --schema=azure --account_name=<ACCOUNT_NAME> --account_key=<ACCOUNT_KEY>
        ```

- `azure-mysql-secret` - for allowing access to the Flexible MySQL instance.

  - Go into your imported recipe directory. It should be under `zenml_stack_recipes/azure-minimal`.
  - Run the following commands to get the username and password for the MySQL instance.

        ```shell
        terraform output metadata-db-username
        ```
        
        ```shell
        terraform output metadata-db-password
        ```

  - An SSL certificate is already downloaded as part of recipe execution and will be available in the recipe directory with name `DigiCertGlobalRootCA.crt.pem`
  - Now, register the ZenML secret using the following command.

        ```shell
        zenml secrets-manager secret register azureml-mysql-secret --user=<USERNAME> --password=<PASSWORD> --ssl_ca=@"<PATH-TO-THE-CERTIFICATE"
        ```

If you face a `ClientAuthorizationError` while trying to create secrets, add the relevant permissions to your account using the following command.

- Get the key vault name by running the command:

    ```shell
    terraform output key-vault-name
    ```

- Find your Azure object ID. You can also get it from the error message you see.

    ```shell
    az ad user show --id <YOUR_AZURE_EMAIL>
    ```

- Set permissions for your object ID.

    ```shell
    az keyvault set-policy --name <KEY_VAULT_NAME> --object-id <YOUR_OBJECT_ID> --secret-permissions get list set delete --key-permissions create delete get list`
    ```

To get `tracking_token` for Azure MLFlow, you can run the following command.

```bash
export CLIENT_ID=$(terraform output service-principal-client-id)
export CLIENT_SECRET=$(terraform output service-principal-client-secret)
export TENANT_ID=$(terraform output service-principal-tenant-id)
TOKEN="$(curl -i -X POST \
  -d "client_id=${CLIENT_ID}" \
  -d "client_secret=${CLIENT_SECRET}" \
  -d "grant_type=client_credentials" \
  -d "resource=https://management.azure.com" \
  "https://login.microsoftonline.com/${TENANT_ID}/oauth2/token"
  | jq -r .access_token)"

echo $TOKEN
```

While registering the experiment tracker, we can add the tracking token obtained from above step.

```bash
export TRACKING_URI=$(terraform output mlflow-tracking-URL)
zenml experiment-tracker register mlflow_experiment_tracker --flavor=mlflow --tracking_uri=$TRACKING_URI --tracking_token=$TOKEN
```

## 🥧 Outputs

The script, after running, outputs the following.
| Output | Description |
--- | ---
subscription-id | Subscription ID of Azure |
resource-group-name | Name of the resource group that is created. |
resource-group-location | Location of the resource group that is created. |
azureml-compute-cluster-name | Name of the compute cluster that is created in AzureML workspace. |
azureml-workspace-name | Name of the AzureML workspace that is created. |
blobstorage-container-path | The Azure Blob Storage Container path for storing your artifacts|
storage-account-name | The name of the Azure Blob Storage account name|
storage-account-connection-string | The Azure Blob Storage account connection string |
mlflow-tracking-URI | The URL for the MLflow tracking server |
metadata-db-host | The host endpoint of the deployed metadata store |
metadata-db-username | The username for the database user |
metadata-db-password | The master password for the database |
key-vault-name | The name of the Azure Key Vault created |
service-principal-id| The ID for created service principal |
service-principal-client-id | The client ID for created service principal |
service-principal-tenant-id | The tenant ID for created service principal |
service-principal-client-secret | The password for created service principal |

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
    zenml stack recipe destroy azureml-minimal
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

## Running on Azure

Create stack to run on Azure

> **_NOTE:_**: The recommended approach to register all the resources we deployed here, as a ZenML stack is to import the generated YAML file. However, since we are fetching the token after registration, we have to now update our experiment tracking stack component to include it.

```shell
# zenml setup
export STACK_PROFILE="azureml-mlflow"

# azure credentials
export SUBSCRIPTION_ID=$(terraform output subscription-id)
export CLIENT_ID=$(terraform output service-principal-client-id)
export CLIENT_SECRET=$(terraform output service-principal-client-secret)
export TENANT_ID=$(terraform output service-principal-tenant-id)

# azure resource group
export RESOURCE_GROUP=$(terraform output resource-group-name)
export REGION=$(terraform output resource-group-location)

# azure storage
export AZURE_STORAGE_CONNECTION_STRING=$(terraform output storage-account-connection-string)
export CONTAINER_PATH=$(terraform output blobstorage-container-path)

# azureml
export WORKSPACE_NAME=$(terraform output azureml-workpsace-name)
export CLUSTER_NAME=$(terraform output azureml-compute-cluster-name)
export KEY_VAULT_NAME=$(terraform output key-vault-name)

# azure mysql
export MYSQL_USERNAME=$(terraform output metadata-db-username)
export MYSQL_PASSWORD=$(terraform output metadata-db-password)
export MYSQL_SERVER_NAME=$(terraform output metadata-db-host)

# azure mlflow
export TRACKING_URI=$(terraform output mlflow-tracking-URL)

TOKEN="$(curl -i -X POST \
  -d "client_id=${CLIENT_ID}" \
  -d "client_secret=${CLIENT_SECRET}" \
  -d "grant_type=client_credentials" \
  -d "resource=https://management.azure.com" \
  "https://login.microsoftonline.com/${TENANT_ID}/oauth2/token"
  | jq -r .access_token)"

echo $TOKEN

zenml clean
zenml init
zenml profile create $STACK_PROFILE
zenml profile set azure-mlflow

zenml artifact-store register azure_store \
    --flavor=azure \
    --path=$CONTAINER_PATH

zenml secrets-manager register azure_secrets_manager \
    --flavor=azure_key_vault \
    --key_vault_name=$KEY_VAULT_NAME

zenml experiment-tracker register azureml_mlflow_experiment_tracker --flavor=mlflow --tracking_uri=$TRACKING_URI --tracking_token=$TOKEN

zenml metadata-store register azure_mysql \
    --flavor=mysql \
    --database=zenml \
    --secret=azureauthentication \
    --host=$MYSQL_SERVER_NAME

zenml step-operator register azureml \
    --flavor=azureml \
    --subscription_id=$SUBSCRIPTION_ID \
    --resource_group=$RESOURCE_GROUP\
    --workspace_name=$WORKSPACE_NAME \
    --compute_target_name=$CLUSTER_NAME

zenml stack register azureml_stack \
    -m azure_mysql \
    -o default \
    -a azure_store \
    -s azureml \
    -x azure_secrets_manager \
    -e azureml_mlflow_experiment_tracker \
    --set

zenml secrets-manager secret register azureauthentication \
    --schema=mysql \
    --user=$MYSQL_USERNAME \
    --password=$MYSQL_PASSWORD
```
