from datetime import datetime, timezone, timedelta
from typing import Literal
from pydantic import BaseModel, field_validator

# External Access Control system operates in Thailand (UTC+7).
# All naive datetimes received from it are assumed to be Thai local time.
_THAI_TZ = timezone(timedelta(hours=7))


class ExternalAccessEvent(BaseModel):
    """Represents a raw event from the external Access Control API."""
    student_id: str          # external system's student identifier
    student_code: str
    student_name: str
    event_time: datetime
    event_type: Literal["IN", "OUT"]
    gate_name: str
    # Access Control also returns two photos per event (optional):
    #   photo_url      → รูปภาพ (reference/profile photo)
    #   scan_photo_url → รูปภาพสแกน (live face-scan snapshot)
    photo_url: str | None = None
    scan_photo_url: str | None = None

    @field_validator("event_time", mode="before")
    @classmethod
    def parse_event_time(cls, v):
        """
        Accept both ISO strings and unix timestamps.

        Timezone handling:
        - Unix timestamps (int/float) are always UTC by definition.
        - ISO strings that already carry an offset (e.g. +07:00 or Z) are
          left untouched — the offset is authoritative.
        - ISO strings WITHOUT an offset are assumed to be Thai local time
          (UTC+7) because the external Access Control system is on-site in
          Thailand and does not include a timezone in its output.
          We attach +07:00 explicitly so downstream code always works with
          timezone-aware datetimes and no silent UTC misinterpretation occurs.
        """
        if isinstance(v, (int, float)):
            # Unix timestamps are UTC by definition
            return datetime.fromtimestamp(v, tz=timezone.utc)
        if isinstance(v, str):
            dt = datetime.fromisoformat(v)
            if dt.tzinfo is None:
                # Naive string from Thai system → attach +07:00
                dt = dt.replace(tzinfo=_THAI_TZ)
            return dt
        # Already a datetime (e.g. passed programmatically in tests)
        if isinstance(v, datetime) and v.tzinfo is None:
            return v.replace(tzinfo=_THAI_TZ)
        return v


class ExternalApiResponse(BaseModel):
    """Wrapper returned by the external polling endpoint."""
    events: list[ExternalAccessEvent]
    total: int


class IngestPayload(BaseModel):
    """Payload sent to NestJS /internal/access-logs."""
    externalStudentId: str
    accessTime: str          # ISO-8601 string
    type: Literal["IN", "OUT"]
    gateName: str
    photoUrl: str | None = None
    scanPhotoUrl: str | None = None
