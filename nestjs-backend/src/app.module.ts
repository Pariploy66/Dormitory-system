import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { CommonModule } from './common/common.module';
import { PrismaModule } from './common/prisma.module';
import { AuthModule } from './auth/auth.module';
import { StudentsModule } from './students/students.module';
import { AccessLogsModule } from './access-logs/access-logs.module';
import { NotificationsModule } from './notifications/notifications.module';
import { EventsModule } from './events/events.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ThrottlerModule.forRoot([{ ttl: 60_000, limit: 30 }]),
    CommonModule,
    PrismaModule,
    AuthModule,
    StudentsModule,
    AccessLogsModule,
    NotificationsModule,
    EventsModule,
  ],
})
export class AppModule {}
