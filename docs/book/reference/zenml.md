# 🙏 Association with ZenML

[![maintained-by-zenml](https://user-images.githubusercontent.com/3348134/173032050-ad923313-f2ce-4583-b27a-afcaa8b355e2.png)](https://github.com/zenml-io/zenml)

It is not necessary to use the MLOps stacks recipes presented here alongside the
[ZenML](https://github.com/zenml-io/zenml) framework, but it is highly
recommended to do so. The ZenML framework is designed to be used with these
recipes, and the recipes are designed to be used with ZenML.

However, ZenML works seamlessly with the infrastructure provisioned through
these recipes. The ZenML CLI has an integration with this package that makes it
really simple to use and deploy these recipes. For more information,
[visit the ZenML documentation](https://docs.zenml.io/stacks-and-components/stack-deployment)
for more but a quick example is shown below.

```shell
# after installing ZenML
zenml stack deploy -p gcp -a -n basic -r us-east1 -t env=dev -x bucket_name=zenml-goes-pypi -x project_id=zenml-core
```

This command will deploy a GCP artifact store to `us-east1` region with a
specific bucket name, project ID and tag, for example.

To learn more about ZenML and how it empowers you to develop a stack-agnostic
MLOps solution, head over to the [ZenML docs](https://docs.zenml.io).
