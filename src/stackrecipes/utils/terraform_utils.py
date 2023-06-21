from typing import Dict
import python_terraform
from stackrecipes.models.stack import Stack


class TerraformRunner:
    def __init__(self, tf_recipe_path):
        self.tf_recipe_path = tf_recipe_path

        self.client = python_terraform.Terraform(
            working_dir=self.tf_recipe_path,
        )

def parse_component_variables(components: List[Component]) -> Dict[str, str]:
    component_variables = {}
    for component in components:
        # extract the logic for each different component type
        # add those variables to the component_variables dict

    return component_variables


def parse_tf_vars(stack: Stack) -> Dict[str, str]:
    tf_vars = {
        "region": stack.default_region,
    }
    # update the dict with the component variables
    tf_vars.update(parse_component_variables(stack.components))
    return tf_vars
