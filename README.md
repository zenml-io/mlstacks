# :man_cook: Open Source MLOps Stack Recipes


When we first created [ZenML](https://zenml.io) as an extensible MLOps framework for
creating portable, production-ready MLOps pipelines, we saw many of our users having to
deal with the pain of deploying infrastructure from scratch to run these pipelines. The
community consistently asked questions like:

- How do I deploy tool X with tool Y?
- Does a combination of tool X with Y make sense?
- Isn't there an easy way to just try these stacks out to make an informed decision?

To address these questions, the ZenML team presents you a series of Terraform-based recipes to quickly
provision popular combinations of MLOps tools. These recipes will be useful for you if:

- You are at the start of your MLOps journey, and would like to explore different tools.
- You are looking for guidelines for production-grade deployments.
- You would like to run your pipelines on your chosen [ZenML Stack](https://docs.zenml.io/advanced-guide/stacks-components-flavors).

🔥 **Do you use these tools or do you want to add one to your MLOps stack?** At
ZenML, we are looking for design partnerships and collaboration to implement and
develop these MLOps stacks in a real-world setting.

If you'd like to learn more, please [join our
Slack](https://zenml.io/slack-invite/) and leave us a message!


## 📜 List of Recipes

| Recipe               | Tools installed                                                | Description                                                                       |
|----------------------|------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|
| aws-minimal | EKS, S3, ECR, RDS, MLflow Tracking, Seldon  | AWS specific recipe to showcase a production-grade MLOps Stack with an EKS orchestrator, S3 artifact store, ECR container registry, RDS MySQL metadata store,  MLFlow experiment tracker and Seldon Core model deployer |
| gcp-minimal | GKE, GCS, GCR, CloudSQL, MLflow Tracking, Seldon | GCP specific recipe to showcase a production-grade MLOps Stack with a GKE orchestrator, GCS artifact store, GCR container repository, CloudSQL MySQL metadata store,  MLFlow experiment tracker and Seldon Core model deployer |
| vertex-ai | Vertex AI Pipelines, GCS, GCR and CloudSQL | A stack with a Vertex AI orchestrator, GCS artifact store, GCR container registry and CloudSQL MySQL metadata store |

## ⚗️ How To Use

Running a recipe is a matter of two simple commands. You can clone the repository, and for a chosen
recipe of your choice execute:

> **Note**
> You need to have credentials for a chosen cloud provider set up before running.

```
terraform init
```

```
terraform apply
```

## 🙏 Association with ZenML

[![maintained-by-zenml](https://user-images.githubusercontent.com/3348134/173032050-ad923313-f2ce-4583-b27a-afcaa8b355e2.png)](https://github.com/zenml-io/zenml)

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

3. 🚀 Deploy the recipe with this simple command.

    ```shell
    zenml stack recipe deploy <stack-recipe-name>
    ```

4. You'll notice that a ZenML stack configuration file gets created automatically! To use the deployed infrastructure, just run the following command to have all of the resources set as your current stack 🤯.

    ```shell
    zenml stack import <path-to-the-created-stack-config-yaml>
    ```

To learn more about ZenML and how it empowers you to develop a stack-agnostic MLOps solution, head
over to the [ZenML docs](https://docs.zenml.io).

## 🎉 Acknowledgements

Thank you to the folks over at [Fuzzy Labs](https://www.fuzzylabs.ai/) for their support and
contributions to this repository.

We'd also like to acknowledge some of the cool inspirations for this project:

- [FuseML](https://fuseml.github.io/)
- [Combinator.ML](https://combinator.ml/)
- [Building a ML Platform From Scratch](https://www.aporia.com/blog/building-an-ml-platform-from-scratch/)