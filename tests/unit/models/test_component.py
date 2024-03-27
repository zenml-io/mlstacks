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

from hypothesis import assume, given
from hypothesis import strategies as st
from hypothesis.strategies import composite

from mlstacks.constants import ALLOWED_COMPONENT_TYPES, PERMITTED_NAME_REGEX
from mlstacks.enums import (
    ComponentFlavorEnum,
    ComponentTypeEnum,
    ProviderEnum,
)
from mlstacks.models.component import Component, ComponentMetadata


@composite
def valid_components(draw):
    # Drawing a valid provider enum member directly
    provider = draw(st.sampled_from([provider for provider in ProviderEnum]))

    # component_types and component_flavors are mappings to strings,
    # and model or validation layer handles string to enum conversion:
    component_types = list(ALLOWED_COMPONENT_TYPES[provider.value].keys())
    assume(component_types)
    component_type = draw(st.sampled_from(component_types))

    component_flavors = ALLOWED_COMPONENT_TYPES[provider.value][component_type]
    assume(component_flavors)

    component_flavor_str = draw(st.sampled_from(component_flavors))
    component_flavor_enum = ComponentFlavorEnum(
        component_flavor_str
    )  # Convert string to enum

    # Constructing the Component instance with valid fields
    return Component(
        name=draw(st.from_regex(PERMITTED_NAME_REGEX)),
        provider=provider.value,
        component_type=component_type,
        component_flavor=component_flavor_enum,
        spec_version=1,
        spec_type="component",
        metadata=None,
    )


@given(st.builds(ComponentMetadata))
def test_component_metadata(instance):
    assert instance.config is None or isinstance(instance.config, dict)
    assert instance.environment_variables is None or isinstance(
        instance.environment_variables, dict
    )


@given(valid_components())
def test_component(instance):
    print(f"instance: {instance}")
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
