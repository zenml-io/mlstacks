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
"""Util functions for Pydantic models and validation."""

import re

from mlstacks.constants import ALLOWED_COMPONENT_TYPES, PERMITTED_NAME_REGEX


def is_valid_name(name: str) -> bool:
    """Check if the name is valid.

    Used for components and stacks.

    Args:
        name: The name.

    Returns:
        True if the name is valid, False otherwise.
    """
    return re.match(PERMITTED_NAME_REGEX, name) is not None


def is_valid_component_type(component_type: str, provider: str) -> bool:
    """Check if the component type is valid.

    Used for components.

    Args:
        component_type: The component type.
        provider: The provider.

    Returns:
        True if the component type is valid, False otherwise.
    """
    allowed_types = list(ALLOWED_COMPONENT_TYPES[provider].keys())
    return component_type in allowed_types


def is_valid_component_flavor(
    component_flavor: str,
    component_type: str,
    provider: str,
) -> bool:
    """Check if the component flavor is valid.

    Used for components.

    Args:
        component_flavor: The component flavor.
        component_type: The component type.
        provider: The provider.

    Returns:
        True if the component flavor is valid, False otherwise.
    """
    try:
        is_valid = (
            component_flavor
            in ALLOWED_COMPONENT_TYPES[provider][component_type]
        )
    except KeyError:
        return False

    return is_valid
