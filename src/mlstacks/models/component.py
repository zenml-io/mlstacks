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

from pydantic import field_validator, BaseModel

from mlstacks.constants import INVALID_NAME_ERROR_MESSAGE
from mlstacks.enums import (
    ComponentFlavorEnum,
    ComponentTypeEnum,
    ProviderEnum,
)
from mlstacks.utils.model_utils import is_valid_name


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

    spec_version: int = 1
    spec_type: str = "component"
    name: str
    component_type: ComponentTypeEnum
    component_flavor: ComponentFlavorEnum
    provider: ProviderEnum
    metadata: Optional[ComponentMetadata] = None

    @field_validator("name")
    @classmethod
    def validate_name(cls, name: str) -> str:  # noqa: N805
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
