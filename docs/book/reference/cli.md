# Using MLStacks via the CLI

MLStacks is a CLI tool that allows you to deploy and manage your ML
infrastructure using the MLStacks specification. You can install the CLI using
the following command:

```bash
pip install mlstacks
```

## Deploying a stack

You can deploy a stack using the `mlstacks deploy` command. This command takes a
path to a stack specification file as an argument. For example, if you have a
stack specification file called `stack.yaml`, you can deploy it using the
following command:

```bash
mlstacks deploy -f stack.yaml
```

If you want to drop into the internal Terraform log messages and prompts, turn
on debug mode with the `-d` or `--debug` flag:

```bash
mlstacks deploy -f stack.yaml -d
```

## Using remote state with a team

MLStacks deploys a remote state bucket to the same cloud provider as you're
using for your stack by default. This remote state backend has a default name
that begins with `zenml-mlstacks-remote-state` and is deployed first before your
stack gets deployed.

If you'd like to connect to a pre-existing state bucket that you or a colleague
have already created, you can do so by passing the bucket name to the
`mlstacks deploy` command:

```bash
mlstacks deploy -f stack.yaml -rb <BUCKET_NAME_GOES_HERE>
# e.g. mlstacks deploy -f stack.yaml -rb s3://zenml-mlstacks-remote-state-3d3r6
```

This will then connect to the remote state bucket and use that as the backend
for your stack deployment.

## Getting stack outputs

Once you have a stack deployed, you can get the outputs of the stack using the
`mlstacks output` command. This command takes a path to a stack specification
file as an argument. For example, if you have a stack specification file called
`stack.yaml`, you can get the outputs of the stack using the following command:

```bash
mlstacks output -f stack.yaml
```

This will print out the outputs of the stack, which you can use in your
pipelines. If you just want a single output you can add the `-k` or `--key`
option and pass in the name of the output you want:

```bash
mlstacks output -f stack.yaml -k my_key
```

## Destroying a stack

You can destroy a stack using the `mlstacks destroy` command. This command takes
a path to a stack specification file as an argument. For example, if you have a
stack specification file called `stack.yaml`, you can destroy it using the
following command:

```bash
mlstacks destroy -f stack.yaml
```

If you want to drop into the internal Terraform log messages and prompts, turn
on debug mode with the `-d` or `--debug` flag:

```bash
mlstacks destroy -f stack.yaml -d
```

## Stack Cost Estimation with Infracost

MLStacks integrates with [Infracost](https://www.infracost.io/) to provide cost
estimates for your stacks. You can install Infracost by following the
instructions in their documentation. Note that you'll need to be logged in to
use it with `mlstacks`.

Once you have Infracost installed, you can get a cost estimate for your stack
using the `mlstacks breakdown` command. This command takes a path to a stack
specification file as an argument. For example, if you have a stack
specification file called `stack.yaml`, you can get a cost estimate for it using
the following command:

```bash
mlstacks breakdown -f stack.yaml
```

This will print out a cost estimate for your stack.

## Viewing Terraform definitions and Stack Specifications

If you'd like to view the Terraform definitions that MLStacks generates for your
stack, you can use the `mlstacks source` command. This command will print out
the location of the Terraform definitions for your stack.

```bash
mlstacks source
```

## Cleaning Up

If you want to clean up all the files and directories created by MLStacks, you
can use the `mlstacks clean` command. This works at a global level (i.e.
affecting all stacks), so you don't need to pass in a stack specification file.

```bash
mlstacks clean
```

## Check your mlstacks version

To see what version of `mlstacks` package you're using, please use the following
command:

```bash
mlstacks version
```
