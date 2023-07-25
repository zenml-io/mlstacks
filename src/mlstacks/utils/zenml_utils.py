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

from typing import Dict, Union

from mlstacks.constants import ALLOWED_FLAVORS


def has_valid_flavor_combinations(
    provider: str, components: Dict[str, Union[bool, str]]
) -> bool:
    """Returns true if flavors have a valid combination.

    Certain component types only permit certain flavors, and certain providers
    only permit certain flavors. This function checks whether the given
    combination of provider and flavors is valid.

    Args:
        provider: The provider of the stack.
        components: The components of the stack.

    Returns:
        A boolean indicating whether the flavors are valid or not.
    """
    for component_type, component_flavor in components.items():
        if component_flavor not in ALLOWED_FLAVORS[component_type]:
            return False
        # for cases like artifact store, secrets manager and container registry
        # the flavor is the same as the cloud
        elif (
            component_flavor in {"s3", "sagemaker", "aws"}
            and provider != "aws"
        ):
            return False
        elif component_flavor in {"vertex", "gcp"} and provider != "gcp":
            return False
        elif component_flavor in {"minio"} and provider != "k3d":
            return False
    return True
