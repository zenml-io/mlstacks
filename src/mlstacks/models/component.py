"""Component model."""


from typing import Dict, Optional

from pydantic import BaseModel

from mlstacks.enums import (
    ComponentFlavorEnum,
    ComponentTypeEnum,
    ProviderEnum,
)


class ComponentMetadata(BaseModel):
    """Component metadata model.

    Attributes:
        config: The configuration for the component.
        environment_variables: The environment variables for the component.
    """

    config: Optional[Dict[str, str]] = None
    environment_variables: Optional[Dict[str, str]] = None


class Component(BaseModel):
    """Component model.

    Attributes:
        spec_version: The version of the component spec.
        spec_type: The type of the component spec.
        component_type: The type of the component.
        name: The name of the component.
        provider: The provider of the component.
        metadata: The metadata of the component.
    """

    spec_version: int = 1
    spec_type: str = "component"
    component_type: ComponentTypeEnum
    component_flavor: ComponentFlavorEnum
    name: str
    provider: ProviderEnum
    metadata: ComponentMetadata
