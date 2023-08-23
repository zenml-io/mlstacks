# Troubleshoot Known Problems

These are some known problems that might arise out of running `mlstacks`. Errors
for mlstacks deployments are usually related to changes that you might have made
independently of the original recipes or they might also relate to network or
permissions issues.

Usually the quickest way to start afresh is to run `mlstacks clean`, but note that
this will also delete deployments that you might have made using `mlstacks`.

You can also try to debug the problem by running the terraform commands from
within the `mlstacks` config directory where the Terraform definition files are
stored.

You can also run the `mlstacks` commands with the `--debug` flag to get more
information and decision points along the way.

## Other known problems

These are issues that sometimes get raised in the underlying Terraform
implementation:

- Running a Kubernetes-based deployment for the first time might result in an
  error with one of the resources - the Istio Ingressway. This is because of a
  limitation with the resource `kubectl_manifest` that needs the cluster to be
  set up before it installs its own resources. 💡 Fix - Run `terraform apply`
  again in a few minutes and this should get resolved.

- When executing terraform commands, an error like this one:
  `timeout while waiting for plugin to start` \
   💡 Fix - If you encounter this error with `apply`, `plan` or `destroy`, do
  `terraform init` and run your command again.

- While running `terraform init`, an error which says
  `Failed to query available provider packages... No available releases match the given constraint`
  \
   💡 Fix - First of all, you should create an issue so that we can take a look.
  Meanwhile, if you know Terraform, make sure all the modules that are being
  used are on their latest version.

- While running a Terraform command, this error might appear too:
  `context deadline exceeded` \
   💡 Fix - This problem could arise due to strained system resources. Try
  running the command again after some time.
