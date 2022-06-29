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

| Recipe               | Stack Components                                                                         | Description                                                                       |
|----------------------|------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|
| eks-s3-seldon-mlflow | S3, Seldon, MLflow, EKS | AWS specific recipe to showcase a production-grade MLOps Stack with MLFlow experiment tracker and Seldon Core Deployer |


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
directly (see below).

However, ZenML works seamlessly with the infrastructure provisioned through these recipes. To learn
more about to seamlessly use these awesome mlops stacks with a unified and simple framework, head
over to the [ZenML docs](https://docs.zenml.io).

## 🎉 Acknowledgements

Thank you to the folks over at [Fuzzy Labs](https://www.fuzzylabs.ai/) for their support and
contributions to this repository.

We'd also like to acknowledge some of the cool inspirations for this project:

- [FuseML](https://fuseml.github.io/)
- [Combinator.ML](https://combinator.ml/)
- [Building a ML Platform From Scratch](https://www.aporia.com/blog/building-an-ml-platform-from-scratch/)