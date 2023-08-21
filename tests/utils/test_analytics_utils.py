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
"""Tests for Analytics utils for MLStacks."""

import sys

import pytest

from mlstacks.utils.analytics_utils import operating_system, python_version


@pytest.mark.skipif(
    sys.version_info != (3, 10) and sys.platform != "linux",
    reason="This test is only for Python 3.10 on Linux.",
)
def test_metadata_for_analytics():
    """Tests if Python version and operating system is returned correctly."""
    assert python_version() == "3.10"
    assert operating_system() == "linux"
