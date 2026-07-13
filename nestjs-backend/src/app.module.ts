import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { CommonModule } from './common/common.module';
import { PrismaModule } from './common/prisma.module';
import { AuthModule } from './modules/auth/auth.module';
import { StudentsModule } from './modules/students/students.module';
import { AccessLogsModule } from './modules/access-logs/access-logs.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { EventsModule } from './modules/events/events.module';

// Rate-limit window/limit are env-driven (no hardcoded values). Defaults keep
// the previous behaviour: 30 requests / 60s per client.
const RATE_TTL_MS = Number(process.env.RATE_LIMIT_TTL_MS ?? 60_000);
const RATE_LIMIT = Number(process.env.RATE_LIMIT_MAX ?? 30);

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    ThrottlerModule.forRoot([{ ttl: RATE_TTL_MS, limit: RATE_LIMIT }]),
    CommonModule,
    PrismaModule,
    AuthModule,
    StudentsModule,
    AccessLogsModule,
    NotificationsModule,
    EventsModule,
  ],
  providers: [
    // Register ThrottlerGuard globally so the configured rate limit is actually
    // enforced (previously the module was imported but no guard was applied,
    // leaving every endpoint unthrottled).
    { provide: APP_GUARD, useClass: ThrottlerGuard },
  ],
})
export class AppModule {}
