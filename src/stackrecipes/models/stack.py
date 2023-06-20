from typing import Dict, List, Optional
from pydantic import BaseModel

from .component import Component


class Stack(BaseModel):
    version: str
    name: str
    default_region: Optional[str]
    default_tags: Optional[Dict[str, str]]
    components: List[Component]
