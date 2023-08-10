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
    if isinstance(path, Path):
        path = str(path)

    if not Path(path).exists():
        raise FileNotFoundError(f"File {path} not found.")

    with open(path) as yaml_file:
        yaml_content = yaml.safe_load(yaml_file)

    # If the content isn't a dict or is None, return an empty dict.
    return yaml_content if isinstance(yaml_content, dict) else {}


def load_component_yaml(path: str) -> Component:
    """Load component YAML file as a Pydantic model.

    Args:
        path: The path to the component YAML file.

    Returns:
        The component model.
    """
    with open(path) as file:
        component_data = yaml.safe_load(file)

    if component_data.get("metadata") is None:
        component_data["metadata"] = {}

    return Component(
        spec_version=component_data.get("spec_version"),
        spec_type=component_data.get("spec_type"),
        name=component_data.get("name"),
        component_type=component_data.get("component_type"),
        component_flavor=component_data.get("component_flavor"),
        provider=component_data.get("provider"),
        metadata=ComponentMetadata(
            config=component_data.get("metadata").get("config"),
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

    if component_data is None:
        component_data = []
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
