# Quickstart on GCP

TKTKTK: WHAT THE STACK IS / INVOLVES

![DIAGRAM GOES HERE]()

## Prerequisites

First, install the `mlstacks` CLI:

```bash
pip install mlstacks
```

You'll need an active GCP account and project to get started. (If you don't have
one, you can create one
[following these instructions](https://developers.google.com/workspace/guides/create-project).
You will also need sufficient permissions to be able to create and destroy
resources.

If you don't have
[Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform)
or [Helm](https://helm.sh/docs/intro/install/#from-script) installed, you should
also install them.

## Defining our stack

Then, create a file called `quickstart_stack.yaml` wherever you have access to
the `mlstacks` tool. In this file, add the following:

```yaml
spec_version: 1
spec_type: stack
name: "quickstart_stack"
provider: gcp
default_region: "europe-north1"
default_tags:
  deployed-by: "mlstacks"
components:
  - simple_component_gcs.yaml
```

This defines our stack using the `mlstacks` specification. We'll now define the
component that we want to deploy in a separate file called
`simple_component_gcs.yaml`:

```yaml
spec_version: 1
spec_type: component
component_type: "artifact_store"
component_flavor: "gcp"
name: "quickstart_gcs_bucket"
provider: gcp
metadata:
  config:
    bucket_name: "quickstart_gcs_bucket"
    project_id: "<YOUR_GCP_PROJECT_ID_HERE>"
  tags:
    deployed-by: "mlstacks"
  region: "eu-north1"
```

## Deploying our stack

Now, we can deploy our stack using the `mlstacks` CLI:

```bash
mlstacks deploy -f quickstart_stack.yaml
```

This will deploy our stack to GCP. You can now check your GCP console to see
that the stack has been deployed.

## Get stack outputs

You can get the outputs of your stack using the `mlstacks` CLI:

```bash
mlstacks output -f quickstart_stack.yaml
```

This will print out the outputs of your stack, which you can use in your
pipelines.

## Destroying our stack

Finally, we can destroy our stack using the `mlstacks` CLI:

```bash
mlstacks destroy -f quickstart_stack.yaml
```
