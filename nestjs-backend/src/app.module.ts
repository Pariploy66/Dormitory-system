import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { CommonModule } from './common/common.module';
import { PrismaModule } from './common/prisma.module';
import { AuthModule } from './modules/auth/auth.module';
import { StudentsModule } from './modules/students/students.module';
import { AccessLogsModule } from './modules/access-logs/access-logs.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { EventsModule } from './modules/events/events.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env.local',
    }),
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
