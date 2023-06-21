from typing import Dict, List, Optional
from pydantic import BaseModel

from .component import Component


class Stack(BaseModel):
    spec_version: int = 1
    spec_type: str = "stack"
    name: str
    provider: str
    default_region: Optional[str]
    default_tags: Optional[Dict[str, str]]
    deployment_method: Optional[str] = "kubernetes"
    components: List[Component]
