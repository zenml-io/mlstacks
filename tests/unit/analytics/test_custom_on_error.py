import pytest
from segment import analytics
import logging
from unittest.mock import patch, Mock
import requests
import uuid


logger = logging.getLogger(__name__)
analytics.max_retries = 0


def mock_post_failure(*args, **kwargs):
    response = requests.Response()
    response.status_code = 500
    response._content = b'{"error": "Simulated failure", "code": "internal_error"}'
    response.headers['Content-Type'] = 'application/json'
    return response


@pytest.fixture(autouse=True)
def reset_analytics_client():
    """Sets a unique write_key for each test session to ensure test isolation."""
    unique_write_key = str(uuid.uuid4())
    original_write_key = analytics.write_key
    analytics.write_key = unique_write_key

    original_max_retries = analytics.max_retries
    original_on_error = analytics.on_error

    yield

    # Reset analytics client configurations after each test
    analytics.write_key = original_write_key
    analytics.max_retries = original_max_retries
    analytics.on_error = original_on_error


@pytest.mark.usefixtures("reset_analytics_client")
def test_segment_custom_on_error_handler_invocation(caplog):
    with caplog.at_level(logging.CRITICAL), \
            patch('segment.analytics.request._session.post', side_effect=mock_post_failure), \
            patch('segment.analytics.on_error', Mock()) as mock_on_error:
        analytics.track('test_user_id', 'Test Event', {'property': 'value'})
        analytics.flush()

    mock_on_error.assert_called()
