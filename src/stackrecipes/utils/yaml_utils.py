import yaml
from stackrecipes.models.component import Component, ComponentMetadata
from stackrecipes.models.stack import Stack


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


def load_stack_yaml(path: str) -> Stack:
    with open(path, "r") as file:
        stack_data = yaml.safe_load(file)
        component_data = stack_data.get("components")

    return Stack(
        spec_version=stack_data.get("spec_version"),
        spec_type=stack_data.get("spec_type"),
        name=stack_data.get("name"),
        provider=stack_data.get("provider"),
        default_region=stack_data.get("default_region"),
        default_tags=stack_data.get("default_tags"),
        deployment_method=stack_data.get("deployment_method"),
        components=[
            load_component_yaml(component) for component in component_data
        ],
    )
