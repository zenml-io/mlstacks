# Installation

MLStacks is a Python package that can be installed using `pip`. It is
recommended that you install MLStacks in a virtual environment. You can install
MLStacks using the following command:

```bash
pip install mlstacks
```

## Other requirements

MLStacks uses Terraform on the backend to manage infrastructure. You will need
to have Terraform installed. Please visit the
[Terraform docs](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform)
for installation instructions.

MLStacks also uses Helm to deploy Kubernetes resources. You will need to have
Helm installed. Please visit the
[Helm docs](https://helm.sh/docs/intro/install/#from-script) for installation
instructions.

If you want to use the `mlstacks breakdown` command to get cost estimates for
your MLOps stacks, you'll need to also have `infracost` installed as well as to
be logged in. Please visit the [Infracost docs](https://www.infracost.io/docs/)
for installation instructions.

## Cloud provider installation

MLStacks currently supports the following stack providers:

- AWS
- GCP
- K3D

If you wish to deploy using these providers you'll need to have accounts (for
AWS and GCP) and the relevant CLIs installed. You will also need to have the
relevant permissions to deploy, manage and destroy resources in these accounts.
Please refer to the documentation for those providers for more information.
