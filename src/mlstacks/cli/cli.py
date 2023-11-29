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
"""CLI for mlstacks."""
import random
import shutil
import string
from pathlib import Path
from typing import TYPE_CHECKING, Optional

import click
import pkg_resources

from mlstacks.analytics import client as analytics_client
from mlstacks.constants import (
    DEFAULT_REMOTE_STATE_BUCKET_NAME,
    MLSTACKS_PACKAGE_NAME,
)
from mlstacks.enums import AnalyticsEventsEnum
from mlstacks.utils.cli_utils import (
    _get_spec_dir,
    confirmation,
    declare,
    error,
    pretty_print_output_vals,
)
from mlstacks.utils.terraform_utils import (
    _get_remote_state_dir_path,
    _get_tf_recipe_path,
    clean_stack_recipes,
    deploy_remote_state,
    deploy_stack,
    destroy_remote_state,
    destroy_stack,
    get_remote_state_bucket,
    get_stack_outputs,
    infracost_breakdown_stack,
)
from mlstacks.utils.yaml_utils import load_stack_yaml, load_yaml_as_dict

if TYPE_CHECKING:
    from mlstacks.models.stack import Stack


@click.group()
def cli() -> None:
    """CLI for mlstacks."""
    pass


@click.command()
@click.option(
    "-f",
    "--file",
    required=True,
    type=click.Path(exists=True),
    help="Path to the YAML file for deploy",
)
@click.option(
    "--remote_state_bucket_name",
    "-rb",
    "remote_state_bucket_name",
    type=click.STRING,
    required=False,
    help="Full URL of a pre-existing remote state bucket",
)
@click.option(
    "-d",
    "--debug",
    is_flag=True,
    default=False,
    help="Flag to enable debug mode to view raw Terraform logging",
)
def deploy(
    file: str,
    remote_state_bucket_name: Optional[str] = None,
    debug: bool = False,
) -> None:
    """Deploys a stack based on a YAML file.

    Args:
        file (str): Path to the YAML file for deploy
        remote_state_bucket_name (str): URL of a pre-existing remote
            state bucket
        debug (bool): Flag to enable debug mode to view raw Terraform logging
    """
    with analytics_client.EventHandler(AnalyticsEventsEnum.MLSTACKS_DEPLOY):
        stack: Stack = load_stack_yaml(file)
        if stack.provider.value == "k3d":
            deployed_bucket_url = None
        elif remote_state_bucket_name:
            deployed_bucket_url = remote_state_bucket_name
            declare(f"Using '{deployed_bucket_url}' for remote state...")
        else:
            # generate random bucket name
            letters = string.ascii_lowercase + string.digits
            random_bucket_suffix = "".join(
                random.choice(letters)  # noqa: S311
                for _ in range(6)
            )
            random_bucket_name = (
                f"{DEFAULT_REMOTE_STATE_BUCKET_NAME}-{random_bucket_suffix}"
            )

            # Remote state deployment
            declare(
                "Deploying remote state to bucket "
                f"'{random_bucket_name}'...",
            )
            deployed_bucket_url = deploy_remote_state(
                stack_path=file,
                bucket_name=random_bucket_name,
                debug_mode=debug,
            )
            declare("Remote state successfully deployed!")
        # Stack deployment
        declare(f"Deploying stack from '{file}'...")
        deploy_stack(
            stack_path=file,
            debug_mode=debug,
            remote_state_bucket=deployed_bucket_url,
        )
        declare("Stack deployed successfully!")


@click.command()
@click.option(
    "-f",
    "--file",
    required=True,
    type=click.Path(exists=True),
    help="Path to the YAML file for destroy",
)
@click.option(
    "-d",
    "--debug",
    is_flag=True,
    default=False,
    help="Flag to enable debug mode to view raw Terraform logging",
)
@click.option(
    "--yes",
    "-y",
    is_flag=True,
    default=False,
    help="Flag to skip confirmation prompt",
)
def destroy(file: str, debug: bool = False, yes: bool = False) -> None:
    """Destroys a stack based on a YAML file.

    Args:
        file (str): Path to the YAML file for destroy
        debug (bool): Flag to enable debug mode to view raw Terraform logging
        yes (bool): Flag to skip confirmation prompt
    """
    with analytics_client.EventHandler(AnalyticsEventsEnum.MLSTACKS_DESTROY):
        if not confirmation(
            f"Are you sure you want to destroy the stack defined in '{file}'?",
        ):
            declare(
                f"Aborted stack destruction for '{file}'...",
            )
            return
        yaml_dict = load_yaml_as_dict(file)
        stack_name: str = str(yaml_dict.get("name"))
        provider: str = str(yaml_dict.get("provider"))
        try:
            remote_state_bucket = get_remote_state_bucket(stack_path=file)
        except FileNotFoundError:
            remote_state_bucket = None
        declare(f"Destroying stack '{stack_name}' from '{file}'...")
        try:
            destroy_stack(
                stack_path=file,
                debug_mode=debug,
                remote_state_bucket=remote_state_bucket,
            )
        except ValueError:
            error("Couldn't find stack files to destroy.")

        spec_files_dir: str = _get_spec_dir(stack_name)
        tf_files_dir: str = _get_tf_recipe_path(provider)
        if (
            yes
            or confirmation(
                f"Would you like to delete the spec files and "
                f"directory (located at '{spec_files_dir}') used "
                "to create this stack?",
            )
        ) and Path(spec_files_dir).exists():
            shutil.rmtree(spec_files_dir)
        if (
            yes
            or confirmation(
                f"Would you like to delete the Terraform state files and "
                f"definitions (located at '{tf_files_dir}') used for "
                "your stack?",
            )
        ) and Path(tf_files_dir).exists():
            shutil.rmtree(tf_files_dir)
        declare(f"Stack '{stack_name}' has been destroyed.")

        if provider != "k3d":
            remote_state_dir = _get_remote_state_dir_path(provider)
            if (
                yes
                or confirmation(
                    f"Would you like to destroy the Terraform remote state "
                    f"used for this stack on {provider}?",
                )
            ) and Path(remote_state_dir).exists():
                destroy_remote_state(provider)
                shutil.rmtree(remote_state_dir)
            declare(f"Remote state for {provider} has been destroyed.")


@click.command()
@click.option(
    "-f",
    "--file",
    required=True,
    type=click.Path(exists=True),
    help="Path to the YAML file for Infracost cost breakdown",
)
def breakdown(file: str) -> None:
    """Estimates the costs for an MLOps stack.

    Args:
        file (str): Path to the YAML file for breakdown
    """
    with analytics_client.EventHandler(AnalyticsEventsEnum.MLSTACKS_BREAKDOWN):
        try:
            cost_output = infracost_breakdown_stack(file)
            print(cost_output)  # noqa: T201
        except ValueError:
            error(
                "Couldn't find stack files to breakdown. Please make sure you "
                "have deployed the stack first.",
            )


@click.command()
@click.option(
    "-f",
    "--file",
    required=True,
    type=click.Path(exists=True),
    help="Path to the YAML file defining the stack",
)
@click.option(
    "--key",
    "-k",
    required=False,
    type=click.STRING,
    help="Optional key for the output to be printed",
)
def output(file: str, key: Optional[str] = "") -> None:
    """Retrieves output values for an MLOps stack.

    Args:
        file (str): Path to the YAML file for breakdown
        key (str): Optional key for the output to be printed
    """
    with analytics_client.EventHandler(AnalyticsEventsEnum.MLSTACKS_OUTPUT):
        try:
            outputs = get_stack_outputs(file, output_key=key)
        except RuntimeError:
            declare(
                "Terraform has not been initialized so there are no outputs "
                "to show. Please run `mlstacks deploy ...` first.",
            )
        if outputs:
            pretty_print_output_vals(outputs)

        try:
            remote_state_bucket = get_remote_state_bucket(stack_path=file)
            declare(f"Remote state bucket: {remote_state_bucket}")
        except FileNotFoundError:
            return


@click.command()
@click.option(
    "--yes",
    "-y",
    is_flag=True,
    default=False,
    help="Flag to skip confirmation prompt",
)
def clean(yes: bool = False) -> None:
    """Cleans up all the Terraform state files.

    Args:
        yes (bool): Flag to skip confirmation prompt
    """
    with analytics_client.EventHandler(AnalyticsEventsEnum.MLSTACKS_CLEAN):
        files_path = (
            Path(click.get_app_dir(MLSTACKS_PACKAGE_NAME)) / "terraform"
        )
        if not files_path.exists():
            declare("No Terraform state files found.")
        elif yes or confirmation(
            "WARNING: Are you sure you want to delete all the Terraform state "
            f"and definition files from {files_path}?\n"
            "This action is irreversible.",
        ):
            clean_stack_recipes()
            declare(
                f"Cleaned up all the Terraform state files from "
                f"'{files_path}'.",
            )
        else:
            declare("Aborting cleaning!")


@click.command()
def source() -> None:
    """Prints and opens the location of TF and Spec files."""
    with analytics_client.EventHandler(AnalyticsEventsEnum.MLSTACKS_SOURCE):
        mlstacks_source_dir = click.get_app_dir(MLSTACKS_PACKAGE_NAME)
        click.echo(f"Source files are located at: `{mlstacks_source_dir}`")
        if confirmation(
            "Would you like to open the source files directory in your "
            "default file browser?",
            default=False,
        ):
            click.launch(mlstacks_source_dir)


@click.command()
def version() -> None:
    """Prints the version of mlstacks package in use."""
    with analytics_client.EventHandler(AnalyticsEventsEnum.MLSTACKS_VERSION):
        try:
            package_version = pkg_resources.get_distribution(
                "mlstacks",
            ).version
            declare(f"mlstacks version: {package_version}")
        except pkg_resources.DistributionNotFound:  # should never happen
            declare("mlstacks package is not installed.")


cli.add_command(deploy)
cli.add_command(destroy)
cli.add_command(breakdown)
cli.add_command(output)
cli.add_command(clean)
cli.add_command(source)
cli.add_command(version)

if __name__ == "__main__":
    cli()
