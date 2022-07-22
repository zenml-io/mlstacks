Thank you for your interest in contributing a recipe to this repository! Here are some things that you should know before getting started. 

## Principles and the structure of a recipe

### Modularity

The recipes are built in a modular fashion so that it's simple to build new ones from parts of existing recipes. 
- Inside a recipe, every file has the code responsible for creation of its namesake resources.
- Any modules that are created internally are put in folders in the root directory. An example would be the MLflow and Seldon modules in the `aws-minimal` recipe.

### Inputs

Each recipe takes user input in two forms:
- Values pertaining to non-sensitive configuration of individual stack components like name, region, allowed IPs, etc. are provided in the `locals.tf` file.
- Any sensitive information like MySQL passwords are passed as variables in the `values.tfvars` file.

### Outputs

The outputs from each resource are used in two ways:
- In the form of terraform outputs in the `outputs.tf` file. These values are shown on the terminal after a successful execution of `terraform apply`.
- These values can also be used inside `output_file.tf` which is used to create the stack configuration file for ZenML to import your created resources from. 

## Testing your recipe

Each recipe can be tested using simple Terraform commands. You can go into the relevant directory and execute `terraform init` and `terraform apply` to see how the resources are being created. The code for integrating with ZenML resides on the ZenML repository and you won't have to worry about testing it. 


## Integrating with the ZenML stack

The integration with the ZenML stack CLI commands happens in two ways:

- The `output_file.tf` file creates a stack configuration YAML of all the relevant output values from the different resources that are created. 
- A script by the name `run_recipe.sh` contains commands that are run when `zenml stack recipe deploy` is executed. This should hold the `terraform init` and `terraform apply` commands and you can take existing recipes as reference for a working script.
- The `destroy_recipe.sh` file contains the commands that are run when `zenml stack recipe destroy` is called. 

## Adding a dummy recipe - an example (Coming soon)