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
    """This command deploys the stack based on a YAML file.

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
    """This command destroys the stack based on a YAML file.

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
    help="Path to the YAML file for Infracost breakdown",
)
def breakdown(file: str) -> None:
    """This command estimates the costs for a stack based on a YAML file.

    Args:
        file (str): Path to the YAML file for breakdown
    """
    infracost_breakdown_stack(file)


cli.add_command(deploy)
cli.add_command(destroy)
cli.add_command(breakdown)

if __name__ == "__main__":
    cli()
