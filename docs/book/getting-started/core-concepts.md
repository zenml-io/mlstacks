# Core Concepts

MLStacks is built around common concepts that are used to describe
infrastructure for machine learning and MLOps. This section will introduce you
to these concepts and how they are used in MLStacks.

## What's a stack?

A Stack is a collection of stack components, where each component represents the
respective configuration regarding a particular function in your MLOps pipeline
such as orchestration systems, artifact repositories, and model deployment
platforms.

As a shorthand, you can think of a stack as a grouping of these components.

## What's a component?

Components are the building-blocks of stacks. MLStacks currently supports the
following stack components:

- `artifact_store`: An [artifact store](https://docs.zenml.io/stacks-and-components/component-guide/artifact-stores) is a component that can be used to store
  artifacts. (e.g. S3 buckets on AWS)
- `container_registry`: A [container registry](https://docs.zenml.io/stacks-and-components/component-guide/container-registries) is a component that can be used to
  store container images. (e.g. ECR on AWS)
- `experiment_tracker`: An [experiment tracker](https://docs.zenml.io/stacks-and-components/component-guide/experiment-trackers) is a component that can be used to
  track experiments, including metrics, parameters, and artifacts. (e.g. MLFlow)
- `orchestrator`: An [orchestrator](https://docs.zenml.io/stacks-and-components/component-guide/orchestrators) is a component that can be used to orchestrate
  machine learning pipelines. (e.g. Airflow)
- `mlops_platform`: An MLOps platform is a component that can be used to deploy,
  monitor, and manage machine learning models. (e.g. ZenML)
- `model_deployer`: A [model deployer](https://docs.zenml.io/stacks-and-components/component-guide/model-deployers) is a component that can be used to deploy
  machine learning models. (e.g. Seldon Core)
- `step_operator`: A [step operator](https://docs.zenml.io/stacks-and-components/component-guide/step-operators) is a component that can be used to execute
  steps that require custom hardware.

## How does MLStacks work?

MLStacks is built around the concept of a stack specification. A stack
specification is a YAML file that describes the stack and includes references to
component specification files. A component specification is a YAML file that
describes a component. (Currently all deployments of components (in various
combinations) must be defined within the context of a stack.)

Once you write your stack specification, you can then use MLStacks' CLI to
deploy your stack to your preferred cloud (or local K3d) provider. Terraform
definitions are stored in your global configuration directory. MLStacks allows
you to deploy or connect to a remote state store (e.g. S3, GCS, etc.) so that
you can collaborate on your stacks and deployed infrastructure with your
colleagues.

Your global configuration directory could be in a number of different places depending
on your operating system, but read more about it in the
[Click docs](https://click.palletsprojects.com/en/8.1.x/api/#click.get_app_dir)
to see which location applies to your situation. This is where the stack specs
and the Terraform definition files are located.
