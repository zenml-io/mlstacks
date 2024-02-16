# Integrating Local Testing of AWS Deployments in MLStacks Using LocalStack

## Prerequisites
- Docker
- AWS CLI
- Terraform

## LocalStack

LocalStack is a powerful tool that simulates AWS cloud services on your local machine, providing a development environment that closely mirrors the live AWS environment without incurring the costs associated with real AWS services. It supports a wide range of AWS services, allowing you to test various deployment configurations before pushing them to AWS. For more information and a complete guide on how to use LocalStack, visit the [LocalStack Documentation](https://docs.localstack.cloud/getting-started/).
### Installation

Installation can be done via Homebrew, PIP, Docker CLI, or Docker Compose. For detailed instructions, refer to the [LocalStack Installation Guide](https://docs.localstack.cloud/getting-started/installation/).

**Using Homebrew:**
```bash
brew install localstack/tap/localstack-cli
```

**Using PIP:**
```bash
python -m venv .venv
source .venv/bin/activate
pip install localstack
```

**Using Docker CLI:**
```bash
docker run --rm -it -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack
```

**Using Docker Compose:**
Refer to the [LocalStack Docker Compose guide](https://docs.localstack.cloud/getting-started/installation/#starting-localstack-with-docker-compose).

### Starting LocalStack

Before starting LocalStack, ensure Docker is running. LocalStack can be started in detached mode, accessible at port 4566.

```bash
localstack start -d
```

Example command to create an S3 bucket:

```bash
aws --endpoint-url=http://localhost:4566 s3 mb mybucket
```

### Setting up LocalStack's AWS CLI (optional)

The [awscli-local](https://github.com/localstack/awscli-local) package simplifies interactions with LocalStack by providing the `awslocal` command, which automatically targets LocalStack's endpoints.

**Installation**

```bash
pip install awscli-local
```

**Usage Examples**

Create an S3 bucket:
```bash
awslocal s3 mb s3://test-bucket
```

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
> Most AWS services require specifying the region when using LocalStack, except for S3, which is globally accessible.


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

This documentation outlines the GitHub Actions workflow designed for comprehensive integration testing of AWS deployments within MLStacks using LocalStack. The workflow consists of two main jobs: `aws_remote_state_integration_test` and `aws_modular_integration_test`, each responsible for provisioning AWS resources in a local testing environment and verifying their setup.

The actual provisioning of resources leverages `terraform-local`

### terraform-local

`terraform-local` is a package that provides the `tflocal` command, a tool that adapts Terraform commands for use within the LocalStack environment, and eliminates the need for manual endpoint configuration. In our framework, `tflocal` is utilized to ensure AWS resources are provisioned in a simulated environment for integration testing.

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

  - name: Install terraform-local
    run: pip install terraform-local

  - name: Apply Terraform Configuration for aws-remote-state
    run: |
      cd src/mlstacks/terraform/aws-remote-state
      tflocal init
      tflocal validate
      tflocal apply -auto-approve -var-file="../../../../tests/integration/aws-remote-state/local.tfvars"

  - name: Run Tests to Verify Resource Provisioning
    run: ./tests/integration/aws-remote-state/verify_stack.sh

  - name: Cleanup Resources for aws-remote-state
    run: |
      cd src/mlstacks/terraform/aws-remote-state
      tflocal destroy -auto-approve -var-file="../../../../tests/integration/aws-remote-state/local.tfvars"
      rm -rf .terraform
      rm -rf volume
      rm -f .terraform.lock.hcl
      rm -f terraform.tfstate
      rm -f terraform.tfstate.backup
```

- **Install terraform-local**: Installs `terraform-local` for the `tflocal` command, integrating Terraform with LocalStack.
- **Apply Terraform Configuration**: Navigates to the `aws-remote-state` directory, initializes Terraform with LocalStack as the backend, validates the configuration, and applies it using a `.tfvars` file.
- **Run Tests**: Executes a bash script to verify resource provisioning.
- **Cleanup Resources**: Destroys provisioned resources and cleans up Terraform-related files.

### AWS Modular Integration Test

This job tests the provisioning of a more complex AWS setup, including the optional SkyPilot orchestrator, within the `aws-modular` configuration.
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

#### Key Steps Overview

The procedure mirrors that of the `aws_remote_state_integration_test`, with adjustments targeting the `aws-modular` directory. It also utilizes a distinct `.tfvars` file located within `tests/integration/aws-modular` for configuration.

```yml
steps:
  - name: Checkout Repository
    uses: actions/checkout@v2

  - name: Install terraform-local
    run: pip install terraform-local

  - name: Apply Terraform Configuration for aws-modular
    run: |
      cd src/mlstacks/terraform/aws-modular
      tflocal init -backend-config="path=./terraform.tfstate"
      tflocal validate
      tflocal apply -auto-approve -var-file="../../../../tests/integration/aws-modular/local.tfvars"

  - name: Run Tests to Verify Resource Provisioning
    run: |
      STACK_YAML_PATH=$(terraform output -raw stack-yaml-path)
      ../../../../tests/integration/aws-modular/verify_stack.sh "$STACK_YAML_PATH"

  - name: Cleanup Resources for aws-modular
    run: |
      cd src/mlstacks/terraform/aws-modular
      tflocal destroy -auto-approve -var-file="../../../../tests/integration/aws-modular/local.tfvars"
      rm -rf .terraform
      rm -rf volume
      rm -f .terraform.lock.hcl
      rm -f terraform.tfstate
      rm -f terraform.tfstate.backup
      rm -f aws_modular_stack_*.yaml 
```

- **Apply Terraform Configuration**: 
  - Initializes Terraform with an explicit backend configuration to use a local `terraform.tfstate` file.
  
    > Here, the use of `-backend-config` with `tflocal init` is a specific workaround due to the module's backend configuration.
    > Without this specification, an "Unsupported argument" error occurs due to a syntax or configuration issue in the `terraform.tf` file on line 42: `config = {}`.
   
  - Applies configuration for `aws-modular` using a `.tfvars` file

   

- **Run Tests**:
	- This step captures the YAML file's path, generated by the Terraform apply process, into a variable. 
	- It then utilizes this path to run a bash script to verify the provisioning and configuration of resources.

## Conclusion

In this documentation, we covered:

- Setting up LocalStack for local emulation of AWS services.
- Installing and starting LocalStack using various methods.
- Using `awslocal` for simplified AWS service interaction.
- Integrating Terraform with LocalStack using `tflocal` and `.tfvars` files for resource provisioning.
- Configuring GitHub Actions for AWS integration testing with LocalStack.