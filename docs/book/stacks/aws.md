# MLStacks on AWS

The AWS Modular recipe is available in the `mlstacks` repository and you can
[view the raw Terraform files here](https://github.com/zenml-io/mlstacks/tree/main/src/mlstacks/terraform/aws-modular).

A full list of supported components and flavors can be found in the
[Supported Components and Flavors](#supported-components-and-flavors) section,
as can a list of components that are coming soon.

## Supported components and flavors

| Component          | Flavor(s)                               |
| ------------------ | --------------------------------------- |
| Artifact Store     | s3                                      |
| Container Registry | aws                                     |
| Experiment Tracker | mlflow                                  |
| Orchestrator       | kubernetes, kubeflow, tekton, sagemaker |
| MLOps Platform     | zenml                                   |
| Model Deployer     | seldon, kserve                          |
| Step Operator      | sagemaker                               |

## Coming Soon!

- Airflow Orchestrator on AWS
- Feast Feature Store on AWS
- Label Studio Annotator on AWS
- Model Registry components on AWS
- Image Builder components on AWS
