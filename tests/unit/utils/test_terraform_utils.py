#  Copyright (c) ZenML GmbH 2023. All Rights Reserved.
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at:
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
#  or implied. See the License for the specific language governing
#  permissions and limitations under the License.

import os
import random
import tempfile

import pytest
from hypothesis import given
from hypothesis.strategies import from_regex

from mlstacks.constants import PERMITTED_NAME_REGEX
from mlstacks.enums import ProviderEnum
from mlstacks.models.component import (
    Component,
    ComponentMetadata,
)
from mlstacks.models.stack import Stack
from mlstacks.utils.terraform_utils import (
    TerraformRunner,
    _compose_enable_key,
    _get_infracost_vars,
    get_recipe_metadata,
    parse_and_extract_component_variables,
    parse_and_extract_tf_vars,
    remote_state_bucket_exists,
    tf_definitions_present,
)
from mlstacks.utils.test_utils import get_allowed_providers

EXISTING_S3_BUCKET_URL = "s3://public-flavor-logos"
EXISTING_S3_BUCKET_REGION = "eu-central-1"
EXISTING_GCS_BUCKET_URL = "gs://zenml-public-bucket"
EXISTING_GCS_BUCKET_REGION = "europe-north1"


def test_terraform_runner_initialization_works():
    """Tests that the TerraformRunner can be initialized."""
    # create empty temporary yaml file
    with tempfile.NamedTemporaryFile(mode="w", delete=False) as f:
        f.write("")
        f_path = f.name
    try:
        runner = TerraformRunner(tf_recipe_path=f_path)
        # check that the TerraformRunner is initialized
        assert runner is not None
    finally:
        # remove temporary yaml file
        os.remove(f_path)


def test_terraform_runner_fails_with_invalid_recipe_path():
    """Tests that the runner doesn't work with empty file."""
    with pytest.raises(ValueError):
        TerraformRunner(tf_recipe_path="invalid_path")


@given(from_regex(PERMITTED_NAME_REGEX))
def test_enable_key_function_works(dummy_name: str):
    """Tests that the enable key function works.

    Args:
        dummy_name: A dummy name for the component.
    """
    c = Component(
        name=dummy_name,
        component_flavor="zenml",
        component_type="mlops_platform",
        provider=random.choice(list(ProviderEnum)).value,
    )
    key = _compose_enable_key(c)
    assert key == "enable_zenml"


@given(from_regex(PERMITTED_NAME_REGEX))
def test_enable_key_function_handles_components_with_flavors(dummy_name: str):
    """Tests that the enable key function works.

    Args:
        dummy_name: A dummy name for the component.
    """
    comp_flavor = "mlflow"
    comp_type = "experiment_tracker"
    c = Component(
        name=dummy_name,
        component_flavor=comp_flavor,
        component_type=comp_type,
        provider=random.choice(list(ProviderEnum)).value,
    )
    key = _compose_enable_key(c)
    assert key == "enable_experiment_tracker_mlflow"


@given(from_regex(PERMITTED_NAME_REGEX))
def test_enable_key_function_handles_components_without_flavors(
    dummy_name: str,
):
    """Tests that the enable key function works.

    Args:
        dummy_name: A dummy name for the component.
    """
    comp_flavor = "s3"
    comp_type = "artifact_store"
    comp_provider = "aws"
    c = Component(
        name=dummy_name,
        component_flavor=comp_flavor,
        component_type=comp_type,
        # provider=random.choice(list(ProviderEnum)).value,
        # Not sure why the above line was used when only "aws" is valid here
        provider=comp_provider,
    )
    key = _compose_enable_key(c)
    assert key == "enable_artifact_store"


def test_component_variable_parsing_works():
    """Tests that the component variable parsing works."""
    metadata = ComponentMetadata()
    component_flavor = "zenml"

    # random_test = random.choice(list(ProviderEnum)).value
    allowed_providers = get_allowed_providers()
    random_test = random.choice(allowed_providers)

    components = [
        Component(
            name="test",
            component_flavor=component_flavor,
            component_type="mlops_platform",
            provider=random_test,
            spec_type="component",
            spec_version=1,
            metadata=metadata,
        )
    ]
    variables = parse_and_extract_component_variables(components)
    assert variables
    variable_keys = variables.keys()
    assert f"enable_{component_flavor}" in variable_keys


def test_component_var_parsing_works_for_env_vars():
    """Tests that the component variable parsing works."""
    env_vars = {"ARIA_KEY": "blupus"}
    metadata = ComponentMetadata(environment_variables=env_vars)

    # EXCLUDE AZURE
    allowed_providers = get_allowed_providers()
    random_test = random.choice(allowed_providers)
    # random_test = random.choice(list(ProviderEnum)).value

    components = [
        Component(
            name="test",
            component_flavor="zenml",
            component_type="mlops_platform",
            provider=random_test,
            metadata=metadata,
        )
    ]
    variables = parse_and_extract_component_variables(components)
    assert variables
    variable_keys = variables.keys()
    assert "TF_VAR_ARIA_KEY" in variable_keys
    assert variables.get("TF_VAR_ARIA_KEY")
    assert variables.get("TF_VAR_ARIA_KEY") == "blupus"


def test_tf_variable_parsing_from_stack_works():
    """Tests that the Terraform variables extraction (from a stack) works."""
    # provider = random.choice(list(ProviderEnum)).value
    allowed_providers = get_allowed_providers()
    provider = random.choice(allowed_providers)

    component_flavor = "zenml"
    metadata = ComponentMetadata()
    components = [
        Component(
            name="test",
            component_flavor=component_flavor,
            component_type="mlops_platform",
            provider=provider,
            metadata=metadata,
        )
    ]
    stack = Stack(
        name="test",
        provider=provider,
        components=components,
    )
    variables = parse_and_extract_tf_vars(stack)
    assert variables
    variable_keys = variables.keys()
    assert "region" in variable_keys
    assert "additional_tags" in variable_keys
    assert f"enable_{component_flavor}" in variable_keys


def test_tf_definitions_present_works():
    """Checks whether Terraform definitions are present."""
    provider = random.choice(list(ProviderEnum)).value

    with tempfile.TemporaryDirectory() as tmp_dir:
        modular_dir = os.path.join(tmp_dir, "terraform", f"{provider}-modular")
        modules_dir = os.path.join(tmp_dir, "terraform", "modules")
        assert not tf_definitions_present(provider, tmp_dir)

        # Create the directories
        os.makedirs(modular_dir, exist_ok=True)
        os.makedirs(modules_dir, exist_ok=True)

        # Assert that the directories were created
        assert os.path.exists(modular_dir)
        assert os.path.exists(modules_dir)
        assert tf_definitions_present(
            provider=provider, base_config_dir=tmp_dir
        )


def test_recipe_metadata_extraction_works():
    """Tests that the recipe metadata extraction works."""
    provider = random.choice(list(ProviderEnum)).value
    with tempfile.TemporaryDirectory() as tmp_dir:
        modular_dir = os.path.join(tmp_dir, "terraform", f"{provider}-modular")

        # Create the modular_dir directory
        os.makedirs(modular_dir)

        # write a metadata.yaml file into that directory containing
        # {"test_key": "test_value"} as the contents (in YAML form)
        with open(os.path.join(modular_dir, "metadata.yaml"), "w") as f:
            f.write("test_key: test_value")
        metadata = get_recipe_metadata(
            provider=provider, base_config_dir=tmp_dir
        )
        assert metadata
        assert metadata.get("test_key")
        assert metadata.get("test_key") == "test_value"


def test_infracost_type_coercion_works():
    """Tests that the infracost type coercion works."""
    tf_vars = {"aria_age": "13"}
    infracost_vars = _get_infracost_vars(tf_vars)
    # assert all keys and values are strings
    assert all(isinstance(k, str) for k in infracost_vars.keys())
    assert all(isinstance(v, str) for v in infracost_vars.values())

    tf_vars_with_dict = {"aria_age": {"value": "13"}}
    infracost_vars_2 = _get_infracost_vars(tf_vars_with_dict)
    # assert all keys and values are strings
    assert all(isinstance(k, str) for k in infracost_vars_2.keys())
    assert all(isinstance(v, str) for v in infracost_vars_2.values())


def test_existing_gcs_bucket():
    """Test that the function correctly identifies an existing GCS bucket."""
    assert (
        remote_state_bucket_exists(
            EXISTING_GCS_BUCKET_URL, EXISTING_GCS_BUCKET_REGION
        )
        == True
    )


def test_existing_gcs_bucket_with_trailing_slash():
    """Test that the function correctly identifies an existing GCS bucket, even with a trailing slash."""
    assert (
        remote_state_bucket_exists(
            f"{EXISTING_GCS_BUCKET_URL}/", EXISTING_GCS_BUCKET_REGION
        )
        == True
    )


def test_existing_s3_bucket():
    """Test that the function correctly identifies an existing S3 bucket."""
    assert (
        remote_state_bucket_exists(
            EXISTING_S3_BUCKET_URL, EXISTING_S3_BUCKET_REGION
        )
        == True
    )


def test_existing_s3_bucket_with_trailing_slash():
    """Test that the function correctly identifies an existing S3 bucket, even with a trailing slash."""
    assert (
        remote_state_bucket_exists(
            f"{EXISTING_S3_BUCKET_URL}/", EXISTING_S3_BUCKET_REGION
        )
        == True
    )


def test_unsupported_url_scheme():
    """Test that the function raises a ValueError for unsupported URL schemes."""
    with pytest.raises(ValueError):
        remote_state_bucket_exists(
            "ftp://some-bucket", EXISTING_GCS_BUCKET_REGION
        )


def test_invalid_gcs_bucket():
    """Test that the function correctly identifies a non-existing GCS bucket."""
    assert (
        remote_state_bucket_exists(
            "gs://non-existent-gcs-bucket", EXISTING_GCS_BUCKET_REGION
        )
        == False
    )


def test_invalid_s3_bucket():
    """Test that the function correctly identifies a non-existing S3 bucket."""
    assert (
        remote_state_bucket_exists(
            "s3://non-existent-s3-bucket", EXISTING_S3_BUCKET_REGION
        )
        == False
    )
