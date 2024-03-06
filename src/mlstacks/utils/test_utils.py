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
"""Util functions for tests."""

from typing import List

from mlstacks.enums import ProviderEnum


def get_allowed_providers() -> List[str]:
    """Filter out unimplemented providers.

    Used for component and stack testing.

    Returns:
        A list of implemented providers
    """
    # Filter out AZURE
    excluded_providers = ["azure"]
    return [
        provider.value
        for provider in ProviderEnum
        if provider.value not in excluded_providers
    ]
