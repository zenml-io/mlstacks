# MLStacks on K3D

The K3D Modular recipe is available in the `mlstacks` repository and you can
[view the raw Terraform files here](https://github.com/zenml-io/mlops-stacks/tree/main/src/mlstacks/terraform/k3d-modular).

A full list of supported components and flavors can be found in the
[Supported Components and Flavors](#supported-components-and-flavors) section,
as can a list of components that are coming soon.

## Supported components and flavors

| Component          | Flavor(s)                               |
| ------------------ | --------------------------------------- |
| Artifact Store     | minio                                   |
| Container Registry | k3d                                     |
| Experiment Tracker | mlflow                                  |
| Orchestrator       | kubernetes, kubeflow, tekton, sagemaker |
| MLOps Platform     | zenml                                   |
| Model Deployer     | seldon, kserve                          |

## Coming Soon!

- Airflow Orchestrator on AWS
- Feast Feature Store on AWS
- Label Studio Annotator on AWS
- Model Registry components on AWS
- Image Builder components on AWS
