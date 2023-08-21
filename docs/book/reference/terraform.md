# Using mlstacks with Terraform

MLStacks uses Terraform under the hood to deploy and destroy the infrastructure
that you specify in your stack specification files. We specifically designed the
interface to conceal the Terraform implementation details from you, but if you
want to use Terraform directly, you can do so.

## Where are the Terraform files stored?

You can download our modular recipes by cloning our GitHub repository:

```bash
git clone https://github.com/zenml-io/mlstacks.git
```

The specific directory you want to look at is `src/mlstacks/terraform`.

## Terraform next steps

If you want to use Terraform directly, you can simply navigate to the root of
one of the `xxx-modular` directories and run (for example) `terraform init` to
initialize the Terraform directory. You can then run `terraform plan` to see
what Terraform will do, and `terraform apply` to apply the changes.

You are free to remix and use the Terraform modules and recipes as you see fit,
but please note that this is not a core use case for MLStacks and you might no
longer be able to use the MLStacks CLI to manage your stacks any more.
