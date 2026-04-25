import asyncio
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.services.poller import run_poll_cycle, start_poll_loop
from app.services.state import poller_state
from app.config import settings

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s — %(message)s",
)
logger = logging.getLogger(__name__)

# ─── Background task handle ─────────────────────────────────
_poll_task: asyncio.Task | None = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    global _poll_task
    logger.info("Starting FastAPI integration layer")
    _poll_task = asyncio.create_task(start_poll_loop())
    yield
    logger.info("Shutting down — cancelling poll loop")
    _poll_task.cancel()
    try:
        await _poll_task
    except asyncio.CancelledError:
        pass


app = FastAPI(
    title="Student Access — Integration Layer",
    version="1.0.0",
    lifespan=lifespan,
)


# ─── Health & status endpoints ───────────────────────────────

@app.get("/health")
async def health():
    return {"status": "ok"}


@app.get("/status")
async def status():
    return {
        "watermark": poller_state.iso(),
        "poll_interval_seconds": settings.poll_interval_seconds,
        "nestjs_url": settings.nestjs_base_url,
        "external_api_url": settings.external_api_base_url,
    }


@app.post("/poll/trigger")
async def trigger_poll():
    """Manually trigger a poll cycle (useful for testing)."""
    result = await run_poll_cycle()
    return result
