from typing import List
from mlstacks.enums import ProviderEnum


def get_allowed_providers() -> List[str]:
    # Filter out AZURE
    excluded_providers = ["azure"]
    allowed_providers = [provider.value for provider in ProviderEnum if provider.value not in excluded_providers]
    return allowed_providers
