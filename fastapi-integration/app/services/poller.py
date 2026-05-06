"""
The poll loop: every POLL_INTERVAL_SECONDS seconds, fetch new events
from the external API and forward them to NestJS.

Deduplication happens at two levels:
1. Timestamp watermark (last_processed_timestamp) — only fetch events newer
   than what we've already processed.
2. NestJS Prisma upsert — the composite unique index on access_logs
   guarantees no duplicate rows even if we send the same event twice.
"""
import asyncio
import logging

from tenacity import RetryError

from app.services.external_client import fetch_events_since
from app.services.nestjs_client import forward_event
from app.services.state import poller_state
from app.config import settings

logger = logging.getLogger(__name__)


async def run_poll_cycle() -> dict:
    """Execute one poll cycle. Returns a summary dict for the status endpoint."""
    since = poller_state.last_processed
    logger.info("Polling external API since %s", since.isoformat())

    try:
        api_response = await fetch_events_since(since)
    except RetryError as e:
        logger.error("External API unavailable after retries: %s", e)
        return {"status": "external_api_down", "events_fetched": 0, "events_forwarded": 0}

    events = api_response.events
    if not events:
        logger.info("No new events")
        return {"status": "ok", "events_fetched": 0, "events_forwarded": 0}

    forwarded = 0
    latest_time = since

    for event in events:
        ok = await forward_event(event)
        if ok:
            forwarded += 1
        # Track the latest event time seen regardless of forward success.
        # After the schema fix, event_time is always timezone-aware (+07:00).
        # Python compares tz-aware datetimes correctly across timezones.
        if event.event_time > latest_time:
            latest_time = event.event_time

    # Advance watermark only after processing the whole batch
    poller_state.advance(latest_time)

    logger.info(
        "Poll done: fetched=%d forwarded=%d watermark=%s",
        len(events), forwarded, poller_state.iso(),
    )
    return {
        "status": "ok",
        "events_fetched": len(events),
        "events_forwarded": forwarded,
        "watermark": poller_state.iso(),
    }


async def start_poll_loop():
    """Infinite poll loop — run as an asyncio background task."""
    interval = settings.poll_interval_seconds
    logger.info("Poller started — interval=%ds", interval)
    while True:
        try:
            await run_poll_cycle()
        except Exception as e:
            logger.exception("Unexpected error in poll cycle: %s", e)
        await asyncio.sleep(interval)
