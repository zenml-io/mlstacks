import pytest
from hypothesis import given, strategies as st

# TODO: fix imports
from src.stackrecipes.models.component import Component, ComponentMetadata


@given(st.builds(ComponentMetadata))
def test_component_metadata(instance):
    assert instance.region is None or isinstance(instance.region, str)


@given(st.builds(Component))
def test_component(instance):
    assert instance.name is not None
