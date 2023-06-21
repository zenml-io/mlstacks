import yaml
from stackrecipes.models.component import Component, ComponentMetadata


def load_component_yaml(path: str) -> Component:
    with open(path, "r") as file:
        component_data = yaml.safe_load(file)

    return Component(
        spec_version=component_data.get("spec_version"),
        spec_type=component_data.get("spec_type"),
        component_type=component_data.get("component_type"),
        name=component_data.get("name"),
        provider=component_data.get("provider"),
        metadata=ComponentMetadata(
            region=component_data.get("metadata").get("region"),
            config=component_data.get("metadata").get("config"),
            tags=component_data.get("metadata").get("tags"),
            environment_variables=component_data.get("metadata").get(
                "environment_variables"
            ),
        ),
    )
