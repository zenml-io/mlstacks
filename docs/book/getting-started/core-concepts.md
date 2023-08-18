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

- `artifact_store`: An artifact store is a component that can be used to store
  artifacts. (e.g. S3 buckets on AWS)
- `container_registry`: A container registry is a component that can be used to
  store container images. (e.g. ECR on AWS)
- `experiment_tracker`: An experiment tracker is a component that can be used to
  track experiments, including metrics, parameters, and artifacts. (e.g. MLFlow)
- `orchestrator`: An orchestrator is a component that can be used to orchestrate
  machine learning pipelines. (e.g. Airflow)
- `mlops_platform`: An MLOps platform is a component that can be used to deploy,
  monitor, and manage machine learning models. (e.g. ZenML)
- `model_deployer`: A model deployer is a component that can be used to deploy
  machine learning models. (e.g. Seldon Core)
- `step_operator`: A step operator is a component that can be used to execute
  steps that require custom hardware.

## How does MLStacks work?

MLStacks is built around the concept of a stack specification. A stack
specification is a YAML file that describes the stack and includes references to
component specification files. A component specification is a YAML file that
describes a component. (Currently all deployments of components (in various
combinations) must be defined within the context of a stack.)

Once you write your stack specification, you can then use MLStacks' CLI to
deploy your stack to your preferred cloud (or local K3d) provider. Terraform
definitions and state are stored in your global configuration directory along
with any state files generated while deploying your stack.

Your configuration directory could be in a number of different places depending
on your operating system, but read more about it in the
[Click docs](https://click.palletsprojects.com/en/8.1.x/api/#click.get_app_dir)
to see which location applies to your situation.
