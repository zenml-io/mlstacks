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
"""Component model."""

from typing import Dict, Optional

from pydantic import BaseModel, validator

from mlstacks.constants import (
    INVALID_COMPONENT_FLAVOR_ERROR_MESSAGE,
    INVALID_COMPONENT_TYPE_ERROR_MESSAGE,
    INVALID_NAME_ERROR_MESSAGE,
)
from mlstacks.enums import (
    ComponentFlavorEnum,
    ComponentSpecVersionEnum,
    ComponentTypeEnum,
    ProviderEnum,
    SpecTypeEnum,
)
from mlstacks.utils.model_utils import (
    is_valid_component_flavor,
    is_valid_component_type,
    is_valid_name,
)


class ComponentMetadata(BaseModel):
    """Component metadata model.

    Attributes:
        config: The configuration for the component.
        environment_variables: The environment variables for the component.
    """

    config: Optional[Dict[str, str]] = None
    environment_variables: Optional[Dict[str, str]] = None


class Component(BaseModel):
    """Component model.

    Attributes:
        spec_version: The version of the component spec.
        spec_type: The type of the component spec.
        name: The name of the component.
        component_type: The type of the component.
        provider: The provider of the component.
        metadata: The metadata of the component.
    """

    spec_version: ComponentSpecVersionEnum = 1
    spec_type: SpecTypeEnum = "component"
    name: str
    provider: ProviderEnum
    component_type: ComponentTypeEnum
    component_flavor: ComponentFlavorEnum
    metadata: Optional[ComponentMetadata] = None

    @validator("name")
    def validate_name(self, cls, name: str) -> str:  # noqa: N805
        """Validate the name.

        Name must start with an alphanumeric character and can only contain
        alphanumeric characters, underscores, and hyphens thereafter.

        Args:
            name: The name.

        Returns:
            The validated name.

        Raises:
            ValueError: If the name is invalid.
        """
        # Regular expression to ensure the first character is alphanumeric
        # and subsequent characters are alphanumeric, underscore, or hyphen
        if not is_valid_name(name):
            raise ValueError(INVALID_NAME_ERROR_MESSAGE)
        return name

    @validator("component_type")
    def validate_component_type(self, cls, component_type: str, values: dict) -> str:
        """Validate the component type.

        Artifact Store, Container Registry, Experiment Tracker, Orchestrator,
        MLOps Platform, and Model Deployer may be used with aws, gcp, and k3d
        providers. Step Operator may only be used with aws and gcp.

        Args:
            component_type: The component type.
            values: The previously validated component specs.

        Returns:
            The validated component type.

        Raises:
            ValueError: If the component type is invalid.
        """
        if not is_valid_component_type(component_type, values["provider"]):
            raise ValueError(INVALID_COMPONENT_TYPE_ERROR_MESSAGE)
        return component_type

    @validator("component_flavor")
    def validate_component_flavor(
        self, cls, component_flavor: str, values: dict
    ) -> str:
        """Validate the component flavor.

        Only certain flavors are allowed for a given provider-component type combination. For more information, consult the tables for your specified provider at the MLStacks documentation: https://mlstacks.zenml.io/stacks/stack-specification.

        Args:
            component_flavor: The component flavor.
            values: The previously validated component specs.

        Returns:
            The validated component flavor.

        Raises:
            ValueError: If the component flavor is invalid.
        """
        if not is_valid_component_flavor(component_flavor, values):
            raise ValueError(INVALID_COMPONENT_FLAVOR_ERROR_MESSAGE)
        return component_flavor
