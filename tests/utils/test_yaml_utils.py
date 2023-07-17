import os
import tempfile

import pytest
import yaml

from mlstacks.utils.yaml_utils import load_yaml_as_dict


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
