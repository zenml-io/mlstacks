from typing import Dict, List
import python_terraform
from mlstacks.models.component import Component
from mlstacks.models.stack import Stack


class TerraformRunner:
    def __init__(self, tf_recipe_path):
        self.tf_recipe_path = tf_recipe_path

        self.client = python_terraform.Terraform(
            working_dir=self.tf_recipe_path,
        )


def parse_component_variables(components: List[Component]) -> Dict[str, str]:
    component_variables = {}
    for component in components:
        if (
            component.component_type == "artifact_store"
            and component.metadata.config
        ):
            component_variables["bucket_name"] = component.metadata.config.get(
                "bucket_name"
            )
            component_variables["enable_artifact_store"] = "true"
        # extract the logic for each different component type
        # add those variables to the component_variables dict

    return component_variables


def parse_tf_vars(stack: Stack) -> Dict[str, str]:
    tf_vars = {
        "region": stack.default_region,
        "tags": stack.default_tags,
    }
    # update the dict with the component variables
    tf_vars.update(parse_component_variables(stack.components))
    return tf_vars
