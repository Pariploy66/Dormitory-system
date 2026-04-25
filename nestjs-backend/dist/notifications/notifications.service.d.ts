import { OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../common/prisma.service';
export declare class NotificationsService implements OnModuleInit {
    private readonly prisma;
    private readonly config;
    private readonly logger;
    private firebaseApp;
    constructor(prisma: PrismaService, config: ConfigService);
    onModuleInit(): void;
    notifyParentsOfStudent(student: {
        id: string;
        name: string;
    }, log: {
        type: string;
        gateName: string;
        accessTime: Date;
    }): Promise<void>;
}
