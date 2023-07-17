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
