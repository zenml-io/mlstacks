#  Copyright (c) ZenML GmbH 2023. All Rights Reserved.
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at:
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
#  or implied. See the License for the specific language governing
#  permissions and limitations under the License.
"""Utility functions for Terraform."""

import logging
import shutil
import subprocess
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

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
from mlstacks.utils.yaml_utils import load_stack_yaml, load_yaml_as_dict

logger = logging.getLogger(__name__)

HIGH_LEVEL_COMPONENTS = [
    "orchestrator",
    "experiment_tracker",
    "model_deployer",
    "step_operator",
]

CONFIG_DIR = get_app_dir(MLSTACKS_PACKAGE_NAME)
STATE_FILE_NAME = "terraform.tfstate"
MLSTACKS_VERSION_FILE_NAME = "MLSTACKS_VERSION.txt"


def _get_tf_recipe_path(
    provider: str,
    base_config_dir: str = CONFIG_DIR,
) -> str:
    """Get Terraform recipe path.

    Args:
        provider: The cloud provider.
        base_config_dir: The base configuration directory.

    Returns:
        The Terraform recipe path.
    """
    return str(Path(base_config_dir) / "terraform" / f"{provider}-modular")


class TerraformRunner:
    """Terraform runner."""

    def __init__(self, tf_recipe_path: str) -> None:
        """Initialize Terraform runner.

        Args:
            tf_recipe_path: The path to the Terraform recipe.

        Raises:
            ValueError: If the Terraform recipe path does not exist.
        """
        self.tf_recipe_path = tf_recipe_path

        if not Path(tf_recipe_path).exists():
            msg = f"Terraform recipe path {tf_recipe_path} does not exist."
            raise ValueError(
                msg,
            )
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
        return f"enable_{component.component_type.value}_{component.component_flavor.value}"  # noqa: E501
    if (
        component.component_type == "mlops_platform"
        and component.component_flavor == "zenml"
    ):
        return "enable_zenml"
    return f"enable_{component.component_type.value}"


# def _get_config_property(
#     component: Component, property_name: str
# ) -> Optional[str]:
#     """Retrieve a property value from the configuration.

#     Args:
#         component: The component.
#         property_name: The name of the property.

#     Returns:
#         The value of the property.
#     """
#     if component.metadata.config is None:
#         return None
#     return component.metadata.config.get(property_name)


def parse_and_extract_component_variables(
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
        if component.metadata:
            config_vals = component.metadata.config
            if config_vals:
                # additionally set all other key/value pairs
                # from the configuration
                component_variables.update(config_vals)

            # set additional environment variables
            env_var_vals = component.metadata.environment_variables
            if env_var_vals:
                # additionally set all other key/value pairs
                # from the environment
                # variables
                # prefix the keys with TF_VAR_ as required by Terraform
                if env_var_vals is not None:
                    prefixed_env_var_vals = {
                        f"TF_VAR_{k}": v for k, v in env_var_vals.items()
                    }
                else:
                    prefixed_env_var_vals = {}
                component_variables.update(prefixed_env_var_vals)

    return component_variables


def parse_and_extract_tf_vars(stack: Stack) -> Dict[str, Any]:
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
    tf_vars.update(parse_and_extract_component_variables(stack.components))
    return tf_vars


def tf_definitions_present(
    provider: ProviderEnum,
    base_config_dir: str = CONFIG_DIR,
) -> bool:
    """Check if Terraform definitions are present.

    Args:
        provider: The provider.
        base_config_dir: The base configuration directory.

    Returns:
        True if Terraform definitions are present, False otherwise.
    """
    return (
        Path(_get_tf_recipe_path(provider, base_config_dir)).exists()
        and (Path(base_config_dir) / "terraform" / "modules").exists()
    )


def include_files(
    directory: str,  # noqa: ARG001
    filenames: List[str],
) -> List[str]:
    """Include files in Terraform definitions.

    Args:
        directory: The directory path.
        filenames: The list of filenames to filter.

    Returns:
        The list of files to include in Terraform definitions, after
            filtering out any unwanted files.
    """
    return [
        filename
        for filename in filenames
        if not (
            filename.endswith(".tf")
            or filename.endswith(".md")
            or filename.endswith(".yaml")
            or filename.endswith(".sh")
            or filename == ".terraformignore"
            or filename == MLSTACKS_INITIALIZATION_FILE_FLAG
        )
    ]


def populate_tf_definitions(
    provider: ProviderEnum,
    force: bool = False,
) -> None:
    """Copies Terraform definitions to local config directory.

    Args:
        provider: The cloud provider.
        force: Whether to force the copy.
    """
    definitions_subdir = Path(f"terraform/{provider}-modular")
    modules_subdir = Path("terraform/modules")
    destination_path = Path(_get_tf_recipe_path(provider))
    modules_destination = Path(CONFIG_DIR) / modules_subdir
    package_path = Path(
        pkg_resources.resource_filename(
            MLSTACKS_PACKAGE_NAME,
            str(definitions_subdir),
        ),
    )
    modules_path = Path(
        pkg_resources.resource_filename(
            MLSTACKS_PACKAGE_NAME,
            str(modules_subdir),
        ),
    )

    # copy files from package to the directory
    shutil.copytree(
        package_path,
        destination_path,
        ignore=include_files,
        dirs_exist_ok=force,
    )
    # also copy the module files
    shutil.copytree(
        modules_path,
        modules_destination,
        dirs_exist_ok=True,
    )

    logger.info("Populated Terraform definitions in %s", destination_path)
    # write package version into the directory
    with open(Path(destination_path) / MLSTACKS_VERSION_FILE_NAME, "w") as f:
        mlstacks_version = pkg_resources.get_distribution(
            MLSTACKS_PACKAGE_NAME,
        ).version
        f.write(mlstacks_version)
    logger.debug("Wrote mlstacks version %s to directory.", mlstacks_version)


def get_recipe_metadata(
    provider: ProviderEnum,
    base_config_dir: str = CONFIG_DIR,
) -> Dict[str, Any]:
    """Loads modular recipe metadata for a specific provider.

    Args:
        provider: The cloud provider.
        base_config_dir: The base config directory.

    Returns:
        The recipe metadata.
    """
    recipe_metadata = (
        Path(_get_tf_recipe_path(provider, base_config_dir=base_config_dir))
        / "metadata.yaml"
    )
    return load_yaml_as_dict(recipe_metadata)


def check_tf_definitions_version(provider: ProviderEnum) -> None:
    """Checks for a Terraform version mismatch.

    Args:
        provider: The cloud provider.
    """
    definitions_path = Path(_get_tf_recipe_path(provider))
    if definitions_path.exists():
        with open(definitions_path / MLSTACKS_VERSION_FILE_NAME) as f:
            tf_version = f.read()
            mlstacks_version = pkg_resources.get_distribution(
                MLSTACKS_PACKAGE_NAME,
            ).version
            if tf_version != mlstacks_version:
                logger.warning(
                    "You are running mlstacks version %s, but the Terraform "
                    "definitions in %s were generated with mlstacks version "
                    "%s. This may lead to unexpected behavior.",
                    mlstacks_version,
                    definitions_path,
                    tf_version,
                )


def tf_previously_initialized(tf_recipe_path: str) -> bool:
    """Returns whether Terraform has been previously initialized.

    Args:
        tf_recipe_path: The path to the Terraform recipe.

    Returns:
        True if Terraform has been previously initialized, False otherwise.
    """
    return (Path(tf_recipe_path) / MLSTACKS_INITIALIZATION_FILE_FLAG).exists()


def tf_client_init(
    client: python_terraform.Terraform,
    provider: str,
    debug: bool = False,
) -> Tuple[Any, Any, Any]:
    """Initialize Terraform client.

    Args:
        client: The Terraform client.
        provider: The cloud provider.
        debug: Whether to run in debug mode.

    Returns:
        The return code, stdout, and stderr.
    """
    base_workspace = _get_tf_recipe_path(provider)
    state_path = f"path={Path(base_workspace) / 'terraform.tfstate'!s}"

    logger.debug("Initializing Terraform in %s...", base_workspace)
    ret_code, _stdout, _stderr = client.init(
        backend_config=state_path,
        raise_on_error=False,
        capture_output=not debug,
    )
    logger.debug("Terraform successfully initialized.")
    return ret_code, _stdout, _stderr


def tf_client_apply(
    client: python_terraform.Terraform,
    tf_vars: Dict[str, Any],
    debug: bool,
) -> Tuple[Any, Any, Any]:
    """Apply Terraform changes.

    Args:
        client: The Terraform client.
        tf_vars: The Terraform variables.
        debug: Whether to run in debug mode.

    Returns:
        The return code, stdout, and stderr.
    """
    try:
        logger.debug("Applying Terraform changes...")
        ret_code, _stdout, _stderr = client.apply(
            var=tf_vars,
            input=debug,
            capture_output=not debug,
            raise_on_error=debug,
            refresh=False,
            auto_approve=not debug,
            skip_plan=not debug,
        )
    except python_terraform.TerraformCommandError as e:
        if "The specified location constraint is not valid" in e.out:
            logger.exception(
                "The region '%s' you provided is invalid. "
                "Please fix and try again.",
                tf_vars["region"],
            )
            return 1, None, None
    logger.debug("Terraform changes successfully applied.")
    return ret_code, _stdout, _stderr


def tf_client_destroy(
    client: python_terraform.Terraform,
    tf_vars: Dict[str, Any],
    debug: bool,
) -> Tuple[Any, Any, Any]:
    """Destroy Terraform changes.

    Args:
        client: The Terraform client.
        tf_vars: The Terraform variables.
        debug: Whether to run in debug mode.

    Returns:
        The return code, stdout, and stderr.
    """
    logger.debug("Destroying Terraform components...")
    ret_code, _stdout, _stderr = client.destroy(
        var=tf_vars,
        input=debug,
        capture_output=not debug,
        raise_on_error=debug,
        force=python_terraform.IsNotFlagged,
        refresh=False,
        auto_approve=not debug,
        # skip_plan=not debug,
    )
    logger.debug("Terraform components successfully destroyed.")
    return ret_code, _stdout, _stderr


def clean_stack_recipes() -> None:
    """Deletes stack recipe files from config directory."""
    logger.info("Cleaning stack recipes...")
    tf_path = Path(CONFIG_DIR) / "terraform"
    shutil.rmtree(tf_path)
    logger.info("Deleted Terraform directory at %s", tf_path)


def deploy_stack(stack_path: str, debug_mode: bool = False) -> None:
    """Deploy stack.

    Args:
        stack_path: The path to the stack.
        debug_mode: Whether to run in debug mode.
    """
    stack = load_stack_yaml(stack_path)
    tf_recipe_path = _get_tf_recipe_path(stack.provider)
    if not tf_definitions_present(stack.provider):
        populate_tf_definitions(stack.provider, force=True)
    tf_vars = parse_and_extract_tf_vars(stack)
    check_tf_definitions_version(stack.provider)

    tfr = TerraformRunner(tf_recipe_path)
    if not tf_previously_initialized(tf_recipe_path):
        tf_client_init(tfr.client, provider=stack.provider, debug=debug_mode)

        # write a file with name `IGNORE_ME` to the Terraform recipe directory
        # to prevent Terraform from initializing the recipe
        (Path(tf_recipe_path) / MLSTACKS_INITIALIZATION_FILE_FLAG).touch()

    tf_client_apply(
        client=tfr.client,
        tf_vars=tf_vars,
        debug=debug_mode,
    )


def destroy_stack(stack_path: str, debug_mode: bool = False) -> None:
    """Destroy stack.

    Args:
        stack_path: The path to the stack.
        debug_mode: Whether to run in debug mode.
    """
    stack = load_stack_yaml(stack_path)
    tf_vars = parse_and_extract_tf_vars(stack)

    tf_recipe_path = _get_tf_recipe_path(stack.provider)

    tfr = TerraformRunner(tf_recipe_path)

    if not tf_previously_initialized(tf_recipe_path):
        tf_client_init(tfr.client, provider=stack.provider, debug=debug_mode)

        # write a file with name `IGNORE_ME` to the Terraform recipe directory
        # to prevent Terraform from initializing the recipe
        (Path(tf_recipe_path) / MLSTACKS_INITIALIZATION_FILE_FLAG).touch()

    tf_client_destroy(tfr.client, tf_vars, debug_mode)


def tf_client_output(
    runner: TerraformRunner,
    state_path: str,
    output_key: Optional[str] = None,
) -> Dict[str, str]:
    """Destroy Terraform changes.

    Args:
        runner: The Terraform runner.
        state_path: The path to the Terraform state file.
        output_key: The output key.

    Returns:
        Output key:value pairs.
    """
    logger.debug("Getting Terraform outputs...")
    if output_key:
        full_outputs = runner.client.output(
            output_key,
            full_value=True,
            state=state_path,
        )
        return {output_key: full_outputs}
    full_outputs = runner.client.output(full_value=True, state=state_path)
    return {k: v["value"] for k, v in full_outputs.items() if v.get("value")}


def get_stack_outputs(
    stack_path: str,
    output_key: Optional[str] = None,
) -> Dict[str, str]:
    """Get stack outputs.

    Args:
        stack_path: The path to the stack.
        output_key: The output key.

    Returns:
        The stack outputs.

    Raises:
        RuntimeError: If Terraform has not been initialized.
    """
    stack = load_stack_yaml(stack_path)
    tf_recipe_path = _get_tf_recipe_path(stack.provider)
    state_tf_path = f"{tf_recipe_path}/terraform.tfstate"

    tfr = TerraformRunner(tf_recipe_path)
    if not tf_previously_initialized(tf_recipe_path):
        msg = (
            "Terraform has not been initialized so "
            "there are no outputs to show."
        )
        raise RuntimeError(msg)

    return tf_client_output(
        runner=tfr,
        state_path=state_tf_path,
        output_key=output_key,
    )


def verify_infracost_installed() -> bool:
    """Checks if Infracost is installed and user is logged in.

    Returns:
        bool: True if Infracost is installed, otherwise False.
    """
    try:
        subprocess.run(
            ["infracost", "configure", "get", "api_key"],  # noqa: S607,S603
            check=True,
            capture_output=True,
            text=True,
        )
        return True  # noqa: TRY300
    except (subprocess.CalledProcessError, FileNotFoundError):
        logger.exception(
            "Infracost is not installed or you have not logged in. "
            "Please visit their docs at https://www.infracost.io/docs/ "
            "and install, then run 'infracost auth login' before retrying.",
        )
        return False


def _get_infracost_vars(variables: Dict[str, Any]) -> Dict[str, str]:
    """Get Infracost variables.

    Args:
        variables: The Terraform variables.

    Returns:
        The Infracost variables.
    """
    # remove any k:v pairs that are nested dicts
    return {k: v for k, v in variables.items() if not isinstance(v, dict)}


def infracost_breakdown_stack(
    stack_path: str,
    debug_mode: bool = False,
) -> str:
    """Estimate costs for a stack using Infracost.

    Args:
        stack_path: The path to the stack.
        debug_mode: Whether to run in debug mode.

    Returns:
        The cost breakdown.
    """
    _ = verify_infracost_installed()
    stack = load_stack_yaml(stack_path)
    infracost_vars = _get_infracost_vars(parse_and_extract_tf_vars(stack))

    tf_recipe_path = _get_tf_recipe_path(stack.provider)

    tfr = TerraformRunner(tf_recipe_path)
    if not tf_previously_initialized(tf_recipe_path):
        # write a file with name `IGNORE_ME` to the Terraform recipe directory
        # to prevent Terraform from initializing the recipe
        tf_client_init(tfr.client, provider=stack.provider, debug=debug_mode)
        (Path(tf_recipe_path) / MLSTACKS_INITIALIZATION_FILE_FLAG).touch()

    # Constructing the infracost command
    infracost_cmd = f"infracost breakdown --path '{tf_recipe_path}'"
    for k, v in infracost_vars.items():
        infracost_cmd += f" --terraform-var {k}={v}"

    # Execute the command
    process = subprocess.run(
        infracost_cmd,
        shell=True,  # noqa: S602
        check=True,
        capture_output=True,
        text=True,
    )

    return process.stdout
