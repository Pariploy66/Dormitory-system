from datetime import datetime
from typing import Literal
from pydantic import BaseModel, field_validator


class ExternalAccessEvent(BaseModel):
    """Represents a raw event from the external Access Control API."""
    student_id: str          # external system's student identifier
    student_code: str
    student_name: str
    event_time: datetime
    event_type: Literal["IN", "OUT"]
    gate_name: str

    @field_validator("event_time", mode="before")
    @classmethod
    def parse_event_time(cls, v):
        """Accept both ISO strings and unix timestamps."""
        if isinstance(v, (int, float)):
            return datetime.fromtimestamp(v)
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
