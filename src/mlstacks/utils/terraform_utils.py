"""Utility functions for Terraform."""

import logging
import shutil
import subprocess
from pathlib import Path
from typing import Any, Dict, List, Optional

import pkg_resources
import python_terraform
from click import get_app_dir

from mlstacks.constants import (
    MLSTACKS_INITIALIZATION_FILE_FLAG,
    MLSTACKS_PACKAGE_NAME,
)
from mlstacks.enums import ProviderEnum
from mlstacks.models.component import Component
from mlstacks.models.stack import Stack
from mlstacks.utils.yaml_utils import load_stack_yaml

logger = logging.getLogger(__name__)

HIGH_LEVEL_COMPONENTS = [
    "orchestrator",
    "experiment_tracker",
    "model_deployer",
    "step_operator",
]

CONFIG_DIR = get_app_dir(MLSTACKS_PACKAGE_NAME)


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
    if component.component_type in HIGH_LEVEL_COMPONENTS:
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


def _get_config_property(
    component: Component, property_name: str
) -> Optional[str]:
    """Retrieve a property value from the configuration.

    Args:
        component: The component.
        property_name: The name of the property.

    Returns:
        The value of the property.
    """
    if component.metadata.config is None:
        return None
    return component.metadata.config[property_name]


def parse_component_variables(
    components: List[Component],
) -> Dict[str, str]:
    """Parse component variables.

    Args:
        components: The components of the stack.

    Returns:
        The component variables.
    """
    component_variables = {}
    for component in components:
        # set enable_xxx as appropriate per component
        enable_key = _compose_enable_key(component)
        component_variables[enable_key] = "true"

        # set additional config properties
        config_vals = component.metadata.config
        if config_vals:
            # additionally set all other key/value pairs from the configuration
            component_variables.update(config_vals)

        # set additional environment variables
        env_var_vals = component.metadata.environment_variables
        if env_var_vals:
            # additionally set all other key/value pairs from the environment
            # variables
            # prefix the keys with TF_VAR_ as required by Terraform
            prefixed_env_var_vals = {f"TF_VAR_{k}": v for k, v in env_var_vals}
            component_variables.update(prefixed_env_var_vals)

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
        "additional_tags": stack.default_tags,
    }
    # update the dict with the component variables
    tf_vars.update(parse_component_variables(stack.components))
    return tf_vars


def tf_definitions_present(provider: ProviderEnum) -> bool:
    """Check if Terraform definitions are present.

    Args:
        provider: The provider.

    Returns:
        True if Terraform definitions are present, False otherwise.
    """
    config_dir = get_app_dir(MLSTACKS_PACKAGE_NAME)
    return Path(f"{config_dir}/terraform/{provider}-modular").exists()


def populate_tf_definitions(provider: ProviderEnum) -> None:
    """Copies Terraform definitions to local config directory.

    Args:
        provider: The cloud provider.
    """
    definitions_subdir = f"terraform/{provider}-modular"
    destination_path = Path(f"{CONFIG_DIR}/{definitions_subdir}")
    package_path = pkg_resources.resource_filename(
        MLSTACKS_PACKAGE_NAME, definitions_subdir
    )
    # copy files from package to the directory
    _ = shutil.copytree(package_path, destination_path)
    logger.info(f"Populated Terraform definitions in {destination_path}")
    # write package version into the directory
    with open(f"{destination_path}/MLSTACKS_VERSION.txt", "w") as f:
        mlstacks_version = pkg_resources.get_distribution(
            MLSTACKS_PACKAGE_NAME
        ).version
        f.write(mlstacks_version)


def check_tf_definitions_version(provider: ProviderEnum) -> None:
    """Checks for a Terraform version mismatch.

    Args:
        provider: The cloud provider.
    """
    definitions_subdir = f"terraform/{provider}-modular"
    definitions_path = Path(f"{CONFIG_DIR}/{definitions_subdir}")
    if definitions_path.exists():
        with open(f"{definitions_path}/MLSTACKS_VERSION.txt", "r") as f:
            tf_version = f.read()
            mlstacks_version = pkg_resources.get_distribution(
                MLSTACKS_PACKAGE_NAME
            ).version
            if tf_version != mlstacks_version:
                logger.warning(
                    f"You are running mlstacks version {mlstacks_version}, "
                    f"but the Terraform definitions in {definitions_path} "
                    f"were generated with mlstacks version {tf_version}. "
                    f"This may lead to unexpected behavior."
                )


def tf_previously_initialized(tf_recipe_path: str) -> bool:
    """Returns whether Terraform has been previously initialized.

    Args:
        tf_recipe_path: The path to the Terraform recipe.

    Returns:
        True if Terraform has been previously initialized, False otherwise.
    """
    return Path(
        f"{tf_recipe_path}/{MLSTACKS_INITIALIZATION_FILE_FLAG}"
    ).exists()


def deploy_stack(stack_path: str) -> None:
    """Deploy stack.

    Args:
        stack_path: The path to the stack.
    """
    # load and parse terraform variables and definitions
    stack = load_stack_yaml(stack_path)
    tf_recipe_path = f"{CONFIG_DIR}/terraform/{stack.provider}-modular"
    if not tf_definitions_present(stack.provider):
        populate_tf_definitions(stack.provider)
    tf_vars = parse_tf_vars(stack)

    check_tf_definitions_version(stack.provider)

    # run Terraform
    tfr = TerraformRunner(tf_recipe_path)

    if not tf_previously_initialized(tf_recipe_path):
        # write a file with name `IGNORE_ME` to the Terraform recipe directory
        # to prevent Terraform from initializing the recipe
        ret_code, _, _ = tfr.client.init(capture_output=True)
        Path(f"{tf_recipe_path}/{MLSTACKS_INITIALIZATION_FILE_FLAG}").touch()

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

    tf_recipe_path = f"{CONFIG_DIR}/terraform/{stack.provider}-modular"

    tfr = TerraformRunner(tf_recipe_path)

    if not tf_previously_initialized(tf_recipe_path):
        # write a file with name `IGNORE_ME` to the Terraform recipe directory
        # to prevent Terraform from initializing the recipe
        ret_code, _, _ = tfr.client.init(capture_output=True)
        Path(f"{tf_recipe_path}/{MLSTACKS_INITIALIZATION_FILE_FLAG}").touch()

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

    tf_recipe_path = f"{CONFIG_DIR}/terraform/{stack.provider}-modular"

    tfr = TerraformRunner(tf_recipe_path)
    if not tf_previously_initialized(tf_recipe_path):
        # write a file with name `IGNORE_ME` to the Terraform recipe directory
        # to prevent Terraform from initializing the recipe
        ret_code, _, _ = tfr.client.init(capture_output=True)
        Path(f"{tf_recipe_path}/{MLSTACKS_INITIALIZATION_FILE_FLAG}").touch()

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

    tf_recipe_path = f"{CONFIG_DIR}/terraform/{stack.provider}-modular"

    tfr = TerraformRunner(tf_recipe_path)
    if not tf_previously_initialized(tf_recipe_path):
        # write a file with name `IGNORE_ME` to the Terraform recipe directory
        # to prevent Terraform from initializing the recipe
        ret_code, _, _ = tfr.client.init(capture_output=True)
        Path(f"{tf_recipe_path}/{MLSTACKS_INITIALIZATION_FILE_FLAG}").touch()

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
