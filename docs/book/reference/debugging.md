## Troubleshoot Known Problems

These are some known problems that might arise out of running this recipe. Some
of these are terraform commands but running `zenml stack recipe apply` would
also achieve similar results as `terraform init` and `terraform apply`.

- Running the script for the first time might result in an error with one of the
  resources - the Istio Ingressway. This is because of a limitation with the
  resource `kubectl_manifest` that needs the cluster to be set up before it
  installs its own resources. \
   💡 Fix - Run `terraform apply` again in a few minutes and this should get
  resolved.

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

- While running a terraform command, this error might appear too:
  `context deadline exceeded` \
   💡 Fix - This problem could arise due to strained system resources. Try
  running the command again after some time.
