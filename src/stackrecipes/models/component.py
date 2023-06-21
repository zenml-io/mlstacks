from typing import Dict, Optional
from pydantic import BaseModel


class ComponentMetadata(BaseModel):
    region: str
    config: Optional[Dict[str, str]]
    tags: Optional[Dict[str, str]]
    environment_variables: Optional[Dict[str, str]]


class Component(BaseModel):
    spec_version: int = 1
    spec_type: str = "component"
    component_type: str
    name: str
    provider: str
    metadata: ComponentMetadata
