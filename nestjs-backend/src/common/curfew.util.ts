/**
 * Pure, dependency-free helpers for access-log time handling.
 *
 * Extracted from AccessLogsService so the timezone and curfew rules can be
 * unit-tested in isolation (no Nest/Prisma/DB needed) and reused without
 * duplication (DRY).
 */

/** Default curfew window in Thai local time (ICT, UTC+7), crosses midnight. */
export const DEFAULT_CURFEW_START_MIN = 22 * 60 + 30; // 22:30 → 1350
export const DEFAULT_CURFEW_END_MIN = 6 * 60; //         06:00 → 360

/**
 * Parse an "HH:MM" string into minutes-since-midnight, falling back to
 * [fallback] when the value is missing or malformed. Used to read the curfew
 * window from configuration instead of hardcoding it.
 */
export function parseTimeToMinutes(
  value: string | undefined,
  fallback: number,
): number {
  if (!value) return fallback;
  const m = /^(\d{1,2}):(\d{2})$/.exec(value.trim());
  if (!m) return fallback;
  const hh = Number(m[1]);
  const mm = Number(m[2]);
  if (hh > 23 || mm > 59) return fallback;
  return hh * 60 + mm;
}

/**
 * Interpret an incoming access time as **Thai local time (UTC+7)** regardless
 * of whatever timezone designator the caller appended.
 *
 * The on-site hardware, FastAPI, and manual tests all report Thai local time,
 * so we strip fractional seconds and any timezone suffix (`Z`, `+00:00`,
 * `+07:00`, or none) and re-attach `+07:00`.
 *
 *   "2026-05-06T17:35:00"        → Thai 17:35
 *   "2026-05-06T17:35:00+07:00"  → Thai 17:35
 *   "2026-05-06T17:35:00.000Z"   → Thai 17:35  (Z ignored)
 */
export function normalizeThaiTime(iso: string): Date {
  const thaiStr = iso
    .replace(/\.\d+/, '') //             strip fractional seconds
    .replace(/[Zz]$|[+-]\d{2}:\d{2}$/, ''); // strip any timezone designator
  return new Date(thaiStr + '+07:00');
}

/**
 * Whether an access event is "late" (inside the curfew window) or "ontime".
 * Only IN events can be late; OUT is always ontime.
 *
 * Curfew crosses midnight, so an event is late when the Thai minute-of-day is
 * >= start (evening) OR < end (early morning).
 */
export function computeAccessStatus(
  accessTime: Date,
  type: 'IN' | 'OUT',
  curfewStartMin: number = DEFAULT_CURFEW_START_MIN,
  curfewEndMin: number = DEFAULT_CURFEW_END_MIN,
): 'late' | 'ontime' {
  if (type !== 'IN') return 'ontime';
  const utcMin = accessTime.getUTCHours() * 60 + accessTime.getUTCMinutes();
  const thaiMin = (utcMin + 7 * 60) % (24 * 60);
  return thaiMin >= curfewStartMin || thaiMin < curfewEndMin ? 'late' : 'ontime';
}
