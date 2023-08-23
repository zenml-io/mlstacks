# Usage Analytics

In order to help us better understand how the community uses ZenML, the pip
package reports anonymized usage statistics. You can always opt-out by setting
the `MLSTACKS_ANALYTICS_OPT_OUT` environment variable to `True`:

```bash
export MLSTACKS_ANALYTICS_OPT_OUT=True
```

## Why does MLStacks collect analytics?

In addition to the community at large, MLStacks is created and maintained by a
startup based in Munich, Germany called [ZenML GmbH](https://zenml.io/). We're a
team of techies that love MLOps and want to build tools that fellow developers
would love to use in their daily work.
[This is us](https://zenml.io/company#CompanyTeam) if you want to put faces to
the names!

However, in order to improve MLStacks and understand how it is being used, we
use analytics to have an overview of how it is used 'in the wild'. This not only
helps us find bugs but also helps us prioritize features and commands that might
be useful in future releases. If we did not have this information, all we really
get is `pip` download statistics and chatting with people directly, which while
being valuable, is not enough to seriously better the tool as a whole.

## How does MLStacks and ZenML collect these statistics?

MLStacks uses [Segment](https://segment.com/) as the data aggregation library
for all our analytics. The entire code is entirely visible and can be seen at
[client.py](https://github.com/zenml-io/mlstacks/blob/main/src/mlstacks/analytics/client.py).

None of the data sent can identify you individually but allows us to understand
how MLStacks is being used holistically.
