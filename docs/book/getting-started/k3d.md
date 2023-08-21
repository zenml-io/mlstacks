# Quickstart on K3D

TKTKTK: WHAT THE STACK IS / INVOLVES

![DIAGRAM GOES HERE]()

## Prerequisites

First, install the `mlstacks` CLI:

```bash
pip install mlstacks
```

You will need to have K3D installed. Please visit the
[K3D docs](https://k3d.io/) for installation instructions.

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
provider: k3d
default_region: "local"
default_tags:
  deployed-by: "mlstacks"
components:
  - simple_component_minio.yaml
```

This defines our stack using the `mlstacks` specification. We'll now define the
component that we want to deploy in a separate file called
`simple_component_minio.yaml`:

```yaml
spec_version: 1
spec_type: component
component_type: "artifact_store"
component_flavor: "minio"
name: "quickstart_minio_bucket"
provider: k3d
metadata:
  config:
    bucket_name: "quickstart_minio_bucket"
  tags:
    deployed-by: "mlstacks"
  region: "local"
```

## Deploying our stack

Now, we can deploy our stack using the `mlstacks` CLI:

```bash
mlstacks deploy -f quickstart_stack.yaml
```

This will deploy our stack to a local K3D cluster. You can now check your K3D
console to see that the stack and the minio bucket has been deployed.

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

## What next?

You can now try adding more components and deploying them to this K3D provider.
You can also try deploying your stack to an actual cloud provider instead of
this local environment.

Good luck! And if you have any questions, feel free to
[reach out to us on Slack](https://www.zenml.io/slack-invite)
