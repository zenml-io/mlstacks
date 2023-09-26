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

import json
import logging
import os
import shutil
import subprocess
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple, cast

import pkg_resources
import python_terraform
import requests
from click import get_app_dir

from mlstacks.constants import (
    DEFAULT_REMOTE_STATE_BUCKET_NAME,
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
MLSTACKS_VERSION_FILE_NAME = "MLSTACKS_VERSION"
REMOTE_STATE_VALUES_FILENAME = "remote_state_values.tfvars.json"
REMOTE_STATE_BUCKET_URL_FILE_NAME = "REMOTE_STATE_BUCKET_URL"


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


def _get_remote_state_dir_path(
    provider: str,
    base_config_dir: str = CONFIG_DIR,
) -> str:
    """Get remote state dir path.

    Args:
        provider: The cloud provider.
        base_config_dir: The base configuration directory.

    Returns:
        The remote files path.
    """
    return str(
        Path(base_config_dir) / "terraform" / f"{provider}-remote-state",
    )


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
    # Note the directory argument is required byTerraform
    # though not used directly in this function
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
    region: str,
    force: bool = False,
    remote_state_bucket: Optional[str] = None,
) -> None:
    """Copies Terraform definitions to local config directory.

    Args:
        provider: The cloud provider.
        region: The region.
        force: Whether to force the copy.
        remote_state_bucket: The remote state bucket URL.
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

    # rename and overwrite terraform config definitions
    if remote_state_bucket:
        remote_state_tf_config_subdir = os.path.join(
            "terraform",
            "remote-state-terraform-config",
        )
        remote_state_terraform_config_subdir = Path(
            pkg_resources.resource_filename(
                MLSTACKS_PACKAGE_NAME,
                str(remote_state_tf_config_subdir),
            ),
        )
        bucket_name_without_prefix = remote_state_bucket.split("://", 1)[-1]
        # get the text of the terraform config file from
        # remote_state_terraform_config_subdir
        tf_config = Path(
            remote_state_terraform_config_subdir / f"terraform-{provider}.tf",
        ).read_text()
        # replace backend config as per provider
        if provider == "aws":
            tf_config = tf_config.replace(
                "BUCKETNAMEREPLACEME",
                bucket_name_without_prefix,
            ).replace("REGIONNAMEREPLACEME", region)
        else:
            tf_config = tf_config.replace(
                "BUCKETNAMEREPLACEME",
                bucket_name_without_prefix,
            )

        # write the string to destination_path using filename `terraform.tf`
        # and overwriting any pre-existing file
        with open(destination_path / "terraform.tf", "w") as f:
            f.write(tf_config)

        # write remote_state_bucket url to destination_path
        # in file named REMOTE_STATE_BUCKET_URL
        with open(
            destination_path / REMOTE_STATE_BUCKET_URL_FILE_NAME,
            "w",
        ) as f:
            f.write(remote_state_bucket)

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


def remote_state_bucket_exists(
    remote_state_bucket_url: str,
    region: str,
) -> bool:
    """Checks if a remote state bucket exists.

    Args:
        remote_state_bucket_url: The remote state bucket URL.
        region: The region the bucket exists in.

    Returns:
        True if the remote state bucket exists, False otherwise.

    Raises:
        ValueError: If the remote state bucket URL is invalid.
    """
    # Remove trailing slash if present
    remote_state_bucket_url = remote_state_bucket_url.rstrip("/")

    # Convert to HTTP URL format
    if remote_state_bucket_url.startswith("s3://"):
        http_url = (
            f"https://{remote_state_bucket_url[5:]}.s3.{region}.amazonaws.com"
        )
    elif remote_state_bucket_url.startswith("gs://"):
        http_url = (
            f"https://storage.googleapis.com/{remote_state_bucket_url[5:]}"
        )
    else:
        remote_state_failure_error = "Unsupported URL scheme / type"
        raise ValueError(remote_state_failure_error)

    # check if the bucket exists
    try:
        response = requests.head(http_url, timeout=60)
    except Exception:
        return False
    else:
        return response.status_code in {200, 403}


def _tf_client_init(
    client: python_terraform.Terraform,
    provider: str,
    region: str,
    debug: bool = False,
    remote_state_bucket: Optional[str] = None,
) -> Tuple[Any, Any, Any]:
    """Initialize Terraform client.

    Args:
        client: The Terraform client.
        provider: The cloud provider.
        region: The region.
        debug: Whether to run in debug mode.
        remote_state_bucket: The remote state bucket URL.

    Returns:
        The return code, stdout, and stderr.

    Raises:
        ValueError: If the remote state bucket doesn't exist.
    """
    base_workspace = _get_tf_recipe_path(provider)
    state_path = f"path={Path(base_workspace) / 'terraform.tfstate'!s}"

    logger.debug("Initializing Terraform in %s...", base_workspace)
    if remote_state_bucket:
        if not remote_state_bucket_exists(
            remote_state_bucket_url=remote_state_bucket,
            region=region,
        ):
            no_bucket_exists_error_msg = (
                "Tried to initialize Terraform with remote state bucket "
                f"'{remote_state_bucket}' but it does not exist.",
            )
            raise ValueError(no_bucket_exists_error_msg)
        logger.debug("Initializing Terraform with remote state...")
        ret_code, _stdout, _stderr = client.init(
            raise_on_error=False,
            capture_output=not debug,
        )
    else:
        logger.debug("Initializing Terraform with local state...")
        ret_code, _stdout, _stderr = client.init(
            backend_config=state_path,
            raise_on_error=False,
            capture_output=not debug,
        )
    logger.debug("Terraform successfully initialized.")
    return ret_code, _stdout, _stderr


def _tf_client_apply(
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
        if e.out and "The specified location constraint is not valid" in e.out:
            logger.exception(
                "The region '%s' you provided is invalid. "
                "Please fix and try again.",
                tf_vars["region"],
            )
        else:
            logger.exception(
                "An unknown error occurred while applying Terraform changes.",
            )
        return 1, None, None
    logger.debug("Terraform changes successfully applied.")
    return ret_code, _stdout, _stderr


def _tf_client_destroy(
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


def remote_state_deployed(tf_definitions_path: str) -> bool:
    """Returns whether remote state is deployed.

    Args:
        tf_definitions_path: The path to the Terraform definitions.

    Returns:
        True if remote state is deployed, False otherwise.
    """
    return (
        Path(tf_definitions_path).exists()
        and Path(
            os.path.join(tf_definitions_path, "terraform.tfstate"),
        ).exists()
    )


def populate_remote_state_tf_definitions(
    provider: str,
    definitions_destination_path: str,
) -> None:
    """Populates remote state TF definitions.

    Args:
        provider: The provider
        definitions_destination_path: The destination path
    """
    definitions_subdir = Path(f"terraform/{provider}-remote-state")
    package_path = Path(
        pkg_resources.resource_filename(
            MLSTACKS_PACKAGE_NAME,
            str(definitions_subdir),
        ),
    )

    # copy files from package to the directory
    shutil.copytree(
        package_path,
        definitions_destination_path,
        ignore=include_files,
        # dirs_exist_ok=force,
    )


def write_remote_state_tf_variables(
    bucket_name: str,
    stack: Stack,
) -> Dict[str, str]:
    """Writes remote state variables to a json file.

    Args:
        bucket_name: The name of the bucket.
        stack: The stack

    Returns:
        The remote state variables as a dictionary
    """
    provider = stack.provider
    remote_state_tf_definitions = os.path.join(
        CONFIG_DIR,
        "terraform",
        f"{provider}-remote-state",
    )
    project_id = parse_and_extract_tf_vars(stack).get("project_id")
    remote_state_variables = {
        "bucket_name": str(bucket_name),
        "region": str(stack.default_region),
    }
    if project_id:
        remote_state_variables["project_id"] = str(project_id)
    with open(
        os.path.join(
            remote_state_tf_definitions,
            REMOTE_STATE_VALUES_FILENAME,
        ),
        "w",
    ) as f:
        json.dump(remote_state_variables, f)

    return remote_state_variables


def get_remote_state_bucket_name(tf_definitions_path: str) -> str:
    """Gets the remote state bucket name.

    Args:
        tf_definitions_path: The path to the Terraform definitions.

    Returns:
        The remote state bucket name.
    """
    with open(
        os.path.join(tf_definitions_path, REMOTE_STATE_VALUES_FILENAME),
    ) as f:
        remote_state_variables = json.load(f)
    return cast(str, remote_state_variables.get("bucket_name"))


def deploy_remote_state(
    stack_path: str,
    bucket_name: str = DEFAULT_REMOTE_STATE_BUCKET_NAME,
    debug_mode: bool = False,
) -> str:
    """Deploy remote state.

    Args:
        stack_path: The path to the stack.
        bucket_name: The name of the bucket.
        debug_mode: Whether to run in debug mode.

    Returns:
        The bucket name used for remote state
    """
    stack: Stack = load_stack_yaml(stack_path)
    remote_state_tf_definitions_path = os.path.join(
        CONFIG_DIR,
        "terraform",
        f"{stack.provider}-remote-state",
    )

    # check whether remote state files already exist locally
    # CONFIG/mlstacks/terraform/gcp-remote-state/
    if remote_state_deployed(remote_state_tf_definitions_path):
        # use the local json file to get the deployed bucket name
        return get_remote_state_bucket_name(remote_state_tf_definitions_path)

    # copy remote state TF definitions
    populate_remote_state_tf_definitions(
        provider=stack.provider,
        definitions_destination_path=remote_state_tf_definitions_path,
    )

    # write json file with (bucket_name, region, project)
    tf_vars = write_remote_state_tf_variables(
        bucket_name=bucket_name,
        stack=stack,
    )

    tfr = TerraformRunner(remote_state_tf_definitions_path)
    # tf init
    if not tf_previously_initialized(remote_state_tf_definitions_path):
        ret_code, _, _stderr = _tf_client_init(
            tfr.client,
            provider=stack.provider,
            region=stack.default_region,
            debug=debug_mode,
        )
        if ret_code != 0:
            raise RuntimeError(_stderr)

        # write a file with name `IGNORE_ME` to the Terraform recipe directory
        # to prevent Terraform from re-initializing the recipe
        (
            Path(remote_state_tf_definitions_path)
            / MLSTACKS_INITIALIZATION_FILE_FLAG
        ).touch()

    # tf apply
    ret_code, _, _stderr = _tf_client_apply(
        client=tfr.client,
        tf_vars=tf_vars,
        debug=debug_mode,
    )
    if ret_code != 0:
        raise RuntimeError(_stderr)

    return (
        _tf_client_output(
            runner=tfr,
            state_path=os.path.join(
                remote_state_tf_definitions_path,
                "terraform.tfstate",
            ),
            output_key="bucket_url",
        ).get("bucket_url")
        or ""
    )


def deploy_stack(
    stack_path: str,
    debug_mode: bool = False,
    remote_state_bucket: Optional[str] = None,
) -> None:
    """Deploy stack.

    Args:
        stack_path: The path to the stack.
        debug_mode: Whether to run in debug mode.
        remote_state_bucket: The remote state bucket URL (if used).
    """
    stack = load_stack_yaml(stack_path)
    tf_recipe_path = _get_tf_recipe_path(stack.provider)
    if not tf_definitions_present(stack.provider):
        populate_tf_definitions(
            stack.provider,
            region=stack.default_region,
            force=True,
            remote_state_bucket=remote_state_bucket,
        )
    tf_vars = parse_and_extract_tf_vars(stack)
    check_tf_definitions_version(stack.provider)

    tfr = TerraformRunner(tf_recipe_path)
    if not tf_previously_initialized(tf_recipe_path):
        ret_code, _, _stderr = _tf_client_init(
            tfr.client,
            provider=stack.provider,
            region=stack.default_region,
            debug=debug_mode,
            remote_state_bucket=remote_state_bucket,
        )
        if ret_code != 0:
            raise RuntimeError(_stderr)

        # write a file with name `IGNORE_ME` to the Terraform recipe directory
        # to prevent Terraform from initializing the recipe
        (Path(tf_recipe_path) / MLSTACKS_INITIALIZATION_FILE_FLAG).touch()

    ret_code, _, _stderr = _tf_client_apply(
        client=tfr.client,
        tf_vars=tf_vars,
        debug=debug_mode,
    )
    if ret_code != 0:
        raise RuntimeError(_stderr)


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
        ret_code, _, _stderr = _tf_client_init(
            tfr.client,
            provider=stack.provider,
            region=stack.default_region,
            debug=debug_mode,
        )
        if ret_code != 0:
            raise RuntimeError(_stderr)

        # write a file with name `IGNORE_ME` to the Terraform recipe directory
        # to prevent Terraform from initializing the recipe
        (Path(tf_recipe_path) / MLSTACKS_INITIALIZATION_FILE_FLAG).touch()

    ret_code, _, _stderr = _tf_client_destroy(
        tfr.client,
        tf_vars,
        debug_mode,
    )
    if ret_code != 0:
        raise RuntimeError(_stderr)


def set_force_destroy(
    tf_definitions_path: str,
    provider: str,
) -> None:
    """Set force destroy flag on remote state bucket file.

    Overwrites the file with force_destroy set to true.

    Args:
        tf_definitions_path: The path to the Terraform definitions
        provider: The provider
    """
    main_definition = Path(
        os.path.join(tf_definitions_path, "main.tf"),
    ).read_text()
    if provider == "aws":
        main_definition = main_definition.replace(
            "prevent_destroy = true",
            "prevent_destroy = false",
        )

    main_definition = main_definition.replace(
        "# force_destroy = true",
        "force_destroy = true",
    )

    with open(
        os.path.join(tf_definitions_path, "main.tf"),
        "w",
    ) as f:
        f.write(main_definition)


def destroy_remote_state(provider: str, debug_mode: bool = False) -> None:
    """Destroy remote state infrastructure.

    Args:
        provider: The provider
        debug_mode: Whether to run in debug mode
    """
    remote_state_tf_definitions_path = _get_remote_state_dir_path(provider)
    tfr = TerraformRunner(remote_state_tf_definitions_path)

    # load tf_vars from the REMOTE_STATE_VALUES_FILENAME custom json file
    with open(
        os.path.join(
            remote_state_tf_definitions_path,
            REMOTE_STATE_VALUES_FILENAME,
        ),
    ) as f:
        tf_vars = json.load(f)

    # overwrites 'main.tf' file to allow destruction
    set_force_destroy(
        remote_state_tf_definitions_path,
        provider=provider,
    )
    # apply the force_destroy update
    ret_code, _, _stderr = _tf_client_apply(
        client=tfr.client,
        tf_vars=tf_vars,
        debug=debug_mode,
    )
    if ret_code != 0:
        raise RuntimeError(_stderr)

    # destroy the infrastructure
    ret_code, _, _stderr = _tf_client_destroy(
        tfr.client,
        tf_vars=tf_vars,
        debug=debug_mode,
    )
    if ret_code != 0:
        raise RuntimeError(_stderr)


def get_remote_state_bucket(stack_path: str) -> str:
    """Get remote state bucket.

    Args:
        stack_path: The path to the stack spec definition.

    Returns:
        The remote state bucket.

    Raises:
        FileNotFoundError: when file does not exist
    """
    stack = load_stack_yaml(stack_path)
    tf_recipe_path = _get_tf_recipe_path(stack.provider)
    bucket_url_file = os.path.join(
        tf_recipe_path,
        REMOTE_STATE_BUCKET_URL_FILE_NAME,
    )
    if not os.path.exists(bucket_url_file):
        bucket_not_found_error_message = (
            f"File {bucket_url_file} does not exist. "
            "Please deploy the remote state first.",
        )
        raise FileNotFoundError(bucket_not_found_error_message)
    # open REMOTE_STATE_BUCKET_URL_FILE_NAME within tf_recipe_path
    with open(os.path.join(bucket_url_file)) as f:
        return f.read()


def _tf_client_output(
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

    return _tf_client_output(
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
        ret_code, _, _stderr = _tf_client_init(
            tfr.client,
            provider=stack.provider,
            region=stack.default_region,
            debug=debug_mode,
        )
        if ret_code != 0:
            raise RuntimeError(_stderr)

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
