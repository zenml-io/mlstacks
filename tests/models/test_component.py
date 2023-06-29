from hypothesis import given
from hypothesis import strategies as st

from mlstacks.models.component import Component, ComponentMetadata


@given(st.builds(ComponentMetadata))
def test_component_metadata(instance):
    assert instance.region is None or isinstance(instance.region, str)


@given(st.builds(Component))
def test_component(instance):
    assert isinstance(instance.spec_version, int)
    assert isinstance(instance.spec_type, str)
    assert isinstance(instance.component_type, str)
    assert isinstance(instance.name, str)
    assert isinstance(instance.provider, str)
    assert isinstance(instance.metadata, ComponentMetadata)
    assert instance.metadata is not None
