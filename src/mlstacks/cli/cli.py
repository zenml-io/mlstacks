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


from pathlib import Path
from typing import Optional

import click

from mlstacks.constants import (
    MLSTACKS_PACKAGE_NAME,
)
from mlstacks.utils.terraform_utils import (
    clean_stack_recipes,
    deploy_stack,
    destroy_stack,
    get_stack_outputs,
    infracost_breakdown_stack,
)


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
    "-d",
    "--debug",
    is_flag=True,
    default=False,
    help="Flag to enable debug mode to view raw Terraform logging",
)
def deploy(file: str, debug: bool = False) -> None:
    """Deploys a stack based on a YAML file.

    Args:
        file (str): Path to the YAML file for deploy
    """
    deploy_stack(stack_path=file, debug_mode=debug)


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
def destroy(file: str, debug: bool = False) -> None:
    """Destroys a stack based on a YAML file.

    Args:
        file (str): Path to the YAML file for destroy
        debug (bool): Flag to enable debug mode to view raw Terraform logging
    """
    destroy_stack(stack_path=file, debug_mode=debug)


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
    infracost_breakdown_stack(file)


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
@click.option(
    "-d",
    "--debug",
    is_flag=True,
    default=False,
    help="Flag to enable debug mode to view raw Terraform logging",
)
def output(file: str, key: Optional[str] = "", debug: bool = False) -> None:
    """Estimates the costs for an MLOps stack.

    Args:
        file (str): Path to the YAML file for breakdown
    """
    get_stack_outputs(file, output_key=key, debug_mode=debug)


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
    files_path = f"{click.get_app_dir(MLSTACKS_PACKAGE_NAME)}/terraform"
    if not Path(files_path).exists():
        click.echo("No Terraform state files found.")
    elif yes or click.confirm(
        "Are you sure you want to delete all the Terraform state "
        f"and definition files from {files_path}?\n",
        "This action is irreversible.",
    ):
        clean_stack_recipes()
        click.echo("Cleaned up all the Terraform state files.")
    else:
        click.echo("Aborting cleaning!")


cli.add_command(deploy)
cli.add_command(destroy)
cli.add_command(breakdown)
# cli.add_command(output)
cli.add_command(clean)

if __name__ == "__main__":
    cli()
