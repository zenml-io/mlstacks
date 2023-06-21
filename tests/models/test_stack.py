from hypothesis import given, strategies as st

# TODO: fix imports
from src.stackrecipes.models.stack import Stack


@given(st.builds(Stack))
def test_component(instance):
    assert isinstance(instance.spec_version, int)
    assert isinstance(instance.spec_type, str)
    assert isinstance(instance.name, str)
    assert isinstance(instance.provider, str)
    assert instance.components is not None
    assert isinstance(instance.components, list)
