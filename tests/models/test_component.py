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
