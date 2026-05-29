import { Module } from '@nestjs/common';
import { AccessLogsService } from './access-logs.service';
import { AccessLogsController } from './access-logs.controller';
import { NotificationsModule } from '../notifications/notifications.module';
import { EventsModule } from '../events/events.module';

@Module({
  imports: [NotificationsModule, EventsModule],
  providers: [AccessLogsService],
  controllers: [AccessLogsController],
})
export class AccessLogsModule {}
