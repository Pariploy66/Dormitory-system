"""
Forwards validated access events to NestJS via the internal API.
Uses X-Internal-API-Key header for service-to-service auth.
"""
import logging

import httpx

from app.config import settings
from app.models.schemas import ExternalAccessEvent, IngestPayload

logger = logging.getLogger(__name__)

_nestjs = httpx.AsyncClient(
    base_url=settings.nestjs_base_url,
    headers={"X-Internal-API-Key": settings.internal_api_key},
    timeout=10.0,
)


async def forward_event(event: ExternalAccessEvent) -> bool:
    """
    Sends a single access event to NestJS.
    Returns True on success, False if NestJS returns a non-2xx (e.g. duplicate).
    """
    payload = IngestPayload(
        externalStudentId=event.student_id,
        accessTime=event.event_time.isoformat(),
        type=event.event_type,
        gateName=event.gate_name,
    )

    try:
        response = await _nestjs.post(
            "/internal/access-logs",
            json=payload.model_dump(),
        )
        if response.status_code == 409:
            # NestJS returned conflict — duplicate, harmless
            return False
        response.raise_for_status()
        return True
    except httpx.HTTPStatusError as e:
        logger.error("NestJS rejected event %s: %s", event.student_id, e)
        return False
    except httpx.HTTPError as e:
        logger.error("NestJS unreachable: %s", e)
        return False
