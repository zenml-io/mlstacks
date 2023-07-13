"""Utility functions for loading YAML files into Python objects."""

from pathlib import Path
from typing import Any, Dict, Union

import yaml

from mlstacks.models.component import (
    Component,
    ComponentMetadata,
)
from mlstacks.models.stack import Stack


def load_yaml_as_dict(path: Union[Path, str]) -> Dict[str, Any]:
    """Loads a yaml file as a dictionary.

    Args:
        path: The path to the yaml file.

    Returns:
        The dictionary representation of the yaml file.
    """
    if type(path) == Path:
        str_path = str(path)

    if not Path(path).exists():
        raise FileNotFoundError(f"File {path} not found.")

    with open(str_path) as yaml_file:
        yaml_dict = yaml.safe_load(yaml_file)
    return yaml_dict


def load_component_yaml(path: str) -> Component:
    """Load component YAML file as a Pydantic model.

    Args:
        path: The path to the component YAML file.

    Returns:
        The component model.
    """
    with open(path) as file:
        component_data = yaml.safe_load(file)

    return Component(
        spec_version=component_data.get("spec_version"),
        spec_type=component_data.get("spec_type"),
        component_type=component_data.get("component_type"),
        component_flavor=component_data.get("component_flavor"),
        name=component_data.get("name"),
        provider=component_data.get("provider"),
        metadata=ComponentMetadata(
            region=component_data.get("metadata").get("region"),
            config=component_data.get("metadata").get("config"),
            tags=component_data.get("metadata").get("tags"),
            environment_variables=component_data.get("metadata").get(
                "environment_variables",
            ),
        ),
    )


def load_stack_yaml(path: str) -> Stack:
    """Load stack YAML file as a Pydantic model.

    Args:
        path: The path to the stack YAML file.

    Returns:
        The stack model.
    """
    with open(path) as yaml_file:
        stack_data = yaml.safe_load(yaml_file)
        component_data = stack_data.get("components")

    return Stack(
        spec_version=stack_data.get("spec_version"),
        spec_type=stack_data.get("spec_type"),
        name=stack_data.get("name"),
        provider=stack_data.get("provider"),
        default_region=stack_data.get("default_region"),
        default_tags=stack_data.get("default_tags"),
        deployment_method=stack_data.get("deployment_method"),
        components=[
            load_component_yaml(component) for component in component_data
        ],
    )
