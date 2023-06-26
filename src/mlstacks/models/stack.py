"""Stack model."""

from typing import Dict, List, Optional

from pydantic import BaseModel

from .component import Component


class Stack(BaseModel):
    """Stack model.

    Attributes:
        spec_version: The version of the stack spec.
        spec_type: The type of the stack spec.
        name: The name of the stack.
        provider: The provider of the stack.
        default_region: The default region of the stack.
        default_tags: The default tags of the stack.
        deployment_method: The deployment method of the stack.
        components: The components of the stack.
    """

    spec_version: int = 1
    spec_type: str = "stack"
    name: str
    provider: str
    default_region: Optional[str]
    default_tags: Optional[Dict[str, str]]
    deployment_method: Optional[str] = "kubernetes"
    components: List[Component] = []
