# 👋 Introduction

## 🌰 In a nutshell: What is MLStacks?

MLStacks is a Python package that allows you to quickly spin up MLOps
infrastructure using Terraform. It is designed to be used with
[ZenML](https://zenml.io), but can be used with any MLOps tool or platform.

Simply write stack and component YAML specification files and deploy them using
the MLStacks CLI. MLStacks will take care of the rest. We currently support
modular MLOps stacks on AWS, GCP and K3D (for local use).

## 👷 Why We Built MLStacks

[![maintained-by-zenml](https://user-images.githubusercontent.com/3348134/173032050-ad923313-f2ce-4583-b27a-afcaa8b355e2.png)](https://github.com/zenml-io/zenml)

When we first created [ZenML](https://zenml.io) as an extensible MLOps framework
for creating portable, production-ready MLOps pipelines, we saw many of our
users having to deal with the pain of deploying infrastructure from scratch to
run these pipelines. The community consistently asked questions like:

- How do I deploy tool X with tool Y?
- Does a combination of tool X with Y make sense?
- Isn't there an easy way to just try these stacks out to make an informed
  decision?

To address these questions, the ZenML team presents you a series of
Terraform-based stacks to quickly provision popular combinations of MLOps tools.
These stacks will be useful for you if:

- You are at the start of your MLOps journey, and would like to explore
  different tools.
- You are looking for guidelines for production-grade deployments.
- You would like to run your MLOps pipelines on your chosen
  [ZenML Stack](https://docs.zenml.io/user-guide/starter-guide/understand-stacks).

🔥 **Do you use these tools or do you want to add one to your MLOps stack?** At
ZenML, we are looking for design partnerships and collaboration to implement and
develop these MLOps stacks in a real-world setting.

If you'd like to learn more, please
[join our Slack](https://zenml.io/slack-invite/) and leave us a message!

## 🤓 Learn More

- Try the [Quickstart example below](./getting-started/) to get started with
  MLStacks.
- Discover what you can configure with the different stacks in the
  [Stacks documentation](./stacks/).
- Learn about our CLI commands in the [CLI documentation](./reference/cli.md).

## 🙏🏻 Acknowledgements

Thank you to the folks over at [Fuzzy Labs](https://www.fuzzylabs.ai/) for their
support and contributions to this repository. Also many thanks to
[Ali Abbas Jaffri](https://github.com/aliabbasjaffri) for several stimulating
discussions around the architecture of this project.

We'd also like to acknowledge some of the cool inspirations for this project:

- [FuseML](https://fuseml.github.io/)
- [Combinator.ML](https://combinator.ml/)
- [Building a ML Platform From Scratch](https://www.aporia.com/blog/building-an-ml-platform-from-scratch/)
