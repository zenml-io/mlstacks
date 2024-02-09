import logging
from unittest.mock import Mock, patch

import requests
from segment import analytics

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

analytics.write_key = "tU9BJvF05TgC29xgiXuKF7CuYP0zhgnx"
analytics.max_retries = 1

analytics.on_error = Mock()


def mock_post_failure(*args, **kwargs):
    response = requests.Response()
    response.status_code = 500
    response._content = (
        b'{"error": "Simulated failure", "code": "internal_error"}'
    )
    response.headers["Content-Type"] = "application/json"
    return response


def test_segment_custom_on_error_handler_invocation():
    with patch(
        "segment.analytics.request._session.post",
        side_effect=mock_post_failure,
    ):
        analytics.track("test_user_id", "Test Event", {"property": "value"})
        analytics.flush()

    analytics.on_error.assert_called()
