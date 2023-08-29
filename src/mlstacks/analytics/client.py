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
from logging import getLogger
from types import TracebackType
from typing import Any, Dict, Optional, Type
from uuid import uuid4

import click
from segment import analytics

from mlstacks.constants import (
    ANALYTICS_OPT_IN_ENV_VARIABLE,
    MLSTACKS_PACKAGE_NAME,
)
from mlstacks.enums import AnalyticsEventsEnum
from mlstacks.utils.analytics_utils import operating_system, python_version
from mlstacks.utils.environment_utils import handle_bool_env_var
from mlstacks.utils.yaml_utils import load_yaml_as_dict

logger = getLogger(__name__)

analytics.write_key = "tU9BJvF05TgC29xgiXuKF7CuYP0zhgnx"

CONFIG_FILENAME = "config.yaml"


class MLStacksAnalyticsContext:
    """Analytics context manager for MLStacks."""

    def __init__(self) -> None:
        """Initialization."""
        self.analytics_opt_in = handle_bool_env_var(
            var=ANALYTICS_OPT_IN_ENV_VARIABLE,
            default=True,
        )
        self.user_id: Optional[str] = None

    def __enter__(self) -> "MLStacksAnalyticsContext":
        """Enter the analytics context manager.

        Returns:
            MLStacksAnalyticsContext: Analytics context manager
        """
        if self.analytics_opt_in and not self.get_analytics_user_id():
            self.user_id = str(uuid4())
            self.set_analytics_user_id(self.user_id)
            analytics.identify(
                self.user_id,
                {
                    "created_at": datetime.datetime.now(
                        tz=datetime.timezone.utc,
                    ),
                },
            )
        else:
            self.user_id = self.get_analytics_user_id()
        return self

    def __exit__(
        self,
        exc_type: Optional[Type[BaseException]],
        exc_val: Optional[BaseException],
        exc_tb: Optional[TracebackType],
    ) -> bool:
        """Exit context manager.

        Args:
            exc_type (Optional[Type[BaseException]]): Exception type
            exc_val (Optional[BaseException]): Exception value
            exc_tb (Optional[TracebackType]): Traceback type

        Returns:
            True if no exception occurred, False otherwise
        """
        if exc_val:
            logger.debug("Error occurred: %s", exc_val)
        return True

    def track(
        self,
        event: AnalyticsEventsEnum,
        properties: Optional[Dict[Any, Any]] = None,
    ) -> Any:
        """Tracks event in Segment.

        Args:
            event (AnalyticsEventsEnum): Event to track
            properties (Optional[Dict[Any, Any]]): Properties to track

        Returns:
            Result of the tracking
        """
        if self.analytics_opt_in:
            if properties is None:
                properties = {}

            return analytics.track(
                self.user_id,
                event.value,
                {
                    "timestamp": datetime.datetime.now(
                        tz=datetime.timezone.utc,
                    ),
                    "python_version": python_version(),
                    "operating_system": operating_system(),
                    **properties,
                },
            )
        return None

    @staticmethod
    def get_analytics_user_id() -> Optional[str]:
        """Returns the user id for analytics.

        Returns:
            The user id for analytics.
        """
        config_dir = click.get_app_dir(MLSTACKS_PACKAGE_NAME)
        config_file = os.path.join(config_dir, CONFIG_FILENAME)
        if os.path.exists(config_file):
            yaml_dict = load_yaml_as_dict(config_file)
            return yaml_dict.get("analytics_user_id", None)
        return None

    @staticmethod
    def set_analytics_user_id(user_id: str) -> None:
        """Sets the user id for analytics.

        Args:
            user_id: The user id for analytics.
        """
        config_dir = click.get_app_dir(MLSTACKS_PACKAGE_NAME)
        os.makedirs(config_dir, exist_ok=True)
        config_file = os.path.join(config_dir, CONFIG_FILENAME)
        with open(config_file, "w") as f:
            f.write(f"analytics_user_id: {user_id}")


def track_event(
    event: AnalyticsEventsEnum,
    metadata: Optional[Dict[str, Any]] = None,
) -> bool:
    """Track segment event if user opted-in.

    Args:
        event: Name of event to track in segment.
        metadata: Dict of metadata to track.

    Returns:
        True if event is sent successfully, False is not.
    """
    if metadata is None:
        metadata = {}

    metadata.setdefault("event_success", True)

    with MLStacksAnalyticsContext() as analytics_context:
        return bool(analytics_context.track(event=event, properties=metadata))
    return False


class EventHandler:
    """Context handler to enable tracking the success status of an event."""

    def __init__(
        self,
        event: AnalyticsEventsEnum,
        metadata: Optional[Dict[str, Any]] = None,
    ):
        """Initialization of the context manager.

        Args:
            event: The type of the analytics event
            metadata: The metadata of the event.
        """
        self.event: AnalyticsEventsEnum = event
        self.metadata: Dict[str, Any] = metadata or {}

    def __enter__(self) -> "EventHandler":
        """Enter function of the event handler.

        Returns:
            the handler instance.
        """
        return self

    def __exit__(
        self,
        type_: Optional[Any],
        value: Optional[Any],
        traceback: Optional[Any],
    ) -> Any:
        """Exit function of the event handler.

        Checks whether there was a traceback and updates the metadata
        accordingly. Following the check, it calls the function to track the
        event.

        Args:
            type_: The class of the exception
            value: The instance of the exception
            traceback: The traceback of the exception

        """
        if traceback is not None:
            self.metadata.update({"event_success": False})
        else:
            self.metadata.update({"event_success": True})

        if type_ is not None:
            self.metadata.update({"event_error_type": type_.__name__})

        track_event(self.event, self.metadata)
