import {
  Controller,
  Get,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { PrismaService } from '../../common/prisma.service';

/**
 * Health endpoints for monitoring / container orchestration.
 *
 *   GET /health        liveness  — process is up (no dependency checks)
 *   GET /health/ready  readiness — critical dependencies (DB) are reachable
 *
 * Public + rate-limit-exempt (probes poll frequently). Responses expose only
 * coarse status strings — never connection strings, versions, or errors.
 */
@SkipThrottle()
@Controller('health')
export class HealthController {
  private readonly logger = new Logger(HealthController.name);

  constructor(private readonly prisma: PrismaService) {}

  @Get()
  liveness() {
    return {
      status: 'ok',
      uptimeSeconds: Math.round(process.uptime()),
      timestamp: new Date().toISOString(),
    };
  }

  @Get('ready')
  async readiness() {
    let db: 'up' | 'down' = 'down';
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      db = 'up';
    } catch (e) {
      // Log the real error server-side; the client sees only "down".
      this.logger.error(`Readiness DB check failed: ${(e as Error).message}`);
    }

    if (db !== 'up') {
      // 503 so orchestrators/load balancers stop routing traffic here.
      throw new ServiceUnavailableException('database not reachable');
    }
    return {
      status: 'ok',
      checks: { database: db },
      timestamp: new Date().toISOString(),
    };
  }
}
