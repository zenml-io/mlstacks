import logging
from typing import Any, Dict, List
from unittest.mock import patch

import requests
from segment import analytics

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

analytics.write_key = "tU9BJvF05TgC29xgiXuKF7CuYP0zhgnx"
analytics.max_retries = 1


def mock_post_failure(*args, **kwargs):
    """Simulates a request failure."""
    response = requests.Response()
    response.status_code = 500
    response._content = (
        b'{"error": "Simulated failure", "code": "internal_error"}'
    )
    response.headers["Content-Type"] = "application/json"
    return response


def test_with_custom_on_error_handler():
    """Tests that the custom on_error handler is called on error."""
    handler_call_info = {"called": False}

    def custom_on_error_handler(error: Exception, batch: List[Dict[str, Any]]):
        handler_call_info["called"] = True
        logger.debug(
            "Custom on_error handler invoked:\nError: %s;\nBatch: %s",
            error,
            batch,
        )

    analytics.on_error = custom_on_error_handler

    with patch(
        "segment.analytics.request._session.post",
        side_effect=mock_post_failure,
    ):
        analytics.track("test_user_id", "Test Event", {"property": "value"})
        analytics.flush()

    assert handler_call_info[
        "called"
    ], "Custom on_error handler was not invoked"
