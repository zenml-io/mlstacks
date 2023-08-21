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
"""Analytics module for MLStacks."""

import datetime
import os
from typing import Optional
from uuid import uuid4

import click
import segment.analytics as analytics

from mlstacks.constants import MLSTACKS_PACKAGE_NAME
from mlstacks.utils.yaml_utils import load_yaml_as_dict

analytics.write_key = "tU9BJvF05TgC29xgiXuKF7CuYP0zhgnx"

CONFIG_FILENAME = "config.yaml"


def get_analytics_user_id() -> Optional[str]:
    """Returns the user id for analytics.

    Returns:
        str: user id
    """
    # read user_id from config_file
    config_dir = click.get_app_dir(MLSTACKS_PACKAGE_NAME)
    config_file = os.path.join(config_dir, CONFIG_FILENAME)
    if os.path.exists(config_file):
        yaml_dict = load_yaml_as_dict(config_file)
        return yaml_dict.get("analytics_user_id", None)


def set_analytics_user_id(user_id: str) -> None:
    """Sets the user id for analytics.

    Args:
        user_id (uuid4): user id
    """
    config_dir = click.get_app_dir(MLSTACKS_PACKAGE_NAME)
    os.makedirs(config_dir, exist_ok=True)
    config_file = os.path.join(config_dir, CONFIG_FILENAME)
    # write user_id to config_file
    with open(config_file, "w") as f:
        f.write(f"analytics_user_id: {user_id}")


if (
    not os.environ.get("MLSTACKS_ANALYTICS_OPT_OUT")
    and not get_analytics_user_id()
):
    user_id = str(uuid4())
    set_analytics_user_id(user_id)
    analytics.identify(
        user_id,
        {
            "created_at": datetime.datetime.now(),
        },
    )
