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
"""Stack model."""
import re
from typing import Dict, List, Optional

from pydantic import BaseModel, validator

from mlstacks.constants import PERMITTED_NAME_REGEX
from mlstacks.enums import (
    DeploymentMethodEnum,
    ProviderEnum,
)
from mlstacks.models.component import Component


class Stack(BaseModel):
    """Stack model.

    Attributes:
        spec_version: The version of the stack spec.
        spec_type: The type of the stack spec.
        name: The name of the stack.
        provider: The provider of the stack.
        default_region: The default region of the stack.
        default_tags: The default tags of the stack.
        deployment_method: The deployment method of the stack.
        components: The components of the stack.
    """

    spec_version: int = 1
    spec_type: str = "stack"
    name: str
    provider: ProviderEnum
    default_region: Optional[str]
    default_tags: Optional[Dict[str, str]] = None
    deployment_method: Optional[
        DeploymentMethodEnum
    ] = DeploymentMethodEnum.KUBERNETES
    components: List[Component] = []

    @validator("name")
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
        if not re.match(PERMITTED_NAME_REGEX, name):
            error_message = (
                "Name must start with an alphanumeric character "
                "and can only contain alphanumeric characters, "
                "underscores, and hyphens thereafter."
            )
            raise ValueError(error_message)
        return name
