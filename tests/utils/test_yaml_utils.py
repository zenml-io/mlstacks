import os
import tempfile

import pytest
import yaml
from pydantic import ValidationError

from mlstacks.models.component import (
    Component,
)
from mlstacks.utils.yaml_utils import load_component_yaml, load_yaml_as_dict


def test_load_valid_yaml_file():
    with tempfile.NamedTemporaryFile(mode="w", delete=False) as f:
        f.write("name: John\nage: 30")
        f_path = f.name
    try:
        expected = {"name": "John", "age": 30}
        result = load_yaml_as_dict(f_path)
        assert result == expected
    finally:
        os.remove(f_path)


def test_load_empty_yaml_file():
    with tempfile.NamedTemporaryFile(mode="w", delete=False) as f:
        f.write("")
        f_path = f.name
    try:
        expected = {}
        result = load_yaml_as_dict(f_path)
        assert result == expected
    finally:
        os.remove(f_path)


# Tests that an error is raised when loading a non-existent yaml file
def test_load_non_existent_yaml_file():
    with pytest.raises(FileNotFoundError):
        load_yaml_as_dict("non_existent_file.yaml")


# Tests that an error is raised when loading a yaml file with invalid syntax
def test_load_yaml_file_with_invalid_syntax():
    with tempfile.NamedTemporaryFile(mode="w", delete=False) as f:
        f.write("name: John\nage: 30:")
        f_path = f.name
    try:
        with pytest.raises(yaml.YAMLError):
            load_yaml_as_dict(f_path)
    finally:
        os.remove(f_path)


# Tests that a yaml file with null values is loaded as a dictionary with None values
def test_load_yaml_file_with_null_values():
    with tempfile.NamedTemporaryFile(mode="w", delete=False) as f:
        f.write("name: null\nage: null")
        f_path = f.name
    try:
        expected = {"name": None, "age": None}
        result = load_yaml_as_dict(f_path)
        assert result == expected
    finally:
        os.remove(f_path)


# Tests that a yaml file with nested dictionaries is loaded as a nested dictionary
def test_load_yaml_file_with_nested_dictionaries():
    with tempfile.NamedTemporaryFile(mode="w", delete=False) as f:
        f.write("person:\n  name: John\n  age: 30")
        f_path = f.name
    try:
        expected = {"person": {"name": "John", "age": 30}}
        result = load_yaml_as_dict(f_path)
        assert result == expected
    finally:
        os.remove(f_path)


# Tests that a yaml file with non-string keys is loaded as a dictionary with non-string keys
def test_load_yaml_file_with_non_string_keys():
    with tempfile.NamedTemporaryFile(mode="w", delete=False) as f:
        f.write("1: John\n2: 30")
        f_path = f.name
    try:
        expected = {1: "John", 2: 30}
        result = load_yaml_as_dict(f_path)
        assert result == expected
    finally:
        os.remove(f_path)


# Tests that a yaml file with duplicate keys is loaded as a dictionary with the last value for each key
def test_load_yaml_file_with_duplicate_keys():
    with tempfile.NamedTemporaryFile(mode="w", delete=False) as f:
        f.write("name: John\nage: 30\nname: Jane")
        f_path = f.name
    try:
        expected = {"name": "Jane", "age": 30}
        result = load_yaml_as_dict(f_path)
        assert result == expected
    finally:
        os.remove(f_path)


# Tests that a yaml file with special characters is loaded as a dictionary
def test_load_yaml_file_with_special_characters():
    with tempfile.NamedTemporaryFile(mode="w", delete=False) as f:
        f.write("name: John Doe\noccupation: Software Engineer @ ACME")
        f_path = f.name
    try:
        expected = {
            "name": "John Doe",
            "occupation": "Software Engineer @ ACME",
        }
        result = load_yaml_as_dict(f_path)
        assert result == expected
    finally:
        os.remove(f_path)


def test_load_component_yaml_valid_input(tmp_path):
    yaml_content = """
    spec_version: 1
    spec_type: component
    name: test
    component_type: mlops_platform
    component_flavor: zenml
    provider: aws
    metadata:
        config: 
            key: value
        environment_variables: 
            key: value
    """

    yaml_file = tmp_path / "component.yaml"
    yaml_file.write_text(yaml_content)

    result = load_component_yaml(str(yaml_file))
    assert isinstance(result, Component)
    assert result.spec_version == 1
    assert result.spec_type == "component"
    assert result.name == "test"


def test_load_component_yaml_invalid_input(tmp_path):
    yaml_content = """
    invalid_key: invalid_value
    """

    yaml_file = tmp_path / "component_invalid.yaml"
    yaml_file.write_text(yaml_content)

    with pytest.raises(ValidationError):
        load_component_yaml(str(yaml_file))


def test_load_component_yaml_file_not_found():
    with pytest.raises(FileNotFoundError):
        load_component_yaml("non_existent_file.yaml")
