# 🥙 Vertex AI MLOps Stack Recipe 

There can be many motivations behind taking your ML application setup to a cloud environment, from neeeding specialized compute 💪 for training jobs to having a 24x7 load-balanced deployment of your trained model serving user requests 🚀.

We know that the process to set up an MLOps stack can be daunting. There are many components (ever increasing) and each have their own requirements. To make your life easier, we already have a [documentation page](addlink) that takes you step-by-step through the entire journey in a cloud platform of your choice (AWS and GCP supported for now). This recipe, however, goes one step further. 

You can have a simple MLOps stack ready for running your machine learning workloads after you execute this recipe 😍. It sets up the following resources: 
- A Vertex AI enabled workspace that you can submit your pipelines to.
- A service account with all the necessary permissions needed to execute your pipelines.
- A GCS bucket as an [artifact store](), which can be used to store all your ML artifacts like the model, checkpoints, etc. 
- A CloudSQL instance as a [metadata store]() that is essential to track all your metadata and its location in your artifact store.  
- An Artifact Registry repository as [container registry]() for hosting your docker images.

Keep in mind, this is a basic setup to get you up and running on Vertex AI with a minimal MLOps stack and more configuration options are coming in the form of new recipes! 👀

## Structure of the recipe

- Every file has a script responsible for creation of its namesake resources.


## 🍏 Inputs

Before starting, you should know the values that you have to keep ready for use in the script. 
- Check out the `locals.tf` file to configure basic information about your deployments.
- Take a look at the `variables.tf` file to know what values have to be supplied during the execution of the script. These are mostly sensitive values like MLflow passwords, etc.
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

## 🥧 Outputs 

The script, after running, outputs the following.
| Output | Description |
--- | ---
gke-cluster-name | Name of the GKE cluster that is created. This is helpful when setting up `kubectl` access |
gcs-bucket-path | The path of the GCS bucket. Useful while registering the artifact store|
ingress-controller-name | Used for getting the ingress URL for the MLflow tracking server|
ingress-controller-namespace | Used for getting the ingress URL for the MLflow tracking server|
seldon-core-workload-namespace | Namespace in which seldon workloads will be created|
metadata-db-host | The host endpoint of the deployed metadata store |
metadata-db-username | The username for the database user |
metadata-db-password | The master password for the database |

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

1. Set up the local `kubectl` client using the output values. Learn more on the Google Cloud [documentation page](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl).

    ```bash
    gcloud container clusters get-credentials <gke-cluster-name>
    ```

2. Register the Kubernetes orchestrator.

    ```bash
    # get the kubernetes context corresponding to the gke cluster
    kubectl config get-contexts

    zenml orchestrator register k8s_orchestrator
        --flavor=kubernetes
        --kubernetes_context=<CONTEXT>
        --synchronous=True
    ```

3. Register the GCS artifact store.

    ```bash
    zenml artifact-store register gcs_store 
        --flavor=gcp 
        --path=gs://<gcs-bucket-path>
    ```

4. Register the secrets manager. [Check](https://console.cloud.google.com/marketplace/product/google/secretmanager.googleapis.com) if you have it enabled in your GCP project. 

    ```bash
    zenml secrets-manager register gcp_secrets_manager \
        --flavor=gcp \
        --region_name=<region>
    ```

5. Register a ZenML secret to use with the metadata store.

    ```bash
    zenml secret register cloudsql_authentication \
        --schema=mysql \
        --user=<metadata-db-username> \
        --password=<metadata-db-password>
    ```

6. Register the CloudSQL metadata store. Here we are using a MySQL store.
    ```
    zenml metadata-store register cloudsql \
        --flavor=mysql \
        --database=zenml \
        --secret=cloudsql_authentication \
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
    export INGRESS_HOST=$(kubectl -n istio-ingress get service istio-ingress-seldon -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    ```


    Now, register the Seldon Core model deployer.

    ```bash
    zenml model-deployer register seldon_eks --type=seldon \
    --kubernetes_context=terraform \ --kubernetes_namespace=<seldon-core-workload-namespace> \
    --base_url=http://$INGRESS_HOST \
    --secret=""
    ```

> **Note**
>
> The tracking username and password should be the same that were used to generate the `.htpasswd` string used to set up the MLflow tracking server.

> **Note**
>
> The folowing command can be used to get the tracking URL for the MLflow server. The EXTERNAL_IP field is the IP of the ingress controller and the path "/" is configured already to direct to the MLflow tracking server.
 ```bash
 kubectl get service "<ingress-controller-name>-ingress-nginx-controller" -n <ingress-controller-namespace>
 ```