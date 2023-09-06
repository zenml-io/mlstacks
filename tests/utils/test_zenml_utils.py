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
"""Tests for utilities for mlstacks-ZenML interaction."""

from mlstacks.models.component import Component
from mlstacks.models.stack import Stack
from mlstacks.utils.zenml_utils import has_valid_flavor_combinations


def test_has_valid_flavor_combinations():
    """Checks that the flavor combination validator works.

    Testing positive cases.
    """
    valid_stack = Stack(
        name="aria-stack",
        provider="aws",
        components=[],
    )
    valid_component = Component(
        name="blupus-component",
        component_type="mlops_platform",
        component_flavor="zenml",
        provider=valid_stack.provider,
    )
    assert has_valid_flavor_combinations(
        stack=valid_stack,
        components=[valid_component],
    )


def test_flavor_combination_validator_fails_aws_gcp():
    """Checks that the flavor combination validator fails.

    Tests a known failure case. (AWS Stack with a GCP artifact store.)
    """
    valid_stack = Stack(
        name="aria-stack",
        provider="aws",
        components=[],
    )
    invalid_component = Component(
        name="blupus-component",
        component_type="artifact_store",
        component_flavor="gcp",
        provider=valid_stack.provider,
    )
    assert not has_valid_flavor_combinations(
        stack=valid_stack,
        components=[invalid_component],
    )


def test_flavor_combination_validator_fails_k3d_s3():
    """Checks that the flavor combination validator fails.

    Tests a known failure case. (K3D Stack with a S3 artifact store.)
    """
    valid_stack = Stack(
        name="aria-stack",
        provider="k3d",
        components=[],
    )
    invalid_component = Component(
        name="blupus-component",
        component_type="artifact_store",
        component_flavor="s3",
        provider=valid_stack.provider,
    )
    assert not has_valid_flavor_combinations(
        stack=valid_stack,
        components=[invalid_component],
    )
