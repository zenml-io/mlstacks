# How to write specification files

## Stack specification

The core of a stack is the `stack.yaml` file. This file contains all the
information needed to deploy a stack. It contains the following fields:

```yaml
spec_version: 1
spec_type: stack
name: <STACK_NAME>
provider: <YOUR_PROVIDER>
default_region: <REGION_NAME>
default_tags:
  - <TAG_KEY>: <TAG_VALUE>
components:
  - <COMPONENT_FILENAME_GOES_HERE>
```

Let's go through each of these fields in detail.

### `spec_version`

This field defines the version of the `mlstacks` specification that this stack
uses. This is currently `1`.

### `spec_type`

This field defines the type of the specification. This is currently `stack`.

### `name`

This field defines the name of the stack. This is used to identify the stack
when deploying, destroying, or getting outputs from the stack.

### `provider`

This field defines the provider that the stack will be deployed to. This is
currently one of `k3d`, `gcp`, or `aws`.

### `default_region`

This field defines the default region that the stack will be deployed to. If you
specify a region that doesn't exist for your particular provider, the stack
deployment will fail.

### `default_tags`

This field defines the default tags that will be applied to all resources
created by the stack. This is useful for identifying resources created by the
stack.

This is an optional field.

### `components`

This field defines the components that will be deployed by the stack. This is a
list of component filenames.

## Component specification

The core of a component is the `component.yaml` file. This file contains all the
information needed to deploy a component. It contains the following fields:

```yaml
spec_version: 1
spec_type: component
component_type: <COMPONENT_TYPE>
component_flavor: <COMPONENT_FLAVOR>
name: <COMPONENT_NAME>
provider: <YOUR_PROVIDER>
metadata:
  config:
    <CONFIG_KEY>: <CONFIG_VALUE>
  tags:
    <TAG_KEY>: <TAG_VALUE>
  region: <REGION_NAME>
```

Let's go through each of these fields in detail.

### `spec_version`

This field defines the version of the `mlstacks` specification that this
component uses. This is currently `1`.

### `spec_type`

This field defines the type of the specification. This is currently `component`.

### `component_type`

This field defines the type of the component. Available component types
currently include:

- `artifact_store`: An artifact store is a component that can be used to store
  artifacts.
- `container_registry`: A container registry is a component that can be used to
  store container images.
- `experiment_tracker`: An experiment tracker is a component that can be used to
  track experiments.
- `orchestrator`: An orchestrator is a component that can be used to orchestrate
  pipelines.
- `mlops_platform`: An MLOps platform is a component that can be used to
  orchestrate pipelines, track experiments, and manage the overall connection of
  MLOps components and tools together.
- `model_deployer`: A model deployer is a component that can be used to deploy
  models.
- `step_operator`: A step operator is a component that can be used to execute
  steps in a pipeline using custom hardware or platforms.

### `component_flavor`

This field defines the flavor of the component. This is used to differentiate
between different implementations of the same component type. For example, the
`artifact_store` component type has the following flavors:

- `minio`: A MinIO artifact store.
- `s3`: An S3 artifact store.
- `gcp`: A GCP/GCS artifact store.

### `name`

This field defines the name of the component. This is used to identify the
component when deploying, destroying, or getting outputs from the component.

### `provider`

This field defines the provider that the component will be deployed to. This is
currently one of `k3d`, `gcp`, or `aws`.

### `metadata`

This field defines the metadata of the component. This is a dictionary with the
following fields:

#### `config`

This field defines the configuration of the component. This is a dictionary you
can pass in arbitrary fields to configure the component. For example for an
artifact store, as shown
[in the quickstart examples](../getting-started/gcp.md), you can pass in a
`bucket_name` field to configure the bucket name of the artifact store.

Config is usually optional (except in the case of GCP deployments when you need
to specify a `project_id`.)

#### `tags`

This field defines the tags of the component. This is a dictionary you can pass
in arbitrary fields to tag the component. For example for an artifact store, as
shown [in the quickstart examples](../getting-started/gcp.md), you can pass in a
`deployed-by` key and a `mlstacks` value to tag the artifact store with the
deployer.

Tags are optional.

#### `region`

This field defines the region of the component. This is a string that defines
the region that the component will be deployed to. If you specify a region that
doesn't exist for your particular provider, the component deployment will fail.
