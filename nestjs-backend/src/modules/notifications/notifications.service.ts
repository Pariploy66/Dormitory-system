import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import { existsSync } from 'fs';
import { isAbsolute, resolve } from 'path';
import { PrismaService } from '../../common/prisma.service';

@Injectable()
export class NotificationsService implements OnModuleInit {
  private readonly logger = new Logger(NotificationsService.name);
  private firebaseApp: admin.app.App;

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {}

  onModuleInit() {
    const configured = this.config.get<string>('FIREBASE_SERVICE_ACCOUNT_PATH');
    if (!configured) {
      this.logger.warn('FIREBASE_SERVICE_ACCOUNT_PATH not set — FCM disabled');
      return;
    }

    // Resolve relative to the process working dir (nestjs-backend/) so it works
    // the same in dev (ts-node) and prod (dist), regardless of module location.
    const path = isAbsolute(configured)
      ? configured
      : resolve(process.cwd(), configured);

    // Crash-safe: a missing/invalid key disables FCM instead of failing
    // bootstrap (the app must still start for teammates without the key).
    if (!existsSync(path)) {
      this.logger.warn(
        `Firebase service account not found at ${path} — FCM disabled`,
      );
      return;
    }
    try {
      // eslint-disable-next-line @typescript-eslint/no-var-requires
      const serviceAccount = require(path);
      this.firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      this.logger.log('Firebase Admin SDK initialised');
    } catch (e) {
      this.logger.warn(`Firebase init failed — FCM disabled: ${e}`);
    }
  }

  /**
   * Sends a push notification to every parent linked to a student.
   * Silently skips if Firebase is not configured.
   */
  async notifyParentsOfStudent(
    student: { id: string; name: string },
    log: { type: string; gateName: string; accessTime: Date },
  ) {
    if (!this.firebaseApp) return;

    // Fetch all FCM tokens of parents linked to this student
    const mappings = await this.prisma.parentStudentMapping.findMany({
      where: { studentId: student.id },
      include: {
        parent: {
          include: { devices: { select: { fcmToken: true } } },
        },
      },
    });

    const tokens: string[] = mappings.flatMap((m) =>
      m.parent.devices.map((d) => d.fcmToken),
    );
    if (!tokens.length) return;

    const direction = log.type === 'IN' ? 'เข้า' : 'ออก';
    const timeStr = log.accessTime.toLocaleTimeString('th-TH', {
      hour: '2-digit',
      minute: '2-digit',
    });

    const message: admin.messaging.MulticastMessage = {
      tokens,
      notification: {
        title: `${student.name} ${direction}หอพัก`,
        body: `ประตู: ${log.gateName} · เวลา ${timeStr}`,
      },
      data: {
        studentId: student.id,
        type: log.type,
        gateName: log.gateName,
        accessTime: log.accessTime.toISOString(),
      },
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } },
    };

    try {
      const response = await admin.messaging().sendEachForMulticast(message);
      this.logger.log(
        `FCM sent: ${response.successCount} ok, ${response.failureCount} failed`,
      );

      // Clean up invalid tokens
      response.responses.forEach(async (r, i) => {
        if (
          !r.success &&
          (r.error?.code === 'messaging/invalid-registration-token' ||
            r.error?.code === 'messaging/registration-token-not-registered')
        ) {
          await this.prisma.device
            .delete({ where: { fcmToken: tokens[i] } })
            .catch(() => null);
        }
      });
    } catch (err) {
      this.logger.error('FCM send error', err);
    }
  }
}
