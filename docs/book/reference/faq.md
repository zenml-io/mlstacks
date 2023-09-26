# Frequently Asked Questions (FAQ)

## What are the benefits of using mlstacks?

MLStacks is a tool for deploying infrastructure to cloud providers. It is
designed to make it easy to deploy and manage infrastructure for machine
learning. It is built on top of [Terraform](https://www.terraform.io/), which
means that it is cloud-agnostic and can be used to deploy infrastructure to any
cloud provider that Terraform supports.

MLStacks is designed and developed by a team that live and breathe MLOps. This
means that it is designed to support the full range of infrastructure that you
might need for your MLOps tooling. It is also designed to be modular, which
means that you can easily mix and match different components to create the
infrastructure that you need.

## What are the tradeoffs of using mlstacks?

MLStacks is currently a project in beta. This means that it is still under
active development and may have some rough edges. We are working hard to make it
production-ready as soon as possible, but in the meantime, you may encounter
some bugs or missing features.

In particular, not all cloud providers and stack components are supported out of
the box with the modular recipes that come with MLStacks. If you want to deploy
to a cloud provider or use a stack component that is not supported, you will
need to write your own recipe. We are working hard to add support for more cloud
providers and stack components, but in the meantime, you can use the existing
recipes as a starting point for writing your own.

## What are the alternatives to mlstacks?

There are lots of ways to deploy infrastructure to cloud providers that span the
full spectrum from manual to automated. MLStacks uses
[Terraform](https://www.terraform.io/) as its backend for configuring and
deploying infrastructure, but there are other tools that can help with this like
[Pulumi](https://www.pulumi.com/) or cloud-specific tools like
[AWS CloudFormation](https://aws.amazon.com/cloudformation).

## What's the connection between mlstacks and ZenML?

MLStacks is developed and maintained by the core ZenML team. It is designed to
work (well) with ZenML, but it can also be used independently of ZenML.

## Can I use mlstacks independently of ZenML?

Yes! You can use MLStacks to deploy infrastructure for any MLOps tooling you
like and it is designed to offer a range of components and flavors to support
the full variety of MLOps tools.

## How do I use mlstacks within a team setting?

MLStacks is designed to be used in a team setting. It is designed to support
the full range of infrastructure that you might need for your MLOps tooling. We
also spin up a remote state backend with every deployment (unless you're
connecting to one that already exists) so that other team members can
collaborate on your stacks and deployed infrastructure. Please see the section
of the docs on [using remote state](../reference/cli.md#using-remote-state) for more information.
