# MLStacks on GCP

The GCP Modular recipe is available in the `mlstacks` repository and you can
[view the raw Terraform files here](https://github.com/zenml-io/mlstacks/tree/main/src/mlstacks/terraform/gcp-modular).

A full list of supported components and flavors can be found in the
[Supported Components and Flavors](#supported-components-and-flavors) section,
as can a list of components that are coming soon.

## Important Notes for GCP Deployments

All GCP deployments require the inclusion of a GCP Project ID in the metadata's
config for each component. This is because GCP resources are tied to a project
and cannot be created without one.

## Supported components and flavors

| Component          | Flavor(s)                                      |
| ------------------ | ---------------------------------------------- |
| Artifact Store     | gcp                                            |
| Container Registry | gcp                                            |
| Experiment Tracker | mlflow                                         |
| Orchestrator       | kubeflow, kubernetes, skypilot, tekton, vertex |
| MLOps Platform     | zenml                                          |
| Model Deployer     | seldon                                 |
| Step Operator      | vertex                                         |

## Coming Soon!

- Airflow Orchestrator on GCP
- Feast Feature Store on GCP
- Label Studio Annotator on GCP
- Model Registry components on GCP
- Image Builder components on GCP
