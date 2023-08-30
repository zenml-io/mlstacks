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
"""Environment utilities for mlstacks."""
import os


def handle_bool_env_var(var: str, default: bool = False) -> bool:
    """Converts normal env var to boolean.

    Args:
        var: The environment variable to convert.
        default: The default value to return if the env var is not set.

    Returns:
        The converted value.
    """
    value = os.getenv(var)

    if value in ["1", "y", "yes", "True", "true"]:
        return True

    if value in ["0", "n", "no", "False", "false"]:
        return False

    return default
