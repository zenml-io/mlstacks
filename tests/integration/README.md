# Integrating Local Testing of AWS Deployments in MLStacks Using LocalStack

## Prerequisites
- Docker
- AWS CLI
- Terraform

## LocalStack

LocalStack is a powerful tool that simulates AWS cloud services on your local machine, providing a development environment that closely mirrors the live AWS environment without incurring the costs associated with real AWS services. It supports a wide range of AWS services, allowing you to test various deployment configurations before pushing them to AWS. For more information and a complete guide on how to use LocalStack, visit the [LocalStack Documentation](https://docs.localstack.cloud/getting-started/).

### Installation

Installation can be done via Homebrew, PIP, Docker CLI, or Docker Compose. For detailed instructions, refer to the [LocalStack Installation Guide](https://docs.localstack.cloud/getting-started/installation/).

**Homebrew**
```bash
brew install localstack/tap/localstack-cli
```

**PIP**
```bash
python -m venv .venv
source .venv/bin/activate
pip install localstack
```

### Starting LocalStack

First, ensure Docker is running. Then, you can start LocalStack using the LocalStack CLI, Docker or Docker Compose.

**LocalStack CLI**
```bash
localstack start -d
```

**Docker CLI**

```bash
docker run --rm -it -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack
```

**Docker Compose**

Use the `docker-compose.localstack.yml` file in `test/integration` for an easy setup. From that directory, run:

```bash
docker-compose -f docker-compose.localstack.yml up -d
```

> You may customize this file as needed. If you don't specify any services, LocalStack defaults to running all supported AWS services. Refer to the [LocalStack Docker Compose guide](https://docs.localstack.cloud/getting-started/installation/#starting-localstack-with-docker-compose) for more details.



### Interacting with LocalStack

Once LocalStack is running, interact with it using `aws` commands by specifying the `endpoint-url`. 
For instance, to create an S3 bucket:

```bash
aws --endpoint-url=http://localhost:4566 s3 mb mybucket
```

To avoid having to specify the `endpoint-url` with each command, you can install the [awscli-local](https://github.com/localstack/awscli-local) package. It provides the `awslocal` command, which automatically targets the LocalStack endpoint.

So you can simply do this...
```bash
awslocal s3 mb s3://test-bucket
```

Instead of this...
```bash
aws --endpoint-url=http://localhost:4566 s3 mb mybucket
```

#### Installation

```bash
pip install awscli-local
```

#### Usage examples

List all buckets:
```bash
awslocal s3 ls
```

Create a DynamoDB table:
```bash
awslocal dynamodb create-table \
    --table-name test-table \
    --key-schema AttributeName=id,KeyType=HASH \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --billing-mode PAY_PER_REQUEST \
    --region eu-north-1
```

List DynamoDB tables:
```bash
awslocal dynamodb list-tables --region eu-north-1
```

> **Note:**
> **Most AWS services require specifying the region when using LocalStack, except for S3, which is globally accessible.**


## Provisioning AWS resources with Terraform + LocalStack

To simulate the deployment of AWS resources locally, we utilize Terraform in conjunction with LocalStack. 

### Terraform Configuration

Instead of relying solely on traditional Terraform files, we incorporate `.tfvars` files to specify resource configurations. These files are used in conjunction with generic Terraform configuration files located in the project's Terraform directories (`aws-modular` and `aws-remote-state`).

`.tfvars` files enable external variable definitions for Terraform, allowing for dynamic adjustments to resource specifications and testing parameters without modifying the primary Terraform configuration. Refer to the [`.tfvars` documentation](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files) for more details.

**Example .`tfvars` file for `aws-modular`:**

```hcl
region                       = "eu-north-1"
bucket_name                  = "local-artifact-store-1"
enable_orchestrator_skypilot = true
```

**Example `.tfvars` for `aws-remote-state`**:

```hcl
region            = "eu-north-1"
bucket_name       = "local-artifact-store-2"
dynamo_table_name = "remote-terraform-state-locks"
force_destroy     = true
```

## GitHub Actions Workflow for AWS Integration Testing

This documentation describes the GitHub Actions workflow for LocalStack-based AWS integration testing within MLStacks. It features two primary jobs: `aws_remote_state_integration_test` and `aws_modular_integration_test`, aimed at provisioning and validating AWS resources in a local setup.


### Implementing Terraform Overrides

For simulating AWS resources in our integration tests, we have two approaches:

1. Manual configuration using override files.
2. Utilizing `tflocal` for a more automated setup.

#### [Manual Configuration](https://docs.localstack.cloud/user-guide/integrations/terraform/#manual-configuration) 

We have adopted the manual configuration method using an `_override.tf` file to specify provider settings tailored for LocalStack. 
This approach allows us to directly manipulate how Terraform interacts with AWS services. 

> Terraform inherently recognizes any file ending in `override.tf` as an override file, allowing you to alter configurations without modifying the primary Terraform files. 
Detailed guidance on employing override files is available in the [Terraform Override Files Documentation](https://developer.hashicorp.com/terraform/language/files/override).

#### Alternative: [Using `terraform-local`](https://docs.localstack.cloud/user-guide/integrations/terraform/)

For an automated setup, you can install the [`terraform-local`](https://github.com/localstack/terraform-local) package, which provides the `tflocal` command. It acts as a wrapper around Terraform commands, automatically adjusting them for compatibility with LocalStack. This eliminates the need for manual endpoint configuration, but requires additional setup for `tflocal`.

## Workflow Setup

### Trigger Events

The workflow is designed to be triggered on two events:

- `workflow_call`: Allows this workflow to be called from other workflows within the repository.
- `workflow_dispatch`: Enables manual triggering of the workflow from the GitHub Actions UI.

```yml
on:
  workflow_call:
  workflow_dispatch:
```
## Jobs Overview

### AWS Modular Integration Test

This job tests the provisioning of AWS resources, including the optional SkyPilot orchestrator, within the `aws-modular` configuration.

#### Setup LocalStack Service

- Uses a service container to spin up LocalStack, mapping port 4566 for AWS service emulation.
- Configures AWS services (`s3`, `iam`, `sts`) and sets the default region to `eu-north-1`.

```yml
services:
  setup-localstack-service:
    image: localstack/localstack
    ports:
      - '4566:4566'
    env:
      SERVICES: 's3,iam,sts'
      DEFAULT_REGION: eu-north-1
      FORCE_NONINTERACTIVE: 1
      AWS_ACCESS_KEY_ID: test
      AWS_SECRET_ACCESS_KEY: test
```

#### Steps

```yml
steps:
  - name: Checkout Repository
    uses: actions/checkout@v2

  - name: Setup Terraform
    uses: hashicorp/setup-terraform@v2
    with:
      terraform_version: 1.3.4

  - name: Copy Override File
    run: |
      cp tests/integration/_override.tf src/mlstacks/terraform/aws-modular/_override.tf

  - name: Apply Terraform Configuration
    run: |
      export TF_CLI_ARGS_apply="-compact-warnings"
      terraform init -backend-config="path=./terraform.tfstate"
      terraform validate
      terraform apply -auto-approve -var-file="../../../../tests/integration/aws-modular/local.tfvars"
    working-directory: src/mlstacks/terraform/aws-modular

  - name: Refresh Terraform State
    run: terraform refresh
    working-directory: src/mlstacks/terraform/aws-modular

  - name: Output Stack YAML Path
    id: set_output
    run: |
      OUTPUT=$(terraform-bin output -raw stack-yaml-path)
      echo "stack_yaml_path=$OUTPUT" >> $GITHUB_OUTPUT
    working-directory: src/mlstacks/terraform/aws-modular
    env:
      terraform_wrapper: false

  - name: Run Tests to Verify Resource Provisioning
    run: |
      STACK_YAML_PATH="${{ steps.set_output.outputs.stack_yaml_path }}"
      ABSOLUTE_PATH="${GITHUB_WORKSPACE}/src/mlstacks/terraform/aws-modular/${STACK_YAML_PATH}"
      echo "Absolute YAML path: $ABSOLUTE_PATH"
      ../../../../tests/integration/aws-modular/verify_stack.sh "$ABSOLUTE_PATH"
    working-directory: src/mlstacks/terraform/aws-modular

  - name: Cleanup Resources for aws-modular
    run: |
      cd src/mlstacks/terraform/aws-modular
      terraform destroy -auto-approve -var-file="../../../../tests/integration/aws-modular/local.tfvars"
      rm -rf .terraform
      rm -rf volume
      rm -f .terraform.lock.hcl
      rm -f terraform.tfstate
      rm -f terraform.tfstate.backup
      rm -f localstack_providers_override.tf
      rm -f aws_modular_stack_*.yaml

  - name: Ensure _override.tf Deletion
    if: always()
    run: |
      rm -f src/mlstacks/terraform/aws-modular/_override.tf
    working-directory: ${{ github.workspace }}
```
- **Copy Override File**: Copies the `_override.tf` file into the `aws-modular` directory to ensure Terraform operations target the LocalStack environment.
- **Apply Terraform Configuration**: Navigates to the `aws-modular` directory, initializes Terraform with LocalStack as the backend, validates the configuration, and applies it using a `.tfvars` file.
- **Refresh Terraform State**: Refreshes the state file to ensure the latest state is accurately reflected, including the generation of the YAML file.
- **Output Stack YAML Path**: Utilizes `terraform-bin` instead of the standard `terraform` command to accurately capture and output the `stack-yaml-path`. This change was required to bypass `terraform_wrapper`, and ensures Terraform commands execute directly without any abstractions.
- **Run Tests to Verify Resource Provisioning**:This step captures the YAML file's path, generated by the Terraform apply process, into a variable. It then utilizes this path to run a bash script to verify the provisioning and configuration of resources.
    > **Note: Using an absolute path is essential here due to the test script's location in `tests/integration`.** 
- **Cleanup Resources**: Handles the teardown of all resources and the removal of Terraform-related files to ensure no residual state or configurations are left behind.
- **Ensure `_override.tf` Deletion**: Ensures the copied `_override.tf` file is removed after job completion.

### AWS Remote State Integration Test

This job focuses on testing the provisioning of AWS resources related to remote state management, such as S3 buckets for artifact storage and DynamoDB tables for state locking.

#### Setup LocalStack Service

- Uses a service container to spin up LocalStack, mapping port 4566 for AWS service emulation.
- Configures essential AWS services (`s3`, `dynamodb`, `iam`, `sts`) and sets the default region to `eu-north-1`.

```yml
services:
  setup-localstack-service:
    image: localstack/localstack
    ports:
      - '4566:4566'
    env:
      SERVICES: 's3,dynamodb,iam,sts'
      DEFAULT_REGION: eu-north-1
      FORCE_NONINTERACTIVE: 1
      AWS_ACCESS_KEY_ID: test
      AWS_SECRET_ACCESS_KEY: test
```


#### Steps

```yml
steps:
  - name: Checkout Repository
    uses: actions/checkout@v2

  - name: Setup Terraform
    uses: hashicorp/setup-terraform@v2
    with:
      terraform_version: 1.3.4

  - name: Copy Override File
    run: |
      cp tests/integration/_override.tf src/mlstacks/terraform/aws-remote-state/_override.tf

  - name: Apply Terraform Configuration for aws-remote-state
    run: |
      export TF_CLI_ARGS_apply="-compact-warnings"
      cd src/mlstacks/terraform/aws-remote-state
      terraform init -backend-config="path=./terraform.tfstate"
      terraform validate
      terraform apply -auto-approve -var-file="../../../../tests/integration/aws-remote-state/local.tfvars"

  - name: Run Tests to Verify Resource Provisioning
    run: ./tests/integration/aws-remote-state/verify_stack.sh
    env:
      AWS_ACCESS_KEY_ID: test
      AWS_SECRET_ACCESS_KEY: test
      AWS_DEFAULT_REGION: eu-north-1

  - name: Cleanup Resources for aws-remote-state
    run: |
      cd src/mlstacks/terraform/aws-remote-state
      terraform destroy -auto-approve -var-file="../../../../tests/integration/aws-remote-state/local.tfvars"
      rm -rf .terraform
      rm -rf volume
      rm -f .terraform.lock.hcl
      rm -f terraform.tfstate
      rm -f terraform.tfstate.backup
      rm -f localstack_providers_override.tf

  - name: Ensure _override.tf Deletion
    if: always()
    run: |
      rm -f src/mlstacks/terraform/aws-remote-state/_override.tf
    working-directory: ${{ github.workspace }}
```

- **Setup Terraform**: Prepares the Terraform environment.
- **Copy Override File**: Copies the `_override.tf` file into the `aws-remote-state` directory to ensure Terraform operations target the LocalStack environment.
- **Apply Terraform Configuration**: Navigates to the `aws-remote-state` directory, initializes Terraform with LocalStack as the backend, validates the configuration, and applies it using a `.tfvars` file.
- **Run Tests**: Executes a bash script to verify resource provisioning.
- **Cleanup Resources**: Destroys provisioned resources and cleans up Terraform-related files.
- **Ensure `_override.tf` Deletion**: Ensures the copied `_override.tf` file is removed after job completion.

## Conclusion

In this documentation, we covered:

- Setting up LocalStack for local emulation of AWS services.
- Installing and starting LocalStack using various methods.
- Using `awslocal` for simplified AWS service interaction.
- Integrating Terraform with LocalStack using override files and `.tfvars` files for resource provisioning.
- Integrating Terraform with LocalStack using `tflocal` and `.tfvars` files as an alternative.
- Configuring GitHub Actions for AWS integration testing with LocalStack.

## Links

- [LocalStack Documentation](https://docs.localstack.cloud/getting-started/)
- [LocalStack Installation Guide](https://docs.localstack.cloud/getting-started/installation/)
- [LocalStack GitHub Actions Integration Guide](https://docs.localstack.cloud/user-guide/ci/github-actions/)
- [LocalStack terraform-local (`tflocal`) integration](https://docs.localstack.cloud/user-guide/integrations/terraform/)
- [terraform-local package](https://github.com/localstack/terraform-local)
- [Override Files Terraform Documentation](https://developer.hashicorp.com/terraform/language/files/override)
- [`.tfvars` documentation](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files)
- [awscli-local package](https://github.com/localstack/awscli-local)