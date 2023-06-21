from typing import Dict, Optional
from pydantic import BaseModel


class ComponentMetadata(BaseModel):
    region: str
    config: Optional[Dict[str, str]]
    tags: Optional[Dict[str, str]]
    environment_variables: Optional[Dict[str, str]]


class Component(BaseModel):
    spec_version: int = 1
    component_type: str = "component"
    name: str
    provider: str
    metadata: ComponentMetadata
