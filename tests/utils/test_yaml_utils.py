import os
import tempfile

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
