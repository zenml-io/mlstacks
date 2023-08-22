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

import os

import click
import pytest
from hypothesis import given
from hypothesis import strategies as st

from mlstacks.constants import MLSTACKS_PACKAGE_NAME, PERMITTED_NAME_REGEX
from mlstacks.utils.cli_utils import _get_spec_dir, error

SPEC_BASE_DIR = click.get_app_dir(MLSTACKS_PACKAGE_NAME)


@given(st.from_regex(PERMITTED_NAME_REGEX))
def test_get_spec_dir(stack_name: str):
    spec_dir = _get_spec_dir(stack_name)
    assert spec_dir == os.path.join(SPEC_BASE_DIR, f"stack_specs/{stack_name}")
    assert isinstance(spec_dir, str)


def test_error_raises_error():
    with pytest.raises(click.ClickException):
        error("error message")
