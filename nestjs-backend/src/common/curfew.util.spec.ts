import {
  normalizeThaiTime,
  computeAccessStatus,
  parseTimeToMinutes,
  DEFAULT_CURFEW_START_MIN,
  DEFAULT_CURFEW_END_MIN,
} from './curfew.util';

// Helper: build a Date that reads as the given Thai wall-clock time.
// Thai 22:30 == 15:30 UTC, so we pass the UTC equivalent.
const thai = (hh: number, mm: number): Date =>
  new Date(Date.UTC(2026, 6, 3, (hh + 24 - 7) % 24, mm));

describe('normalizeThaiTime', () => {
  it('treats a naive datetime as Thai time (UTC+7)', () => {
    // 17:35 Thai == 10:35 UTC
    expect(normalizeThaiTime('2026-05-06T17:35:00').toISOString()).toBe(
      '2026-05-06T10:35:00.000Z',
    );
  });

  it('ignores a trailing Z and still treats it as Thai time', () => {
    expect(normalizeThaiTime('2026-05-06T17:35:00.000Z').toISOString()).toBe(
      '2026-05-06T10:35:00.000Z',
    );
  });

  it('ignores an explicit +07:00 offset (same result)', () => {
    expect(normalizeThaiTime('2026-05-06T17:35:00+07:00').toISOString()).toBe(
      '2026-05-06T10:35:00.000Z',
    );
  });

  it('ignores a +00:00 offset and reinterprets as Thai', () => {
    expect(normalizeThaiTime('2026-05-06T17:35:00+00:00').toISOString()).toBe(
      '2026-05-06T10:35:00.000Z',
    );
  });

  it('all designator variants collapse to the same instant', () => {
    const a = normalizeThaiTime('2026-05-06T17:35:00').getTime();
    const b = normalizeThaiTime('2026-05-06T17:35:00.999Z').getTime();
    const c = normalizeThaiTime('2026-05-06T17:35:00+07:00').getTime();
    expect(a).toBe(b);
    expect(b).toBe(c);
  });
});

describe('computeAccessStatus (curfew 22:30–05:59 Thai)', () => {
  it('OUT is always ontime, even deep in curfew', () => {
    expect(computeAccessStatus(thai(3, 0), 'OUT')).toBe('ontime');
  });

  it('22:29 IN is ontime (just before curfew)', () => {
    expect(computeAccessStatus(thai(22, 29), 'IN')).toBe('ontime');
  });

  it('22:30 IN is late (curfew start, inclusive)', () => {
    expect(computeAccessStatus(thai(22, 30), 'IN')).toBe('late');
  });

  it('23:59 IN is late', () => {
    expect(computeAccessStatus(thai(23, 59), 'IN')).toBe('late');
  });

  it('00:00 IN is late (past midnight, still curfew)', () => {
    expect(computeAccessStatus(thai(0, 0), 'IN')).toBe('late');
  });

  it('05:59 IN is late (last curfew minute)', () => {
    expect(computeAccessStatus(thai(5, 59), 'IN')).toBe('late');
  });

  it('06:00 IN is ontime (curfew end, exclusive)', () => {
    expect(computeAccessStatus(thai(6, 0), 'IN')).toBe('ontime');
  });

  it('daytime 14:38 IN is ontime', () => {
    expect(computeAccessStatus(thai(14, 38), 'IN')).toBe('ontime');
  });

  it('honours a custom curfew window (20:00–04:00)', () => {
    const start = 20 * 60;
    const end = 4 * 60;
    expect(computeAccessStatus(thai(19, 59), 'IN', start, end)).toBe('ontime');
    expect(computeAccessStatus(thai(20, 0), 'IN', start, end)).toBe('late');
    expect(computeAccessStatus(thai(3, 59), 'IN', start, end)).toBe('late');
    expect(computeAccessStatus(thai(4, 0), 'IN', start, end)).toBe('ontime');
  });

  it('exposes the documented default window constants', () => {
    expect(DEFAULT_CURFEW_START_MIN).toBe(1350);
    expect(DEFAULT_CURFEW_END_MIN).toBe(360);
  });
});

describe('parseTimeToMinutes', () => {
  it('parses a valid HH:MM string', () => {
    expect(parseTimeToMinutes('22:30', 0)).toBe(1350);
    expect(parseTimeToMinutes('06:00', 0)).toBe(360);
    expect(parseTimeToMinutes('0:05', 0)).toBe(5);
  });

  it('falls back when undefined, empty, or malformed', () => {
    expect(parseTimeToMinutes(undefined, 1350)).toBe(1350);
    expect(parseTimeToMinutes('', 1350)).toBe(1350);
    expect(parseTimeToMinutes('garbage', 1350)).toBe(1350);
    expect(parseTimeToMinutes('7pm', 1350)).toBe(1350);
  });

  it('rejects out-of-range hours/minutes and falls back', () => {
    expect(parseTimeToMinutes('24:00', 999)).toBe(999);
    expect(parseTimeToMinutes('12:60', 999)).toBe(999);
  });
});
