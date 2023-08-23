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

from hypothesis import given
from hypothesis import strategies as st

from mlstacks.enums import DeploymentMethodEnum, ProviderEnum
from mlstacks.models.stack import Stack


@given(st.builds(Stack))
def test_stack(instance):
    assert isinstance(instance.spec_version, int)
    assert isinstance(instance.spec_type, str)
    assert isinstance(instance.name, str)
    assert isinstance(instance.provider, ProviderEnum)
    assert instance.components is not None
    assert isinstance(instance.components, list)
    assert (
        isinstance(instance.default_region, str)
        or instance.default_region is None
    )
    assert (
        isinstance(instance.default_tags, dict)
        or instance.default_tags is None
    )
    assert isinstance(instance.deployment_method, DeploymentMethodEnum)
