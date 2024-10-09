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
"""Utilities for mlstacks-ZenML interaction."""

from mlstacks.constants import ALLOWED_FLAVORS
from mlstacks.models.component import Component
from mlstacks.models.stack import Stack


def has_valid_flavor_combinations(
    stack: Stack,
    components: list[Component],
) -> bool:
    """Returns true if flavors have a valid combination.

    Certain component types only permit certain flavors, and certain providers
    only permit certain flavors. This function checks whether the given
    combination of provider and flavors is valid.

    Args:
        stack: The stack.
        components: The components.

    Returns:
        A boolean indicating whether the flavors are valid or not.
    """
    return not any(
        (
            (
                component.component_flavor
                not in ALLOWED_FLAVORS[component.component_type]
            )
            or (
                component.component_flavor in {"s3", "sagemaker", "aws"}
                and stack.provider != "aws"
            )
            or (
                component.component_flavor in {"vertex", "gcp"}
                and stack.provider != "gcp"
            )
            or (
                component.component_flavor in {"minio"}
                and stack.provider != "k3d"
            )
        )
        for component in components
    )
