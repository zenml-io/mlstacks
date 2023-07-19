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
import random
import tempfile

import pytest
from hypothesis import given
from hypothesis.strategies import text

from mlstacks.enums import ComponentFlavorEnum, ComponentTypeEnum, ProviderEnum
from mlstacks.models.component import (
    Component,
)
from mlstacks.utils.terraform_utils import TerraformRunner


def test_terraform_runner_initialisation_works():
    """Tests that the TerraformRunner can be initialised."""
    # create empty temporary yaml file
    with tempfile.NamedTemporaryFile(mode="w", delete=False) as f:
        f.write("")
        f_path = f.name
    try:
        # initialise TerraformRunner
        runner = TerraformRunner(tf_recipe_path=f_path)
        # check that the TerraformRunner is initialised
        assert runner is not None
    finally:
        # remove temporary yaml file
        os.remove(f_path)


def test_terraform_runner_fails_with_invalid_recipe_path():
    """Tests that the runner doesn't work with empty file."""
    with pytest.raises(ValueError):
        TerraformRunner(tf_recipe_path="invalid_path")


@given(text(min_size=1))
def test_enable_key_function_works(dummy_name: str):
    """Tests that the enable key function works."""
    Component(
        name=dummy_name,
        component_flavor=random.choice(list(ComponentFlavorEnum)),
        component_type=random.choice(list(ComponentTypeEnum)),
        provider=random.choice(list(ProviderEnum)),
    )
