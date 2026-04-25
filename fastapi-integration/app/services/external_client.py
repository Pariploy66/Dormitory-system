"""
Client for the external Access Control system.
Uses Tenacity for automatic retry with exponential back-off so a
temporary outage of the external API doesn't break the integration layer.
"""
import logging
from datetime import datetime

import httpx
from tenacity import (
    retry,
    stop_after_attempt,
    wait_exponential,
    retry_if_exception_type,
    before_sleep_log,
)

from app.config import settings
from app.models.schemas import ExternalApiResponse

logger = logging.getLogger(__name__)

# Shared async client — reused across poll cycles
_client = httpx.AsyncClient(
    base_url=settings.external_api_base_url,
    headers={"Authorization": f"Bearer {settings.external_api_key}"},
    timeout=15.0,
)


@retry(
    retry=retry_if_exception_type((httpx.HTTPError, httpx.TimeoutException)),
    stop=stop_after_attempt(5),
    wait=wait_exponential(multiplier=1, min=2, max=30),
    before_sleep=before_sleep_log(logger, logging.WARNING),
    reraise=True,
)
async def fetch_events_since(since: datetime) -> ExternalApiResponse:
    """
    Fetch access events from the external API that occurred after `since`.
    Retries up to 5 times with exponential back-off on network errors.
    """
    response = await _client.get(
        "/access-events",
        params={
            "since": since.isoformat(),
            "limit": 200,
        },
    )
    response.raise_for_status()

    data = response.json()
    return ExternalApiResponse.model_validate(data)
