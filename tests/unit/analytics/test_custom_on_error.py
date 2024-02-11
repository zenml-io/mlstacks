import logging
from typing import Any, Dict, List
from unittest.mock import patch

import pytest
import requests
from segment import analytics

logger = logging.getLogger(__name__)


@pytest.fixture(autouse=True)
def reset_analytics_client():
    default_on_error = analytics.on_error

    yield

    analytics.on_error = default_on_error


def mock_post_failure(*args, **kwargs):
    response = requests.Response()
    response.status_code = 500
    response._content = (
        b'{"error": "Simulated failure", "code": "internal_error"}'
    )
    response.headers["Content-Type"] = "application/json"
    return response


def custom_on_error(error: Exception, batch: List[Dict[str, Any]]) -> None:
    logger.debug("Analytics error: %s; Batch: %s", error, batch)


@pytest.mark.usefixtures("reset_analytics_client")
def test_segment_custom_on_error_handler_invocation(caplog):
    with caplog.at_level(logging.DEBUG):
        with patch(
            "segment.analytics.request._session.post",
            side_effect=mock_post_failure,
        ):
            analytics.track(
                "test_user_id", "Test Event", {"property": "value"}
            )
            analytics.flush()

    assert "Analytics error:" in caplog.text
