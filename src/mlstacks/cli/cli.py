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


import click

from mlstacks.utils.terraform_utils import (
    deploy_stack,
    destroy_stack,
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
def deploy(file: str) -> None:
    """Deploys a stack based on a YAML file.

    Args:
        file (str): Path to the YAML file for deploy
    """
    deploy_stack(file)


@click.command()
@click.option(
    "-f",
    "--file",
    required=True,
    type=click.Path(exists=True),
    help="Path to the YAML file for destroy",
)
def destroy(file: str) -> None:
    """Destroys a stack based on a YAML file.

    Args:
        file (str): Path to the YAML file for destroy
    """
    destroy_stack(file)


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
    "-n",
    "--name",
    required=True,
    type=str,
    help="Stack recipe name",
)
def output(recipe_name: str) -> None:
    """Estimates the costs for an MLOps stack.

    Args:
        file (str): Path to the YAML file for breakdown
    """
    get_stack_outputs(recipe_name)


cli.add_command(deploy)
cli.add_command(destroy)
cli.add_command(breakdown)

if __name__ == "__main__":
    cli()
