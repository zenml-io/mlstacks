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
def cost(file: str) -> None:
    """Estimates the costs for an MLOps stack.

    Args:
        file (str): Path to the YAML file for breakdown
    """
    infracost_breakdown_stack(file)


cli.add_command(deploy)
cli.add_command(destroy)
cli.add_command(cost)

if __name__ == "__main__":
    cli()
