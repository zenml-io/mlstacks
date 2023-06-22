import click
import os
from mlstacks.utils.terraform_utils import deploy_stack


@click.group()
def cli():
    pass


@click.command()
@click.option(
    "-f",
    "--file",
    required=True,
    type=click.Path(exists=True),
    help="Path to the YAML file for deploy",
)
def deploy(file):
    """This command deploys the stack based on a YAML file"""
    deploy_stack(file)


@click.command()
@click.option(
    "-f",
    "--file",
    required=True,
    type=click.Path(exists=True),
    help="Path to the YAML file for destroy",
)
def destroy(file):
    """This command destroys the stack based on a YAML file"""
    with open(file, "r") as file:
        content = file.read()
        click.echo(f"Destroying with the following file contents:\n{content}")


cli.add_command(deploy)
cli.add_command(destroy)

if __name__ == "__main__":
    cli()
