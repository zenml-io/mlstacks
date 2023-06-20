from typing import Dict, Optional
from pydantic import BaseModel


class ComponentMetadata(BaseModel):
    configuration: Optional[Dict[str, str]]
    tags: Optional[Dict[str, str]]
    region: Optional[str]
    environment_variables: Optional[Dict[str, str]]


class Component(BaseModel):
    name: str
    deployment_type: str = "KUBERNETES"
    metadata: Optional[ComponentMetadata]
