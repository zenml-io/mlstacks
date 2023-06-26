import click

from mlstacks.utils.terraform_utils import deploy_stack, destroy_stack


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
def destroy(file):
    """This command destroys the stack based on a YAML file.

    Args:
        file (str): Path to the YAML file for destroy
    """
    destroy_stack(file)


cli.add_command(deploy)
cli.add_command(destroy)

if __name__ == "__main__":
    cli()
