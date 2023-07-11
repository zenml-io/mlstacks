"""Utility functions for Terraform."""

import logging
import subprocess
from typing import Any, Dict, List, Optional

import python_terraform

from mlstacks.models.component import Component
from mlstacks.models.stack import Stack
from mlstacks.utils.yaml_utils import load_stack_yaml

logger = logging.getLogger(__name__)

HIGH_LEVEL_COMPONENTS = [
    "artifact_store",
    "container_registry",
    "secrets_manager",
    "mlops_platform",
]


class TerraformRunner:
    """Terraform runner."""

    def __init__(self, tf_recipe_path: str) -> None:
        """Initialize Terraform runner.

        Args:
            tf_recipe_path: The path to the Terraform recipe.
        """
        self.tf_recipe_path = tf_recipe_path

        self.client = python_terraform.Terraform(
            working_dir=self.tf_recipe_path,
        )


def _compose_enable_key(component: Component) -> str:
    """Generate the key for enabling a component.

    Args:
        component: The component.

    Returns:
        The key for enabling the component.
    """
    if component.component_type not in HIGH_LEVEL_COMPONENTS:
        return (
            f"enable_{component.component_type}_{component.component_flavor}"
        )
    elif (
        component.component_type == "mlops_platform"
        and component.component_flavor == "zenml"
    ):
        return "enable_zenml"
    else:
        return f"enable_{component.component_type}"


def _get_config_property(component: Component, property_name: str) -> str:
    """Retrieve a property value from the configuration.

    Args:
        component: The component.
        property_name: The name of the property.

    Returns:
        The value of the property.
    """
    return component.metadata.config.get(property_name)


def parse_component_variables(
    components: List[Component],
) -> Dict[str, Optional[str]]:
    """Parse component variables.

    Args:
        components: The components of the stack.

    Returns:
        The component variables.
    """

    component_variables = {}
    for component in components:
        key = _compose_enable_key(component)
        component_variables[key] = "true"
        if component.metadata.config:
            # additionally set all other key/value pairs from the configuration
            for config_key in component.metadata.config:
                component_variables[config_key] = _get_config_property(
                    component, config_key
                )

    return component_variables


def parse_tf_vars(stack: Stack) -> Dict[str, Any]:
    """Parse Terraform variables.

    Args:
        stack: The stack.

    Returns:
        The Terraform variables.
    """
    tf_vars = {
        "region": stack.default_region,
        "tags": stack.default_tags,
    }
    # update the dict with the component variables
    tf_vars.update(parse_component_variables(stack.components))
    return tf_vars


def deploy_stack(stack_path: str) -> None:
    """Deploy stack.

    Args:
        stack_path: The path to the stack.
    """
    stack = load_stack_yaml(stack_path)
    tf_vars = parse_tf_vars(stack)

    tf_recipe_path = f"terraform/{stack.provider}-modular"

    tfr = TerraformRunner(tf_recipe_path)
    ret_code, _, _ = tfr.client.init(capture_output=True)

    tfr.client.apply(
        var=tf_vars,
        input=False,
        capture_output=False,
        raise_on_error=True,
        refresh=False,
    )


def destroy_stack(stack_path: str) -> None:
    """Destroy stack.

    Args:
        stack_path: The path to the stack.
    """
    stack = load_stack_yaml(stack_path)
    tf_vars = parse_tf_vars(stack)

    tf_recipe_path = f"terraform/{stack.provider}-modular"

    tfr = TerraformRunner(tf_recipe_path)
    ret_code, _, _ = tfr.client.init(capture_output=True)

    tfr.client.destroy(
        var=tf_vars,
        capture_output=False,
        raise_on_error=True,
        force=python_terraform.IsNotFlagged,
        refresh=False,
    )


def get_stack_outputs(
    stack_name: str, output_key: Optional[str] = None
) -> Dict[str, str]:
    """Get stack outputs.

    Args:
        stack_path: The path to the stack.
    """
    stack = load_stack_yaml(stack_name)

    tf_recipe_path = f"terraform/{stack.provider}-modular"

    tfr = TerraformRunner(tf_recipe_path)
    tfr.client.init(capture_output=True)

    if output_key:
        full_outputs = tfr.client.output(output_key, full_value=True)
        return {output_key: full_outputs}
    else:
        full_outputs = tfr.client.output(full_value=True)
        return {k: v["value"] for k, v in full_outputs.items()}


def _infracost_installed() -> bool:
    """Check if Infracost is installed.

    Returns:
        True if Infracost is installed, False otherwise.
    """
    try:
        subprocess.run(
            ["infracost", "configure", "get", "api_key"],
            check=True,
            capture_output=True,
            text=True,
        )
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def _get_infracost_vars(vars: Dict[str, Any]) -> Dict[str, str]:
    """Get Infracost variables.

    Args:
        vars: The Terraform variables.

    Returns:
        The Infracost variables.
    """
    # remove any k:v pairs that are nested dicts
    return {k: v for k, v in vars.items() if not isinstance(v, dict)}


def infracost_breakdown_stack(stack_path: str) -> None:
    """Estimate costs for a stack using Infracost."""
    if not _infracost_installed():
        logger.error(
            "Infracost is not installed or you have not logged in. "
            "Please visit their docs at https://www.infracost.io/docs/ "
            "and install, then run 'infracost auth login' before retrying."
        )
        return

    stack = load_stack_yaml(stack_path)
    infracost_vars = _get_infracost_vars(parse_tf_vars(stack))

    tf_recipe_path = f"terraform/{stack.provider}-modular"

    tfr = TerraformRunner(tf_recipe_path)
    tfr.client.init(capture_output=True)

    # Constructing the infracost command
    infracost_cmd = f"infracost breakdown --path {tf_recipe_path}"
    for k, v in infracost_vars.items():
        infracost_cmd += f" --terraform-var {k}={v}"

    # Execute the command
    process = subprocess.run(
        infracost_cmd, shell=True, check=True, capture_output=True, text=True
    )

    # Print the output
    print(process.stdout)
