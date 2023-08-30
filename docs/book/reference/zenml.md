# 🙏 Association with ZenML

[![maintained-by-zenml](https://user-images.githubusercontent.com/3348134/173032050-ad923313-f2ce-4583-b27a-afcaa8b355e2.png)](https://github.com/zenml-io/zenml)

It is not necessary to use the MLOps stacks recipes presented here alongside the
[ZenML](https://github.com/zenml-io/zenml) framework, but it is highly
recommended to do so. The ZenML framework is designed to be used with these
recipes, and the recipes are designed to be used with ZenML.

The ZenML CLI has an integration with this package that makes it really simple
to use and deploy these recipes. For more information,
[visit the ZenML documentation](https://docs.zenml.io/stacks-and-components/stack-deployment)
for more but a quick example is shown below.

```shell
# after installing ZenML
zenml stack deploy -p gcp -a -n basic -r us-east1 -t env=dev -x bucket_name=my-new-bucket -x project_id=zenml
```

This command will deploy a GCP artifact store to `us-east1` region with a
specific bucket name, project ID and tag, for example.

To learn more about ZenML and how it empowers you to develop a stack-agnostic
MLOps solution, head over to the [ZenML docs](https://docs.zenml.io).

## Importing `mlstacks` stacks into ZenML

The ZenML CLI also has a command to import stacks created with `mlstacks` into
ZenML. All stacks created with `mlstacks` generate a `.yaml` file that can be
imported into ZenML with the following command:

```shell
# after installing ZenML
zenml stack import -f <path-to-stack-file.yaml>
```

The path of the stack file can be found by navigating to the directory
containing all the Terraform source files. You can easily find this by running
the following command:

```shell
mlstacks source
```

This will print the path to the directory containing all the Terraform source
and will ask you if you want to open the directory in your default file
explorer. You can then navigate to the `.yaml` file and use that path to import
it into ZenML as described above.
