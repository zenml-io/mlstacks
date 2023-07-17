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

from mlstacks.enums import ComponentFlavorEnum, ComponentTypeEnum
from mlstacks.models.component import Component, ComponentMetadata


@given(st.builds(ComponentMetadata))
def test_component_metadata(instance):
    assert instance.config is None or isinstance(instance.config, dict)
    assert instance.environment_variables is None or isinstance(
        instance.environment_variables, dict
    )


@given(st.builds(Component))
def test_component(instance):
    assert isinstance(instance.spec_version, int)
    assert isinstance(instance.spec_type, str)
    assert isinstance(instance.name, str)
    assert instance.name is not None
    assert instance.spec_version is not None
    assert instance.spec_type is not None
    assert isinstance(instance.component_type, ComponentTypeEnum)
    assert isinstance(instance.component_flavor, ComponentFlavorEnum)
    assert isinstance(instance.provider, str)
    assert instance.provider is not None
    assert (
        isinstance(instance.metadata, ComponentMetadata)
        or instance.metadata is None
    )
