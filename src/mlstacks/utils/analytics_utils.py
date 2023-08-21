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
"""Analytics utils for MLStacks."""

import sys


def python_version() -> str:
    """Returns the python version currently running.

    Returns:
        str: python version
    """
    return ".".join(map(str, sys.version_info[:3]))


def operating_system() -> str:
    """Returns the operating system currently running.

    Returns:
        str: operating system
    """
    return sys.platform
