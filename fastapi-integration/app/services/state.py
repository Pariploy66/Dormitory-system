"""
Simple in-process state store for the poller.

Tracks the last successfully processed timestamp so every poll
only requests events NEWER than what we've already seen.

In production you could swap this for a Redis key or a small
SQLite file so state survives restarts.
"""
from datetime import datetime, timezone


class PollerState:
    def __init__(self):
        # Default: start from 24 hours ago on first run
        self._last_processed: datetime = datetime.now(timezone.utc).replace(
            hour=0, minute=0, second=0, microsecond=0
        )

    @property
    def last_processed(self) -> datetime:
        return self._last_processed

    def advance(self, up_to: datetime) -> None:
        """Call after a successful batch to move the watermark forward."""
        if up_to > self._last_processed:
            self._last_processed = up_to

    def iso(self) -> str:
        return self._last_processed.isoformat()


# Module-level singleton — shared across the application
poller_state = PollerState()
